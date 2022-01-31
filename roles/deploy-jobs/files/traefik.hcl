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
        cap_add=["CAP_NET_BIND_SERVICE", "NET_ADMIN"]
        image        = "docker.io/traefik:latest"
        network_mode = "host"
        #privileged = "true"
        #ports = ["http","https","external", "api"]
        volumes = [
          "/etc/consul.d/consul-agent-ca.pem:/etc/ssl/consul/ca.crt",
          "secret/cert.pem:/etc/ssl/certs/ix.techunter.io.pem",
          "secret/cert.key:/etc/ssl/certs/ix.techunter.io.key",
          "local/traefik.yml:/etc/traefik/traefik.yml"
        ]
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
          - main: "*.techunter.io"
            sans:
              - "*.techunter.io"
              - "ix.techunter.io"

  traefik:
    address: ":8081"

api:
  dashboard: true
  insecure: true
tls:
  certificates:
    - certFile: /certs/ix.techunter.io.pem
      keyFile: /certs/ix.techunter.io.key
providers:
  consulCatalog:
    prefix: traefik
    exposedByDefault: true
    defaultRule: "Host(`ix.techunter.io`)"
    endpoint:
      address: "server.dc1.consul:8501"
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

      template {
        data = <<EOF
{{ with secret "pki_int/issue/techunter-io" "common_name=*.ix.techunter.io" "ttl=30d" }}{{ .Data.private_key }}{{ end }}
EOF

        destination = "secret/cert.key"
      }
      template {
        data = <<EOH
{{ with secret "pki_int/issue/techunter-io" "common_name=*.ix.techunter.io" "ttl=30d" }}
{{ .Data.certificate }}
{{ end }}
      EOH

        destination = "secret/cert.pem"
      }

      vault {
        policies      = ["traefik", "issue-techunter-io"]
        change_mode   = "signal"
        change_signal = "SIGHUP"
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
      resources {
        cpu    = 2000
        memory = 1024
      }
    }
  }
}

