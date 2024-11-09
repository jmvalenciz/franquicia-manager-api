package com.nequi.franquicias.App.franquicia;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Mono;

/**
 * FranquiciaService
 */
@Service
public class FranquiciaService implements IFranquiciaService{
	FranquiciaRepository franquiciaRepository;

	FranquiciaService(FranquiciaRepository franquiciaRepository){
		this.franquiciaRepository = franquiciaRepository;
	}

	@Override
	public Mono<Franquicia> createFranquicia(NewFranquicia newFranquicia) {
		var franquicia = new Franquicia();
		franquicia.nombre = newFranquicia.nombre;
		return this.franquiciaRepository.save(franquicia);
	}

	@Override
	public Mono<Franquicia> getFranquiciaById(UUID id) {
		return this.franquiciaRepository.findById(id)
		.switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Franquicia not found")));
	}

	@Override
	public Mono<Franquicia> getFranquiciaByNombre(String nombre) {
		return this.franquiciaRepository.findByNombre(nombre)
		.switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Franquicia not found")));
	}

	@Override
	public Mono<Franquicia> updateFranquicia(UpdatedFranquicia updatedFranquicia) {
		return this.franquiciaRepository.findById(updatedFranquicia.id)
		.flatMap(f -> {
			f.nombre = updatedFranquicia.nombre;
			return this.franquiciaRepository.save(f);
		}).switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Franquicia not found")));
	}

	@Override
	public Mono<Boolean> exists(UUID id) {
		return this.franquiciaRepository.existsById(id);
	}
}
