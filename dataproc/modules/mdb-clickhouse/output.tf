output "cluster_id" {
  value = "${yandex_mdb_clickhouse_cluster.managed_clickhouse.id}"
}

output "cluster_hosts_fqdns" {
  value = [
    for host in yandex_mdb_clickhouse_cluster.managed_clickhouse.host[*] :
    host.fqdn if host.type == "CLICKHOUSE"
  ]
}

output "cluster_hosts_fips" {
  value = "${zipmap(yandex_mdb_clickhouse_cluster.managed_clickhouse.host.*.fqdn,
  yandex_mdb_clickhouse_cluster.managed_clickhouse.host.*.assign_public_ip)}"
}

output "cluster_users" {
  value = ["${yandex_mdb_clickhouse_cluster.managed_clickhouse.user.*.name}"]
}

output "cluster_users_passwords" {
  value = "${zipmap(yandex_mdb_clickhouse_cluster.managed_clickhouse.user.*.name,
  yandex_mdb_clickhouse_cluster.managed_clickhouse.user.*.password)}"
  sensitive = true
}

output "cluster_databases" {
  value = "${yandex_mdb_clickhouse_cluster.managed_clickhouse.database.*.name}"
}

