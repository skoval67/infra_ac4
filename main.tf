resource "yandex_vpc_network" "network-dmz" {
  name = "network-dmz"
}

resource "yandex_vpc_subnet" "subnet-dmz" {
  name           = "subnet-mz"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-dmz.id
  v4_cidr_blocks = ["10.0.0.0/16"]
  #   route_table_id = yandex_vpc_route_table.rt.id
}
