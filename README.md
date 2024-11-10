# Franquicias Manager API

Gestor de franquicias

## Desarrollo local

Para el desarrollo local, se necesitan las siguientes herramientas:

- Docker
- Docker Compose (para abstraer la configuración de PostgreSQL)
- Maven
- Java EE 21
- Make (Opcional pero se usará para automatizar algunos comandos)

Para iniciar el proyecto, primero vamos a obtener las dependencias:

```sh
make install-deps
```

Luego, vamos a iniciar la base de datos, a crear las tablas y a llenar la base de datos con datos dummy:

```sh
# se puede usar docker-compose
# si la versión de docker instalada no contiene este subcomando
dokcer compose up -d
# crear las tablas
make init-db
# llenar la base de datos con datos dummy
make populate-db
```

Y finalmente, iniciamos el proyecto:

```sh
make run
```

## Despliegue

Para realizar el despliegue, lo primero que vamos a hacer es asegurarnos de tener las dependencias necesarias instalasdas:

- aws-cli
- terraform

Lugo vamos a movernos a la carpeta `./infraestructura/` que es en donde está el proyecto de terraform
y ejecutamos el siguiente comando para inicializar el proyecto de forma local y traer las dependencias:

```sh
terraform init
```

Después vamos a crear una clave ssh para configurar las instancias:

```sh
ssh-keygen -t rsa -b 4096 -f <SSH_KEY_PATH>
```

Luego de esto, vamos a configurar el archivo `terraform.tfvars` con las variables sensibles como lo son la contraseña de la base de datos y la ruta de la clave ssh:

```terraform
db_password="<DB_PASSWORD>"
ssh_key_path="<SSH_PUBLIC_KEY_PATH>"
```

y finalmente, validamos el plan de terraform y desplehamos

```sh
terraform plan
terraform apply -auto-approve
```

y como output, vamos a obtener la ip publica de la instancia del api y de la instancia de la base de datos:

```sh
api-instance_ip = "44.193.4.178"
db-instance_ip = "100.26.150.90"
```

