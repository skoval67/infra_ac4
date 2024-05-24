resource "yandex_vpc_network" "network1" {
  name = "network1"
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-to-internet"
  network_id = yandex_vpc_network.network1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet-dmz" {
  name           = "subnet-dmz"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.0.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-app1" {
  name           = "subnet-app1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-app2" {
  name           = "subnet-app2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-db1" {
  name           = "subnet-db1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.128.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-db2" {
  name           = "subnet-db2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.129.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_security_group" "dmz-sg" {
  name       = "dmz-sg"
  network_id = yandex_vpc_network.network1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "zone2-app1-sg" {
  name       = "zone2-app1-sg"
  network_id = yandex_vpc_network.network1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "app"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Zone 2"
    v4_cidr_blocks = ["192.168.0.0/23"]
    from_port      = 1
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "zone2-app2-sg" {
  name       = "zone2-app2-sg"
  network_id = yandex_vpc_network.network1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "app"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Zone 2"
    v4_cidr_blocks = ["192.168.0.0/23"]
    from_port      = 1
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "zone3-db1-sg" {
  name       = "zone3-db1-sg"
  network_id = yandex_vpc_network.network1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "app"
    security_group_id = yandex_vpc_security_group.zone2-app1-sg.id
    port              = 80
  }
}

resource "yandex_vpc_security_group" "zone3-db2-sg" {
  name       = "zone3-db2-sg"
  network_id = yandex_vpc_network.network1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.dmz-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "app"
    security_group_id = yandex_vpc_security_group.zone2-app2-sg.id
    port              = 80
  }
}

module "lb_dmz" {
  source = "./modules/vm"

  vm_options = {
    one = {
      name               = "dmzhost"
      subnet_id          = yandex_vpc_subnet.subnet-dmz.id
      nat                = true
      security_group_ids = [yandex_vpc_security_group.dmz-sg.id]
      group              = "dmz"
      zone               = "ru-central1-a"
    }
  }
}

module "app1" {
  source = "./modules/vm"

  vm_options = {
    one = {
      name               = "app1host"
      subnet_id          = yandex_vpc_subnet.subnet-app1.id
      security_group_ids = [yandex_vpc_security_group.zone2-app1-sg.id]
      group              = "app"
      zone               = "ru-central1-a"
    }
  }
}

module "app2" {
  source = "./modules/vm"

  vm_options = {
    one = {
      name               = "app2host"
      subnet_id          = yandex_vpc_subnet.subnet-app2.id
      security_group_ids = [yandex_vpc_security_group.zone2-app2-sg.id]
      group              = "app"
      zone               = "ru-central1-b"
    }
  }
}

module "db1" {
  source = "./modules/vm"

  vm_options = {
    one = {
      name               = "db1"
      subnet_id          = yandex_vpc_subnet.subnet-db1.id
      security_group_ids = [yandex_vpc_security_group.zone3-db1-sg.id]
      group              = "db"
      zone               = "ru-central1-a"
    }
  }
}

module "db2" {
  source = "./modules/vm"

  vm_options = {
    one = {
      name               = "db2"
      subnet_id          = yandex_vpc_subnet.subnet-db2.id
      security_group_ids = [yandex_vpc_security_group.zone3-db2-sg.id]
      group              = "db"
      zone               = "ru-central1-b"
    }
  }
}
