##Configurar una zona DNS Privada
## Creo una zona DNS privada que estará asociada con la red VPC. 
## Esto garantiza que solo los recursos dentro de la red VPC 
## puedan resolver los nombres DNS configurados en esta zona.
resource "google_dns_managed_zone" "private_zone" {
  name        = "my-private-zone"
  dns_name    = "cloudsql.internal."
  description = "Private DNS zone for Cloud SQL"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.private_network.self_link
    }
  }
}

## Creo un registro DNS para la instancia de Cloud SQL
# Hay que añadir un registro DNS que apunte al nombre de la instancia de Cloud SQL. 
# Utilizo un registro A que se resolverá a la dirección IP privada de la instancia de Cloud SQL. 
# Para que esto funcione correctamente, hay que asegurarse de que la instancia de Cloud SQL ya haya sido creada 
# y que tenga una dirección IP privada asignada.
resource "google_dns_record_set" "cloud_sql_dns" {
  name         = "db.cloudsql.internal."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private_zone.name
  rrdatas      = [google_sql_database_instance.mysql_instance.private_ip_address]
}


