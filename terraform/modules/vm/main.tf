terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_compute_instance" "vm" {
  for_each    = var.vm_options
  platform_id = "standard-v3"
  name = lookup(each.value, "name")
  hostname = lookup(each.value, "name")

  resources {
    memory        = lookup(each.value, "memory", 2)
    cores         = lookup(each.value, "cores", 2)
    core_fraction = lookup(each.value, "core_fraction", 20)
  }

  scheduling_policy {
    preemptible = lookup(each.value, "preemptible", true)
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = lookup(each.value, "image_id", "fd87j6d92jlrbjqbl32q")
      size     = lookup(each.value, "boot_disk_size", 10)
    }
  }

  network_interface {
    subnet_id          = lookup(each.value, "subnet_id")
    nat                = lookup(each.value, "nat", false)
    security_group_ids = each.value["security_group_ids"]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  labels = {
    group = lookup(each.value, "group", "app")
  }

  zone = lookup(each.value, "zone")
}
