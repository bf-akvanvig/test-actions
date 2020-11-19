terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.6.2"
    }
  }
}

#provider "libvirt" {
#  uri = "qemu:///system"
#}

provider "libvirt" {
  uri   = "qemu+ssh://libvirt-user@81.166.193.189:7000/system"
}

resource "libvirt_volume" "centos7-qcow2" {
  name   = "centos7.qcow2"
  pool   = "default"
  source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "test-vm1" {
  name   = "test-vm1"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.centos7-qcow2.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
