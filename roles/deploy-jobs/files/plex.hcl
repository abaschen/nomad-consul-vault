job "plex" {
  region = "global"
  datacenters = ["dc1"]

  group "plex" {
    count = 1 
    network {
        port "http" { to = "32400" }
    }

    task "plex" {
      driver = "podman"
      env {
        PUID = "0"
        GUID = "0"
        TZ   = "Europe/Paris"
        UMASK = "002"
      }
      config {
        image = "plexinc/pms-docker:plexpass"
        force_pull = "true"
        ports = ["http"]
        volumes = [
          "/mnt/tank/storage/config/plex:/config",
          "/mnt/tank/storage/config/certs:/certs",
          "/mnt/tank/storage/media/videos:/data"
        ]
        tmpfs = [
          "/transcode"
        ]
      }

      service {
        port = "http"
        name = "plex"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
                  "traefik.enable=true",
                  "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=websecure",
                  "traefik.http.routers.${NOMAD_TASK_NAME}.tls=true"
        ]
      }

      resources {
        cpu    = 20000
        memory = 16284
      }
    }
  }
}

