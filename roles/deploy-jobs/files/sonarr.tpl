<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <EnableSsl>False</EnableSsl>
  <Port>{{ env NOMAD_PORT_http }}</Port>
  <SslPort>9898</SslPort>
  <UrlBase></UrlBase>
  <BindAddress>*</BindAddress>
  <ApiKey>{{ with secret "secrets/sonarr" }}{{ .Data.api }}{{end}}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <LaunchBrowser>True</LaunchBrowser>
  <Branch>develop</Branch>
  <SslCertHash></SslCertHash>
</Config>