package com.nequi.franquicias.App.producto;

import java.util.UUID;

import org.springframework.data.relational.core.mapping.Column;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * MaxStockPorSucursal
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MaxStockPorSucursal {
    @Column("id_sucursal")
    @JsonProperty("id_sucursal")
    UUID sucursalId;

    @Column("nombre_sucursal")
    @JsonProperty("nombre_sucursal")
    String nombreSucursal;

    @Column("id_producto")
    @JsonProperty("id_producto")
    int productoId;

    @Column("nombre_producto")
    @JsonProperty("nombre_producto")
    String nombreProducto;

    @Column("producto_stock")
    @JsonProperty("producto_stock")
    int productoStock;
}
