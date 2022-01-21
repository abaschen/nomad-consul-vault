job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "external" {
        static = 9443
      }


      port "api" {
        static = 8081
      }
    }

    task "traefik" {
      driver = "podman"

      config {
        image        = "traefik:latest"
        network_mode = "host"
        volumes = [
          "/etc/consul.d/consul-agent-ca.pem:/etc/ssl/consul/ca.crt",
          "/mnt/tank/storage/config/certs:/etc/ssl/certs",
          "local/traefik.yml:/etc/traefik/traefik.yml"
        ]
      }
      vault {
        policies = ["traefik"]
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      template {
        data = <<EOH
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"
    http:
      tls:
        domains:
          - main: "*.tec.192.168.1.201.nip.io"
            sans:
              - "*.tec.192.168.1.201.nip.io"
  external:
    address: ":9443"
    http:
      tls:
        domains:
          - main: "*.techunter.io"
            sans:
              - "techunter.io"
              - "*.techunter.io"

  traefik:
    address: ":8081"

api:
  dashboard: true
  insecure: true
certificatesResolvers:
  resolverName:
    vault:
      url: "http://127.0.0.1:8200"
      auth:
        token: "{{ with secret "nomad/creds/traefik" }}{{ .Data.secret_id }}{{end}}"
      enginePath: "pki"
      role: "pki_manager"
providers:
  consulCatalog:
    prefix: traefik
    exposedByDefault: true
    defaultRule: "Host(`{{ .Name }}.tec.192.168.1.201.nip.io`)"
    endpoint:
      address: "127.0.0.1:8501"
      scheme: "https"
      token: "{{ with secret "secrets/data/traefik" }}{{ .Data.data.consulCatalog }}{{end}}"
      tls:
        ca: /etc/ssl/consul/ca.crt
        insecureSkipVerify: true
log:
  level: DEBUG
        EOH
        destination = "local/traefik.yml"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      service {
        name = "traefik"

        check {
          name     = "alive"
          type     = "tcp"
          port     = "https"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}

