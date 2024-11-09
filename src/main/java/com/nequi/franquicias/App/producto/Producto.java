package com.nequi.franquicias.App.producto;

import java.sql.Timestamp;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Producto
 */
@Data
@Table("productos")
@NoArgsConstructor
@AllArgsConstructor
public class Producto {
	@Id
	public int id;
	public String nombre;
	public int stock;
	public UUID sucursalId;
	@Column("created_at")
	public Timestamp createdAt;
	@Column("updated_at")
	public Timestamp updatedAt;
}
