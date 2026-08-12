-- =========================================================================
-- PROYECTO: Análisis Estratégico de Clientes y Ventas - E-commerce UK
-- AUTOR: Fredy Ricardo Toro Castañeda
-- OBJETIVO: Resolver preguntas clave de negocio y segmentación de clientes
-- =========================================================================

-- -------------------------------------------------------------------------
-- PREGUNTA 1: ¿Cuál fue la tendencia de ventas a lo largo de los meses?
-- Objetivo: Identificar la estacionalidad y el volumen de ingresos reales.
-- NOTA: Se excluyen las cantidades negativas para analizar solo ventas efectivas.
-- -------------------------------------------------------------------------
SELECT 
    DATE_TRUNC('month', Fecha) AS Mes, -- Agrupa las fechas por el primer día de cada mes
    COUNT(DISTINCT TransactionNo) AS Total_Pedidos,
    SUM(Cantidad * Precio) AS Ingresos_Totales_GBP
FROM ecommerce_table
WHERE Cantidad > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY 1
ORDER BY Mes ASC;


-- -------------------------------------------------------------------------
-- PREGUNTA 2: ¿Cuáles son los productos que se compran con mayor frecuencia?
-- Objetivo: Identificar los artículos "estrella" para optimizar el inventario.
-- -------------------------------------------------------------------------
SELECT 
    Producto,
    COUNT(DISTINCT TransactionNo) AS Veces_Comprado,
    SUM(Cantidad) AS Unidades_Totales_Vendidas
FROM ecommerce_table
WHERE Cantidad > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY Producto
ORDER BY Unidades_Totales_Vendidas DESC
LIMIT 10;


-- -------------------------------------------------------------------------
-- PREGUNTA 3: ¿Cuántos productos compra el cliente en cada transacción?
-- Objetivo: Entender el volumen del carrito de compras promedio (Ticket Promedio).
-- -------------------------------------------------------------------------
SELECT 
    TransactionNo,
    CustomerNo,
    SUM(Cantidad) AS Total_Productos_En_Pedido,
    SUM(Cantidad * Precio) AS Valor_Total_Pedido_GBP
FROM ecommerce_table
WHERE Cantidad > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY TransactionNo, CustomerNo
ORDER BY Total_Productos_En_Pedido DESC;


-- -------------------------------------------------------------------------
-- PREGUNTA 4: ¿Cuáles son los segmentos de clientes más rentables?
-- Objetivo: Separar clientes minoristas (B2C) de los mayoristas (B2B) 
--           según su volumen promedio de compra.
-- -------------------------------------------------------------------------
SELECT 
    CustomerNo,
    País,
    SUM(Cantidad * Precio) AS Gasto_Total_GBP,
    COUNT(DISTINCT TransactionNo) AS Total_Visitas,
    AVG(Cantidad) AS Promedio_Unidades_Por_Pedido,
    CASE 
        WHEN AVG(Cantidad) >= 50 THEN 'Cliente Mayorista (B2B)'
        ELSE 'Cliente Minorista (B2C)'
    END AS Segmento_Estratégico
FROM ecommerce_table
WHERE Cantidad > 0 AND CustomerNo IS NOT NULL
GROUP BY CustomerNo, País
ORDER BY Gasto_Total_GBP DESC;


-- -------------------------------------------------------------------------
-- ANÁLISIS EXTRA: Impacto Financiero de las Cancelaciones (Falta de Stock)
-- Objetivo: Medir cuánto dinero se dejó de percibir debido a las cancelaciones.
-- -------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT TransactionNo) AS Total_Pedidos_Cancelados,
    SUM(ABS(Cantidad) * Precio) AS Ingresos_Perdidos_GBP
FROM ecommerce_table
WHERE Cantidad < 0 OR TransactionNo LIKE 'C%';

