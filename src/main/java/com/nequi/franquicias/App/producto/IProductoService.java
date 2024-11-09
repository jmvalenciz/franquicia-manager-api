package com.nequi.franquicias.App.producto;

import java.util.UUID;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * IProductoService
 */
public interface IProductoService {
	Mono<Producto> createProducto(NewProducto newProducto);
	Mono<Producto> getProductoById(int id);
	Flux<Producto> getProductosBySucursalId(UUID sucursalId);
	Flux<MaxStockPorSucursal> getMaxStockPorSucursal(UUID franquicia);
	Mono<Producto> deleteProductoById(int id);
	Mono<Producto> updateStock(int id, int stock);
	Mono<Producto> updateProduct(UpdatedProducto updatedProducto);
}
