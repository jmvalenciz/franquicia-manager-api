package com.nequi.franquicias.App.sucursal;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.nequi.franquicias.App.franquicia.FranquiciaService;

import reactor.core.publisher.Mono;

/**
 * SucursalService
 */
@Service
public class SucursalService implements ISucursalService{
	SucursalRepository sucursalRepository;
	FranquiciaService franquiciaService;

	SucursalService(SucursalRepository sucursalRepository, FranquiciaService franquiciaService){
		this.sucursalRepository = sucursalRepository;
		this.franquiciaService = franquiciaService;
	}

	@Override
	public Mono<Sucursal> createSucursal(NewSucursal newSucursal){
		return this.franquiciaService.exists(newSucursal.franquiciaId)
		.flatMap(franquiciaExists -> {
			if(!franquiciaExists){
				return Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND,"Franquicia not found"));
			}
			var sucursal = new Sucursal();
			sucursal.nombre = newSucursal.nombre;
			sucursal.franquiciaId = newSucursal.franquiciaId;
			return this.sucursalRepository.save(sucursal);
		});
	}

	@Override
	public Mono<Sucursal> getSucursalByNombre(String nombre) {
		return this.sucursalRepository.findByNombre(nombre)
		.switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal not found")));
	}

	@Override
	public Mono<Sucursal> getSucursalById(UUID id) {
		return this.sucursalRepository.findById(id)
		.switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal not found")));
	}

	@Override
	public Mono<Sucursal> updateSucursal(UpdatedSucursal updatedSucursal) {
		return this.sucursalRepository.findById(updatedSucursal.id)
		.flatMap(s ->{
			s.nombre = updatedSucursal.nombre;
			s.updatedAt = LocalDateTime.now();
			return this.sucursalRepository.update(s.id, s.nombre);
		}).switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal not found")));
	}

	@Override
	public Mono<Boolean> exists(UUID id) {
		return this.sucursalRepository.existsById(id);
	}

}
