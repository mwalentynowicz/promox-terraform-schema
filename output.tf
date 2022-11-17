output "array_of_vms1" {
  description = "Szybki podglad, ktora vmka to ktory numer w tablicy hostow."
  value = <<EOT
                %{ for table_id, name in proxmox_vm_qemu.vm.*.name }
                    Numer w tablicy test_env[${table_id}] = ${name}
                %{ endfor }
                EOT
}