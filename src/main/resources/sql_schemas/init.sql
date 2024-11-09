CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- Function para actualizar updatedAt cuando se actualice una fila
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS franquicias(
	id UUID DEFAULT uuid_generate_v4(),
	nombre VARCHAR(60) NOT NULL UNIQUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id)
);
CREATE INDEX idx_franquicias_nombre ON franquicias(nombre);
CREATE TRIGGER set_franquicia_updated_at
BEFORE UPDATE ON franquicias
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();


CREATE TABLE IF NOT EXISTS sucursales(
	id UUID DEFAULT uuid_generate_v4(),
	nombre VARCHAR(60) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	franquicia_id UUID NOT NULL,
	UNIQUE (nombre, franquicia_id),
	FOREIGN KEY (franquicia_id) REFERENCES franquicias(id),
	PRIMARY KEY (id)
);
CREATE INDEX idx_sucursales_franquicia ON sucursales(franquicia_id);
CREATE INDEX idx_sucursales_nombre_franquicia ON sucursales(franquicia_id, nombre);
CREATE TRIGGER set_sucursal_updated_at
BEFORE UPDATE ON sucursales
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE IF NOT EXISTS productos(
	id SERIAL,
	nombre VARCHAR(60) NOT NULL,
	stock INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	sucursal_id UUID NOT NULL,
	UNIQUE (nombre, sucursal_id),
	FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
);
CREATE INDEX idx_productos_sucursal ON productos(sucursal_id);
CREATE INDEX idx_productos_nombre ON productos(nombre);
-- Útil para crear alertas cuando hay bajo stock o no hay stock de un producto
CREATE INDEX idx_productos_stock ON productos(stock);
CREATE INDEX idx_productos_nombre_sucursal ON productos(sucursal_id, nombre);
CREATE TRIGGER set_producto_updated_at
BEFORE UPDATE ON productos
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

