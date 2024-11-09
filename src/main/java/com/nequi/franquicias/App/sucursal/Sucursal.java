package com.nequi.franquicias.App.sucursal;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Sucursal
 */
@Data
@Table("sucursales")
@AllArgsConstructor
@NoArgsConstructor
public class Sucursal {
	@Id
	public UUID id;
	public String nombre;
	public UUID franquiciaId;
	@Column("created_at")
	public Timestamp createdAt;
	@Column("update_at")
	public LocalDateTime updatedAt;
}
