package com.nequi.franquicias.App.producto;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * ProductoController
 */
@RestController
@RequestMapping("/producto")
public class ProductoController {
	ProductoService productoService;

	ProductoController(ProductoService productoService){
		this.productoService = productoService;
	}

	@PostMapping("/")
	@ResponseStatus(HttpStatus.CREATED)
	Mono<Producto> createProducto(@Valid @RequestBody NewProducto newProducto){
		return this.productoService.createProducto(newProducto);
	}

	@PutMapping("/stock/{id}")
	Mono<Producto> updateStockByProductId(@PathVariable int id, @RequestBody int stock){
		return this.productoService.updateStock(id, stock);
	}

	@PutMapping("/")
	Mono<Producto> updateProductById(@RequestBody UpdatedProducto updatedProducto){
		return this.productoService.updateProduct(updatedProducto);
	}

	@GetMapping("/max_stock/franquicia/{franquiciaId}")
	Flux<MaxStockPorSucursal> getMaxStockPorSucursalByFranquiciaId(@PathVariable UUID franquiciaId){
		return this.productoService.getMaxStockPorSucursal(franquiciaId);
	}

	@GetMapping("/sucursal/{sucursalId}")
	Flux<Producto> getProductosBySucursalId(@PathVariable UUID sucursalId){
		return this.productoService.getProductosBySucursalId(sucursalId);
	}

	@DeleteMapping("/{id}")
	Mono<Producto> deleteProductoById(@PathVariable Integer id){
		return this.productoService.deleteProductoById(id);
	}

	@GetMapping("/{id}")
	Mono<Producto> getProducto(@PathVariable int id){
		return this.productoService.getProductoById(id);
	}


}
