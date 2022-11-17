resource "null_resource" "vm_properties_cloudinit" {
  count    = "${length(var.vm_properties)}"

  connection {
    type        = "ssh"
    user        = "snippet" #
    private_key = file("~/.ssh/snippet_proxmox_rsa")
    host        = "0.0.0.0"
  }

  provisioner "file" {
    source      = "${path.module}/cloudinit/${var.vm_properties[count.index].ci}-ci.yml"
    # tutaj mamy stworzony dysk NFS na osobnym storage, gdzie przechowujemy wszystkie snippety
    # ten NFS jest podmontowany na wszystkich nodeach - pozwala nam to kopiowac tylko jeden raz plik Cloudinitu
    # zamiast na wszystkie nody
    destination = "/nfs/pve/NFS_SNIPPET/snippets/${var.vm_properties[count.index].ci}-ci.yml" 
  }
}

resource "proxmox_vm_qemu" "vm" {
  count = "${length(var.vm_properties)}"

  vmid        = lookup(var.vm_properties[count.index], "vmid")
  name        = "${lookup(var.vm_properties[count.index], "name")}"
  target_node = "${lookup(var.vm_properties[count.index], "target_node")}"
  desc        = "${lookup(var.vm_properties[count.index], "name")}"

  clone   = "${lookup(var.vm_properties[count.index], "clone_image")}"
  os_type = "cloud-init"

  force_recreate_on_change_of = "${lookup(var.vm_properties[count.index], "force_recreate")}"

  # tutaj znow pojawia sie NFS o którym mowa wyżej
  cicustom  = "user=NFS_SNIPPET:snippets/${lookup(var.vm_properties[count.index], "ci")}-ci.yml"

  #
  #tutaj ponownie może pojawiać się issue z podwójną definicją routingu - drugi interfejs stanowczo wynieść do cloudinit
  #
  # komentarz powyzej powstal juz dawno - ale nie udalo sie tego zrobic - tak apropo naszej rozmowy ;)
  ipconfig0 = "ip=${lookup(var.vm_properties[count.index], "private_ip")}/24,gw=${lookup(var.vm_properties[count.index], "gateway")}"
  ipconfig1 = (count.index == 0 ? "ip=${lookup(var.vm_properties[count.index], "public_ip")},gw=${lookup(var.vm_properties[count.index], "public_ip_gw")}" : "")

  sockets = 1
  cores = "${lookup(var.vm_properties[count.index], "vcpu")}"
  memory = lookup(var.vm_properties[count.index], "ram")
  agent  = 1 # aby to nie wywalilo terraforma po apply, musi być wrzucony qemu-guest-agent w obraz, który wykorzystujemy do tworzenia

  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"
  disk {
    type = "scsi"
    storage = "local"
    size = lookup(var.vm_properties[count.index], "disk_size")
  }

  # Set the network
  # LAN interface
  network {
    #id     = 0
    model  = "e1000"
    bridge = "${lookup(var.vm_properties[count.index], "network_bridge")}"
    firewall = true
  }

  # WAN interface
  network {
    #id     = 0
    model  = "e1000"
    bridge = "vmbr0"
    firewall = false
    link_down = (count.index == 0 ? "false" : "true")
    #macaddr = "02:00:00:09:67:CA"
  }



  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      network
    ]
  }
  tags = "TF"
}
