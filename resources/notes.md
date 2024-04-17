gcloud config set project [ID_DEL_PROYECTO]

gcloud config get-value project

gcloud services enable \
compute.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com \
sqladmin.googleapis.com \
run.googleapis.com \
serviceusage.googleapis.com \
cloudresourcemanager.googleapis.com \
vpcaccess.googleapis.com \
servicenetworking.googleapis.com \
clouddeploy.googleapis.com \
secretmanager.googleapis.com \
dns.googleapis.com \ 
cloudfunctions.googleapis.com \
cloudscheduler.googleapis.com \



### Eliminar recursos:
gcloud artifacts repositories delete wp-repo --location=europe-southwest1

gcloud compute networks subnets delete my-subnet --region=europe-southwest1
gcloud compute networks delete my-vpc

gcloud builds triggers delete github-trigger



### Crear una conexión de servicios privados en tu red virtual
gcloud compute networks vpc-access connectors create my-connector --network=my-vpc


### Establecer un peering de VPC con la red de servicios de red de Google
gcloud services vpc-peerings connect --service=servicenetworking.googleapis.com --network=my-vpc --ranges=10.0.0.0/24



### Identificar el nombre de la red de servicios de red de Google
gcloud compute networks list
gcloud services vpc-peerings list



### Github, evitar introducir contraseña cada vez que se haga un pull

git config --global credential.helper store


### Para sacar un esquema de la infraestructura
gcloud compute networks subnets describe my-subnet --region=europe-southwest1 --format=json > my-subnet.json
gcloud compute networks describe my-vpc --format=json > my-vpc.json
gcloud sql instances describe my-instance --format=json > my-instance.json
gcloud run services describe my-service --platform=managed --region=europe-southwest1 --format=json > my-service.json
gcloud compute networks vpc-access connectors describe my-connector --region=europe-southwest1 --format=json > my-connector.json
gcloud services vpc-peerings describe my-vpc --format=json > my-vpc-peering.json
gcloud artifacts repositories describe my-repo --location=europe-southwest1 --format=json > my-repo.json
gcloud builds triggers describe github-trigger --format=json > github-trigger.json

### Gráfico visual de la infra
terraform graph | dot -Tsvg > graph.svg

