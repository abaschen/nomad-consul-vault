job "torrent-client" {
  region = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "downloaders" {
    count = 1
    network {
          port "http" { }
          port "inbound" {  }
    }

    task "qbittorrent" {
      driver = "podman"
      env {
        PUID = "0"
        PGID = "0"
        TZ   = "Europe/Paris"
        UMASK = "002"
        WEBUI_PORT= "${NOMAD_PORT_http}"
      }
      config {
        image = "lscr.io/linuxserver/qbittorrent"
	    ports = ["http", "inbound"]
        volumes = [
            "/mnt/tank/storage/config/qbittorrent:/config/qBittorrent",
            "/mnt/tank/storage/download:/downloads",
            "local/qBittorrent.conf:/config/qBittorrent/qBittorrent.conf"
        ]
      }
      vault {
        policies = ["torrent-api"]
        change_mode   = "noop"
      }
      template {
          data = <<EOH
[AutoRun]
enabled=true
program=unrar x -ibck -inul \"%F/*.r*\" \"%F/\"

[BitTorrent]
Session\Categories=@Variant(\0\0\0\b\0\0\0\x5\0\0\0\xe\0t\0v\0-\0s\0h\0o\0w\0\0\0\n\0\0\0\0\0\0\0\x10\0s\0o\0\x66\0t\0w\0\x61\0r\0\x65\0\0\0\n\0\0\0\0\0\0\0\f\0m\0o\0v\0i\0\x65\0s\0\0\0\n\0\0\0\0\0\0\0\n\0m\0o\0v\0i\0\x65\0\0\0\n\0\0\0\0\0\0\0\n\0g\0\x61\0m\0\x65\0s\0\0\0\n\0\0\0\0)
Session\DisableAutoTMMByDefault=true
Session\DisableAutoTMMTriggers\CategoryChanged=false
Session\DisableAutoTMMTriggers\CategorySavePathChanged=true
Session\DisableAutoTMMTriggers\DefaultSavePathChanged=true
Session\GlobalMaxSeedingMinutes=-1
Session\MultiConnectionsPerIp=true
Session\SeedChokingAlgorithm=FastestUpload
Session\TorrentContentLayout=Original

[Core]
AutoDeleteAddedTorrentFile=IfAdded

[LegalNotice]
Accepted=true

[Network]
Cookies=@Invalid()

[Preferences]
Advanced\AnonymousMode=true
Advanced\IgnoreLimitsLAN=true
Advanced\OutgoingPortsMax=0
Advanced\OutgoingPortsMin=0
Advanced\RecheckOnCompletion=false
Advanced\trackerPort={{ env "NOMAD_PORT_inbound" }}
Bittorrent\AddTrackers=false
Bittorrent\DHT=false
Bittorrent\Encryption=1
Bittorrent\MaxConnecs=50000
Bittorrent\MaxConnecsPerTorrent=-1
Bittorrent\MaxRatio=1.5
Bittorrent\MaxRatioAction=0
Bittorrent\MaxUploads=-1
Bittorrent\MaxUploadsPerTorrent=-1
Bittorrent\PeX=true
Bittorrent\uTP_rate_limited=false
Connection\GlobalDLLimit=0
Connection\GlobalDLLimitAlt=0
Connection\GlobalUPLimit=100000
Connection\GlobalUPLimitAlt=10
Connection\PortRangeMin=60881
Connection\ResolvePeerCountries=false
Connection\UPnP=true
Downloads\PreAllocation=false
Downloads\SavePath=/downloads/completed/
Downloads\StartInPause=false
Downloads\TempPath=/downloads/incomplete/
Downloads\TempPathEnabled=false
DynDNS\DomainName=changeme.dyndns.org
DynDNS\Enabled=false
DynDNS\Password=
DynDNS\Service=0
DynDNS\Username=
General\Locale=
General\UseRandomPort=false
MailNotification\email=
MailNotification\enabled=false
MailNotification\password=u..i.a.e
MailNotification\req_auth=true
MailNotification\req_ssl=false
MailNotification\sender=qBittorrent_notification@example.com
MailNotification\smtp_server=smtp.changeme.com
MailNotification\username=admin
Queueing\IgnoreSlowTorrents=true
Queueing\MaxActiveDownloads=-1
Queueing\MaxActiveTorrents=-1
Queueing\MaxActiveUploads=-1
Queueing\QueueingEnabled=false
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\BanDuration=3600
WebUI\CSRFProtection=true
WebUI\ClickjackingProtection=true
WebUI\CustomHTTPHeaders=
WebUI\CustomHTTPHeadersEnabled=false
WebUI\HTTPS\CertificatePath=
WebUI\HTTPS\Enabled=false
WebUI\HTTPS\KeyPath=
WebUI\HostHeaderValidation=false
WebUI\LocalHostAuth=true
WebUI\MaxAuthenticationFailCount=5
WebUI\Password_ha1=@ByteArray(56c08db625dff544aeb2eb1983d98fb0)
WebUI\Port={{ env "NOMAD_PORT_http" }}
WebUI\RootFolder=
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\SessionTimeout=360000
WebUI\UseUPnP=false
WebUI\Username=admin

[RSS]
AutoDownloader\DownloadRepacks=true
AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"
        EOH

          destination = "local/qBittorrent.conf"
          change_mode   = "signal"
          change_signal = "SIGINT"
      }
      service {
        port = "http"
        name = "qbittorrent"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=websecure",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule='Host(`${NOMAD_TASK_NAME}.ix.techunter.io`)'",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls=true"
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }

  }

  group "jackett" {
    count = 1
    network {
      port "http" { to = 9117 }
    }
    task "jackett" {
      driver = "podman"
      env {
        PUID  = "0"
        PGID  = "0"
        S6_READ_ONLY_ROOT = "1"
        TZ    = "Europe/Paris"
        UMASK = "002"
      }

      config {
        image   = "guillaumedsde/jackett-distroless:latest"
        ports = ["http"]
        volumes = [
          "/mnt/tank/storage/config/jackett:/config",
          "/mnt/tank/storage/download:/downloads",
          "local/conf:/config/ServerConfig.json"
        ]

      }
      service {
        port = "http"
        name = "jackett"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=websecure",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule='Host(`${NOMAD_TASK_NAME}.ix.techunter.io`)'",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls=true"
        ]

      }

      resources {
        cpu    = 500
        memory = 256
      }
      vault {
        policies = ["torrent-api"]
        change_mode   = "noop"
      }
      template {
        destination = "local/conf"

        data = <<EOH
{
  "Port": {{ env "NOMAD_PORT_http" }},
  "AllowExternal": true,
  "APIKey": "{{ with secret "secrets/data/jackett" }}{{ .Data.data.api }}{{end}}",
  "AdminPassword": null,
  "InstanceId": "{{ with secret "secrets/data/jackett" }}{{ .Data.data.instanceId }}{{end}}",
  "BlackholeDir": "",
  "UpdateDisabled": true,
  "UpdatePrerelease": false,
  "BasePathOverride": "",
  "CacheEnabled": true,
  "CacheTtl": 2100,
  "CacheMaxResultsPerIndexer": 1000,
  "OmdbApiKey": "",
  "OmdbApiUrl": "",
  "ProxyType": -1,
  "ProxyUrl": "",
  "ProxyPort": null,
  "ProxyUsername": "",
  "ProxyPassword": "",
  "ProxyIsAnonymous": true
}
EOH
      }
    }
  }

  group "sonarr" {
    count = 1
    network {
      port "http" {}
    }

    task "sonarr" {
      driver = "podman"
      env {
        PUID       = "0"
        PGID       = "0"
        TZ         = "Europe/Paris"
        UMASK      = "002"
      }
      config {
        ports = ["http"]

        volumes      = [
          "/mnt/tank/storage/config/sonarr:/config",
          "/mnt/tank/storage/media/videos/TVShows:/tv",
          "/mnt/tank/storage/download/completed:/downloads",
          "local/run:/etc/services.d/sonarr/run"
        ]
        image        = "lscr.io/linuxserver/sonarr"
      }
      vault {
        policies = ["torrent-api"]
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      template {
        data = <<EOH
#!/usr/bin/with-contenv bash

cd /app/sonarr/bin || exit
sed -i "s/\(<Port>\)[^<>]*\(<\/Port\)/\1{{ env "NOMAD_PORT_http" }}\2/" /config/config.xml
sed -i "s/\(<ApiKey>\)[^<>]*\(<\/ApiKey\)/\1{{ with secret "secrets/data/sonarr" }}{{ .Data.data.api }}{{end}}\2/" /config/config.xml
exec s6-setuidgid abc mono --debug Sonarr.exe -nobrowser -data=/config

        EOH

      destination = "local/run"
      change_mode   = "signal"
      change_signal = "SIGINT"
      perms = "755"
    }
      service {
        port = "http"
        name = "sonarr"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=websecure",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule='Host(`${NOMAD_TASK_NAME}.ix.techunter.io`)'",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls=true"
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 1000
        memory = 512
      }
    }
  }
  group "radarr" {
    count = 1
    network {
      port "http" { }
    }

    task "radarr" {
      driver = "podman"
      env {
        PUID = "0"
        PGID = "0"
        TZ   = "Europe/Paris"
        UMASK = "002"
      }
      config {
        image = "lscr.io/linuxserver/radarr:latest"
        ports = ["http"]
        volumes = [
          "/mnt/tank/storage/config/radarr:/config",
          "/mnt/tank/storage/media/videos/Movies:/movies",
          "/mnt/tank/storage/download/completed:/downloads",
          "local/run:/etc/services.d/radarr/run"
        ]
      }
      vault {
        policies = ["torrent-api"]
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      template {
        data = <<EOH
#!/usr/bin/with-contenv bash

cd /app/radarr/bin || exit
sed -i "s/\(<Port>\)[^<>]*\(<\/Port\)/\1{{ env "NOMAD_PORT_http" }}\2/" /config/config.xml
sed -i "s/\(<ApiKey>\)[^<>]*\(<\/ApiKey\)/\1{{ with secret "secrets/data/radarr" }}{{ .Data.data.api }}{{end}}\2/" /config/config.xml
exec s6-setuidgid abc /app/radarr/bin/Radarr -nobrowser -data=/config

        EOH

        destination = "local/run"
        change_mode   = "signal"
        change_signal = "SIGINT"
        perms = "755"
      }
      service {
        port = "http"
        name = "radarr"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.entrypoints=websecure",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule='Host(`${NOMAD_TASK_NAME}.ix.techunter.io`)'",
          "traefik.http.routers.${NOMAD_TASK_NAME}.tls=true"
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 1000
        memory = 512
      }
    }

  }
}

