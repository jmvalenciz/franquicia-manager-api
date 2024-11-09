package com.nequi.franquicias.App.franquicia;

import java.sql.Timestamp;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Franquicia
 */
@Data
@Table("franquicias")
@NoArgsConstructor
@AllArgsConstructor
public class Franquicia {
	@Id
	public UUID id;
	public String nombre;
	@Column("created_at")
	public Timestamp createdAt;
	@Column("updated_at")
	public Timestamp updatedAt;
}
