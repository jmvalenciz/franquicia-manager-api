package com.nequi.franquicias.App.sucursal;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * NewSucursal
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdatedSucursal {
	@NotNull
	public UUID id;
	@NotNull
	@Size(min = 3, max = 60)
	public String nombre;
}
