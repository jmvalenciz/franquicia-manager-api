DB_HOST=localhost
DB_PASSWORD=root
DB_USER=root
DB_DATABASE=franquicias-manager
DB_PORT=5432

run:
	mvn spring-boot:run

install-deps:
	mvn dependency:resolve

init-db:
	psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) -d $(DB_DATABASE) -f src/main/resources/sql_schemas/init.sql

populate-db:
	psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) -d $(DB_DATABASE) -f src/main/resources/sql_schemas/mock_populate.sql

build-release:
	mvn clean package

