package com.nequi.franquicias.App.sucursal;

import java.util.UUID;

import reactor.core.publisher.Mono;

/**
 * ISucursalService
 */
public interface ISucursalService {
	Mono<Sucursal> createSucursal(NewSucursal newSucursal);
	Mono<Sucursal> getSucursalByNombre(String nombre);
	Mono<Sucursal> getSucursalById(UUID id);
	Mono<Sucursal> updateSucursal(UpdatedSucursal updateSucursal);
	Mono<Boolean> exists(UUID id);
}
