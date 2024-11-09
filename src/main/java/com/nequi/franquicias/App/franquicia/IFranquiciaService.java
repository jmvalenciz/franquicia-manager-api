package com.nequi.franquicias.App.franquicia;

import java.util.UUID;

import reactor.core.publisher.Mono;

/**
 * IFranquiciaService
 */
public interface IFranquiciaService {
	Mono<Franquicia> createFranquicia(NewFranquicia newFranquicia);
	Mono<Franquicia> getFranquiciaById(UUID id);
	Mono<Franquicia> getFranquiciaByNombre(String nombre);
	Mono<Franquicia> updateFranquicia(UpdatedFranquicia updateFranquicia);
	Mono<Boolean> exists(UUID id);
}
