output "ip" {
  value = yandex_compute_instance.vm["one"].network_interface.0.nat_ip_address
}
