resource "yandex_dns_zone" "external_zone" {
  name        = "externalzone"
  description = "externalzone"
  zone        = "${var.site_name}."
  public      = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.external_zone.id
  name    = "@"
  type    = "CNAME"
  ttl     = 200
  data    = ["${yandex_dns_recordset.rs2.name}"]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.external_zone.id
  name    = "adm.${var.site_name}."
  type    = "A"
  ttl     = 200
  data    = [module.lb_dmz.ip]
}
