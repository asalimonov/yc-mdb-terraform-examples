output "disk_names_by_ids" {
    value = {
        for instance in yandex_compute_disk.vm_disk :
            instance.id => instance.name
    }
}

output "disk_ids_by_names" {
    value = {
        for instance in yandex_compute_disk.vm_disk :
            instance.name => instance.id
    }
}

output "disk_zones_by_ids" {
    value  = {
        for instance in yandex_compute_disk.vm_disk :
            instance.id => instance.zone
    }
}

output "disk_names" {
  value = "${yandex_compute_disk.vm_disk.*.name}"
}

output "disk_ids" {
  value = "${yandex_compute_disk.vm_disk.*.id}" 
}

output "vm_fqdns" {
    value = "${yandex_compute_instance.vm.*.fqdn}"
}

output "vms" {
    value = {
        for instance in yandex_compute_instance.vm :
            instance.fqdn => 
            {
                name = instance.name
                fqdn = instance.fqdn
                zone = instance.zone
                internal_ip = instance.network_interface.0.ip_address
                nat_address = instance.network_interface.0.nat_ip_address
                secondary_disk = instance.secondary_disk
            }
    }
}

