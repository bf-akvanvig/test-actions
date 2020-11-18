provider "libvirt" {
  alias = "server2"
  uri   = "qemu+ssh://${{ secrets.hostname }}/system"
}
