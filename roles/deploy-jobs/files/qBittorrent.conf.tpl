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
