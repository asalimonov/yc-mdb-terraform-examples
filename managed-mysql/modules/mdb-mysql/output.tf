output "cluster_id" {
  value = "${yandex_mdb_mysql_cluster.managed_mysql.id}"
}

output "cluster_hosts_fqdns" {
  value = ["${yandex_mdb_mysql_cluster.managed_mysql.host.*.fqdn}"]
}

output "cluster_hosts_fips" {
  value = "${zipmap(yandex_mdb_mysql_cluster.managed_mysql.host.*.fqdn,
  yandex_mdb_mysql_cluster.managed_mysql.host.*.assign_public_ip)}"
}

output "cluster_users" {
  value = ["${yandex_mdb_mysql_cluster.managed_mysql.user.*.name}"]
}

output "cluster_users_passwords" {
  value = "${zipmap(yandex_mdb_mysql_cluster.managed_mysql.user.*.name,
  yandex_mdb_mysql_cluster.managed_mysql.user.*.password)}"
  sensitive = true
}

output "cluster_databases" {
  value = "${yandex_mdb_mysql_cluster.managed_mysql.database.*.name}"
}

