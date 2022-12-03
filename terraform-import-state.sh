#!/bin/sh
# Terraform Import Script

terraform import google_compute_router.router airflow-nat-router
terraform import module.cloud-nat.google_compute_router_nat.main projects/uit-cloud-computing/regions/asia-southeast1/routers/airflow-nat-router/airflow-nat-config
terraform import google_sql_database_instance.postgres_instance airflow-database
terraform import google_sql_database.database projects/uit-cloud-computing/instances/airflow-database/databases/airflow-db
terraform import google_sql_user.users uit-cloud-computing/airflow-database/bi
terraform import google_compute_network.vpc_network airflow-network
terraform import google_compute_global_address.private_ip_address private-ip-address
terraform import google_compute_firewall.airflow-allow-ssh airflow-allow-ssh
terraform import google_compute_firewall.airflow-allow-http airflow-allow-http
terraform import google_compute_firewall.airflow-allow-https airflow-allow-https
terraform import google_compute_firewall.airflow-allow-icmp airflow-allow-icmp
terraform import google_compute_firewall.airflow-allow-prometheus airflow-allow-prometheus
terraform import google_compute_firewall.allow-airflow allow-airflow
terraform import google_compute_firewall.airflow-allow-nfs airflow-allow-nfs
terraform import google_container_cluster.primary uit-cloud-computing/asia-southeast1-a/airflow-cluster
terraform import google_container_node_pool.airflow-core uit-cloud-computing/asia-southeast1-a/airflow-cluster/airflow-core
terraform import google_container_node_pool.airflow-webserver uit-cloud-computing/asia-southeast1-a/airflow-cluster/airflow-webserver
terraform import google_container_node_pool.airflow-celery-workers uit-cloud-computing/asia-southeast1-a/airflow-cluster/airflow-celery-workers
terraform import google_container_node_pool.airflow-k8s-workers uit-cloud-computing/asia-southeast1-a/airflow-cluster/airflow-k8s-workers
terraform import google_service_networking_connection.peering_connection 
