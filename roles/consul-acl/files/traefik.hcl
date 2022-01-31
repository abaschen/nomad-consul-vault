key_prefix "traefik" {
  policy = "write"
}

service "traefik" {
  policy = "write"
}
service "" {
  policy = "write"
}

service_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}