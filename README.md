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

Luego, vamos a iniciar la base de datos y a cargar las tablas:

```sh
# se puede usar docker-compose
# si la versión de docker instalada no contiene este subcomando
dokcer compose up -d
make init-db
```

Y finalmente, iniciamos el proyecto:

```sh
make run
```
