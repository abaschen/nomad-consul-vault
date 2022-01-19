<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <BindAddress>*</BindAddress>
  <EnableSsl>False</EnableSsl>
  <SslCertPath></SslCertPath>
  <Port>{{ env NOMAD_PORT_http }}</Port>
  <UrlBase></UrlBase>
  <ApiKey>{{ with secret "secrets/radarr" }}{{ .Data.api }}{{end}}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <SslPort>9898</SslPort>
  <LaunchBrowser>True</LaunchBrowser>
  <Branch>master</Branch>
  <SslCertPassword></SslCertPassword>
  <AnalyticsEnabled>False</AnalyticsEnabled>
</Config>