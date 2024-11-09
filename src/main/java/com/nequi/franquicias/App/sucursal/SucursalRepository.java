package com.nequi.franquicias.App.sucursal;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.Modifying;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;

import reactor.core.publisher.Mono;

/**
 * SucursalRepository
 */
public interface SucursalRepository extends ReactiveCrudRepository<Sucursal, UUID>{
	@Query("SELECT * FROM sucursales WHERE nombre = :nombre")
	Mono<Sucursal> findByNombre(String nombre);
	@Modifying
	@Query("UPDATE sucursales SET nombre=$2 WHERE id=$1 RETURNING *")
	Mono<Sucursal> update(UUID id, String nombre);
}
