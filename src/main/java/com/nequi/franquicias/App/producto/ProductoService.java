package com.nequi.franquicias.App.producto;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.result.method.annotation.ResponseEntityExceptionHandler;
import org.springframework.web.server.ResponseStatusException;

import com.nequi.franquicias.App.sucursal.SucursalService;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * ProductoService
 */
@Service
public class ProductoService implements IProductoService{
	ProductoRepository productoRepository;
	SucursalService sucursalService;

	ProductoService(ProductoRepository productoRepository, SucursalService sucursalService){
		this.productoRepository = productoRepository;
		this.sucursalService = sucursalService;
	}

	@Override
	public Mono<Producto> createProducto(NewProducto newProducto){
		return this.sucursalService.exists(newProducto.sucursalId)
		.flatMap(sucursalExists -> {
			if(!sucursalExists){
				return Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND,"Sucursal not found"));
			}
			var producto = new Producto();
			producto.nombre = newProducto.nombre;
			producto.stock = newProducto.stock;
			producto.sucursalId = newProducto.sucursalId;
			return this.productoRepository.save(producto);
		});
	}

	@Override
	public Mono<Producto> getProductoById(int id) {
		return this.productoRepository.findById(id);
	}

	@Override
	public Flux<Producto> getProductosBySucursalId(UUID sucursalId) {
		return this.productoRepository.findBySucursalId(sucursalId);
	}

	@Override
	public Flux<MaxStockPorSucursal> getMaxStockPorSucursal(UUID franquiciaId) {
		return this.productoRepository.findMaxStockPorSucursalByFranquiciaId(franquiciaId);
	}

	@Override
	public Mono<Producto> deleteProductoById(int id) {
		return this.productoRepository.deleteById(id);
	}

	@Override
	public Mono<Producto> updateStock(int id, int stock) {
		return this.productoRepository.findById(id)
		.flatMap(pr -> {
			pr.stock = stock;
			return this.productoRepository.save(pr);
		}).switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND,"Producto not found")));
	}

	@Override
	public Mono<Producto> updateProduct(UpdatedProducto updatedProducto) {
		return this.productoRepository.findById(updatedProducto.id)
		.flatMap(pr -> {
			if(updatedProducto.nombre == null){
				return Mono.just(pr);
			}
			pr.nombre = updatedProducto.nombre;
			return this.productoRepository.save(pr);
		}).switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND,"Producto not found")));
	}
}
