package com.nequi.franquicias.App.franquicia;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import reactor.core.publisher.Mono;

/**
 * FranquiciaController
 */
@RestController
@RequestMapping("/franquicia")
public class FranquiciaController {

	FranquiciaService franquiciaService;

	FranquiciaController(FranquiciaService franquiciaService){
		this.franquiciaService = franquiciaService;
	}

	@PostMapping("/")
	@ResponseStatus(HttpStatus.CREATED)
	Mono<Franquicia> createFranquicia(@Valid @RequestBody NewFranquicia newFranquicia){
		return this.franquiciaService.createFranquicia(newFranquicia);
	}

	@GetMapping("/{id}")
	Mono<Franquicia> getFranquiciaById(@PathVariable UUID id){
		return this.franquiciaService.getFranquiciaById(id);
	}

	@GetMapping("/nombre/{nombre}")
	Mono<Franquicia> getFranquiciaByNombre(@PathVariable String nombre){
		return this.franquiciaService.getFranquiciaByNombre(nombre);
	}

	@PutMapping("/")
	Mono<Franquicia> updateFranquicia(@Valid @RequestBody UpdatedFranquicia updatedFranquicia){
		return this.franquiciaService.updateFranquicia(updatedFranquicia);
	}
}
