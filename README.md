### Desafío Altrostatus

## Objetivo
Implementar una infraestructura en la nube que levante un sitio de wordpress (offline) con una base de datos para que alguien de marketing sin conocimientos técnicos pueda modificar el contenido del sitio. Generando el sitio en formato estático.

## Requerimientos
- Utilizar Terraform para la creación de la infraestructura.

## Solución
Para la solución de este desafío se utilizó Terraform para la creación de la infraestructura en la nube. Se utilizó GCP como proveedor de servicios en la nube y se crearon los siguientes servicios:
- Cloud Build: Para la creación de la imagen de Docker.
- Artifact Registry: Para almacenar la imagen de Docker.
- Cloud Run: Para la ejecución de la imagen de Docker.
- Cloud Deploy: Para la creación de la infraestructura de Wordpress.
- Cloud SQL: Para la base de datos de Wordpress.
- Cloud DNS: Para el manejo de los DNS.
- Cloud Functions: Para el manejo de los eventos de Cloud SQL. Como por ejemplo, el apagar la instancia de Cloud SQL cuando no se está utilizando.
- Pub/sub + Cloud Functions: Para el envío de un mensaje a Slack comunicando la pubblicación o no de un artículo en el sitio de Wordpress.

La persona de marketing tiene su wordpress en offline. Cuando quiera publicar un artículo, deberá hacerlo desde el sitio de wordpress. Se debe encender entonces iniciar el proceso de Cloud Build, Artifact Registry, Cloud Run y Cloud Deploy, y encendido de la instancia de Cloud SQL. Una vez que el proceso haya terminado, se enviará un mensaje a Slack comunicando la publicación del artículo.

## Estrucutra del proyecto
El proyecto se encuentra dividido en tres repositorios:
- [Infraestructura](https://github.com/siemeris/42-ALT-Terraform)
- [Wordpress Offline](https://github.com/siemeris/WP-GCLOUD-42-ALT)
- [Wordpress Estático](https://github.com/siemeris/42-ALT-WP-Sta)
