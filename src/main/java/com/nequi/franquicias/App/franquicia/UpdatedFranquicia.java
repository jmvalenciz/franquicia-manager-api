package com.nequi.franquicias.App.franquicia;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * UpdateFranquicia
 */
@Data
public class UpdatedFranquicia {
	@NotNull
	public UUID id;
	@NotNull
	@Size(min = 3, max = 60)
	public String nombre;
}
