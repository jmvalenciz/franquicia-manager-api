package com.nequi.franquicias.App.producto;

import java.util.UUID;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Producto
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewProducto {
	@NotNull
	@Size(min=3,max=60)
	public String nombre;
	@Min(0)
	public int stock;
	@NotNull
	public UUID sucursalId;
}
