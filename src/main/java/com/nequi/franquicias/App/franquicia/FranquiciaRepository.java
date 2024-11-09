package com.nequi.franquicias.App.franquicia;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;

import reactor.core.publisher.Mono;

/**
 * FranquiciaRepository
 */
public interface FranquiciaRepository extends ReactiveCrudRepository<Franquicia, UUID>{
	Mono<Franquicia> findByNombre(String name);
}
