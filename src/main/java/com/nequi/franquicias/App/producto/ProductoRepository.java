package com.nequi.franquicias.App.producto;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * ProductoRepository
 */
public interface ProductoRepository extends ReactiveCrudRepository<Producto, Integer>{
	Mono<Producto> findByNombre(String nombre);
	Flux<Producto> findBySucursalId(UUID sucursalId);
	/* SELECT su.nombre AS nombre_sucursal, su.id AS id_sucursal, pr.nombre AS nombre_producto, pr.id AS id_producto, pr.stock AS producto_stock
	FROM sucursales su
	INNER JOIN (
		SELECT su.id as sucursal_id, MAX(pr.stock) as stock FROM productos pr
		INNER JOIN sucursales su ON su.id = pr.sucursal_id AND su.franquicia_id = :franquicia_id
		GROUP BY su.id
	) stock_table
	ON su.id = stock_table.sucursal_id
	INNER JOIN productos pr
	ON pr.sucursal_id = su.id AND stock_table.stock = pr.stock; */
	@Query("SELECT su.nombre AS nombre_sucursal, su.id AS id_sucursal, pr.nombre AS nombre_producto, pr.id AS id_producto, pr.stock AS producto_stock FROM sucursales su INNER JOIN ( SELECT su.id as sucursal_id, MAX(pr.stock) as stock FROM productos pr INNER JOIN sucursales su ON su.id = pr.sucursal_id AND su.franquicia_id = $1 GROUP BY su.id) stock_table ON su.id = stock_table.sucursal_id INNER JOIN productos pr ON pr.sucursal_id = su.id AND stock_table.stock = pr.stock;")
	Flux<MaxStockPorSucursal> findMaxStockPorSucursalByFranquiciaId(UUID franquiciaId);
	Mono<Producto> deleteById(int id);
}
