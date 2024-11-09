package com.nequi.franquicias.App.producto;

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
public class UpdatedProducto {
	@NotNull
	@Min(0)
	public int id;
	@Size(min = 3, max = 60)
	public String nombre;
}
