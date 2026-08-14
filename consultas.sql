-- =========================================================================
-- PROYECTO: Análisis Estratégico de Clientes y Ventas - E-commerce UK
-- AUTOR: Fredy Ricardo Toro Castañeda
-- ENFOQUE: Soporte Técnico e Integridad Metodológica (Híbrido SQL / Power BI)
-- =========================================================================

-- -------------------------------------------------------------------------
-- PASO 1: Diagnóstico de Calidad de Datos e Impacto de Cancelaciones
-- Objetivo: Identificar la proporción de órdenes canceladas por falta de stock.
-- -------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Quantity < 0 OR TransactionNo LIKE 'C%' THEN 'Cancelaciones / Devoluciones'
        ELSE 'Ventas Efectivas'
    END AS Estado_Transaccion,
    COUNT(*) AS Cantidad_Registros,
    ROUND(COUNT(*) * 100.0 / 536350, 2) AS Porcentaje_Del_Total
FROM ecommerce_limpio
GROUP BY 1;


-- -------------------------------------------------------------------------
-- PASO 2: Tendencia de Ventas Mensuales (Eje Temporal)
-- Objetivo: Analizar la estacionalidad comercial excluyendo registros corruptos
--           (Mes '00') y cancelaciones.
-- -------------------------------------------------------------------------
SELECT 
    SUBSTR(Date, -4) AS Anio,
    PRINTF('%02d', CAST(REPLACE(
        CASE 
            WHEN SUBSTR(Date, -7, 1) = '/' THEN SUBSTR(Date, -6, 2)
            ELSE SUBSTR(Date, -6, 1)
        END, '/', '') AS INTEGER)) AS Mes_Limpio,
    COUNT(DISTINCT TransactionNo) AS Total_Pedidos_Efectivos,
    ROUND(SUM(Quantity * Price), 2) AS Ingresos_Totales_GBP
FROM ecommerce_limpio
WHERE Quantity > 0 
  AND TransactionNo NOT LIKE 'C%'
  AND SUBSTR(Date, -6, 2) != '00' -- Exclusión de anomalías de sistema
GROUP BY Anio, Mes_Limpio
ORDER BY Anio ASC, Mes_Limpio ASC;


-- -------------------------------------------------------------------------
-- PASO 3: Análisis de Rotación de Inventario (Top 10 Productos)
-- Objetivo: Identificar los artículos estrella basados en unidades vendidas.
-- -------------------------------------------------------------------------
SELECT 
    ProductName,
    SUM(Quantity) AS Unidades_Totales_Vendidas
FROM ecommerce_limpio
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY ProductName
ORDER BY Unidades_Totales_Vendidas DESC
LIMIT 10;


-- -------------------------------------------------------------------------
-- PASO 4: Estructura de Ingresos por Segmento de Cliente (B2B vs B2C)
-- Objetivo: Clasificar clientes según la regla de negocio (Mayorista >= 50 unidades).
-- -------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Quantity >= 50 THEN 'Cliente Mayorista (B2B)'
        ELSE 'Cliente Minorista (B2C)'
    END AS Segmento_Cliente,
    ROUND(SUM(Quantity * Price), 2) AS Suma_Venta_Total
FROM ecommerce_limpio
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY 1;

