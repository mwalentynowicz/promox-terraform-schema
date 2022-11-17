#Konfiguracja providera dla Proxmoxa
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"

    }
  }

  #Jako backend uzywam bucketow AWSowcyh - ten fragment jest zapozyczony z ksiazki Terraform Up and Runnning i przerobiony leciutko
  #(mamy osobne repo do generowania plikow backend.hcl z danymi o bucketcie s3, gdzie przechowujemy repo)
  backend "s3" {
    key = "backend/s3/terraform.tfstate"
    profile = "moj_profil_aws"
  }
}

provider "proxmox" {
  pm_api_url = var.cluster_address
  pm_debug = true
  pm_user = var.pm_user_x #instrukcja w README.md oraz credentials.tmp
  pm_password = var.pm_pass_x
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}