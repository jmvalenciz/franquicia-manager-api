package com.nequi.franquicias.App.franquicia;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * NewFranquicia
 */
@Data
public class NewFranquicia {
	@NotNull
	@Size(min = 3, max = 60)
	public String nombre;
}
