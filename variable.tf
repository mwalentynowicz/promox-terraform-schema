variable cluster_address {
  type = string
  default = "https://192.0.0.0:8006/api2/json"
}

variable vm_properties {
  type = list(object({
    table_id       = string       #brzydko zahardkodowany numeru tablicy
    vmid           = string       #virtual machine id - dla porzadku na wirtualizatorze - unique
    target_node    = string       #na którym nodzie w clustrze terraform ma utworzyć daną maszynkę
    name           = string       #nazwa VMki oraz hostname
    description    = string       #opis widoczny w GUI Proxmoxa
    force_recreate = string       #przełącznik do wymuszania przebudowy VMki - domyślnie false - praktycznie nie znalazlem funkcjonalnosci
    private_ip     = string       #prywatny adres ip dla VMki
    disk_size      = string       #rozmiar dysku
    clone_image    = string       #nazwa templatki, z której będzie brany obraz do cloudinit
    vcpu           = string       #określa liczbę corów na jednym socketcie
    ram            = string       #wielkość RAMu (w MB)
    network_bridge = string       #nazwa interfejsu sieciowego - ważne dla separacji sieci
    public_ip      = string       #publiczny adres IP, jeżeli VMka posiada
    public_ip_gw   = string       #gateway dla publicznego adresu IP
    ci             = string       #nazwa pliku z cloudinitem
    gateway        = string       #gateway
    tag            = string       #tag vlanu (default -1)
  }))

  default = [
    {
      table_id       = "0"
      vmid           = "900"
      target_node    = "node01"
      name           = "VM01"
      description    = "Ładny opis dla GUI Proxmoxa. Maszynka z public IP"
      force_recreate = "true"
      private_ip     = "10.0.10.1"
      tag            = "-1"
      disk_size      = "30G"
      clone_image    = "debian-cloudinit"
      vcpu           = "1"
      ram            = "4096"
      network_bridge = "vmbr1"
      public_ip      = "0.0.0.0/32"
      public_ip_gw   = "0.0.0.1"
      ci             = "vm01"
      gateway        = "10.0.10.1"
    },
    {
      table_id       = "1"
      vmid           = "910"
      target_node    = "node02"
      name           = "vm02"
      description    = "Serwer ukryty w vlanie bez publicow"
      force_recreate = "false"
      private_ip     = "10.0.0.1"
      disk_size      = "20G"
      clone_image    = "debian-cloudinit"
      vcpu           = "2"
      ram            = "8192"
      network_bridge = "vmbr2"
      public_ip      = ""
      public_ip_gw   = ""
      ci             = "vm02"
      gateway        = "10.0.10.10"
    }
  ]
}