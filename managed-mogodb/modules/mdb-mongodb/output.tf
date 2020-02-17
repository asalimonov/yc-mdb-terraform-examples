output "cluster_id" {
  value = "${yandex_mdb_mongodb_cluster.managed_mongodb.id}"
}

output "cluster_hosts_fqdns" {
  value = ["${yandex_mdb_mongodb_cluster.managed_mongodb.host.*.name}"]
}

output "cluster_hosts_fips" {
  value = "${zipmap(yandex_mdb_mongodb_cluster.managed_mongodb.host.*.name,
  yandex_mdb_mongodb_cluster.managed_mongodb.host.*.assign_public_ip)}"
}

output "cluster_users" {
  value = ["${yandex_mdb_mongodb_cluster.managed_mongodb.user.*.name}"]
}

output "cluster_users_passwords" {
  value = "${zipmap(yandex_mdb_mongodb_cluster.managed_mongodb.user.*.name,
  yandex_mdb_mongodb_cluster.managed_mongodb.user.*.password)}"
  sensitive = true
}

output "cluster_databases" {
  value = "${yandex_mdb_mongodb_cluster.managed_mongodb.database.*.name}"
}

