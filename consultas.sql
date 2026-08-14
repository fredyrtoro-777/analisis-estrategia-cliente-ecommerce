-- =========================================================================
-- PROYECTO: Soporte Técnico Analítico - E-commerce UK
-- AUTOR: Fredy Ricardo Toro Castañeda
-- ENFOQUE: Homologación de KPIs Financieros y Operativos (SQL vs Power BI)
-- NOTA: Consultas ejecutadas sobre la base de datos depurada y estandarizada 
--       mediante el proceso ETL de Power BI (Power Query).
-- =========================================================================

-- -------------------------------------------------------------------------
-- 0. AUDITORÍA DE INGESTA MASIVA (Chequeo Rápido)
-- Objetivo: Confirmar que el motor de SQL absorbió el 100% de las filas 
--           del archivo CSV exportado desde Power BI, sin recortes ni pérdidas.
-- -------------------------------------------------------------------------
SELECT COUNT(*) AS Total_Filas_Cargadas 
FROM ecommerce_data_clean;


-- -------------------------------------------------------------------------
-- 1. CONTROL DE CALIDAD Y CUADRE FINANCIERO (Métrica de Validación)
-- Objetivo: Verificar la integridad de la carga frente a las tarjetas del Dashboard.
--           Garantiza el match exacto con los ingresos de £62,965,974.34.
-- -------------------------------------------------------------------------
SELECT 
    COUNT(*) AS Total_Filas_Efectivas,
    COUNT(DISTINCT TransactionNo) AS Total_Pedidos_Unicos,
    ROUND(SUM(Quantity * Price), 2) AS Ingresos_Totales_GBP
FROM ecommerce_data_clean
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%';


-- -------------------------------------------------------------------------
-- 2. TENDENCIA DE VENTAS MENSUALES (Eje Temporal) - REPARACIÓN DE ORDEN
-- Objetivo: Evaluar la estacionalidad comercial basándose en la fecha limpia.
-- FORMATO: Visualización estructurada como MM-AAAA (ej. 12-2018).
-- SOLUCIÓN: Se aplica TRIM para eliminar espacios ocultos al final del texto 
--           y asegurar que el año 2018 se posicione en la primera fila.
-- -------------------------------------------------------------------------
SELECT 
    SUBSTR(TRIM(Date), 4, 2) || '-' || SUBSTR(TRIM(Date), 7, 4) AS Mes_Periodo, 
    COUNT(DISTINCT TransactionNo) AS Total_Pedidos_Efectivos,
    ROUND(SUM(Quantity * Price), 2) AS Ingresos_Mensuales_GBP
FROM ecommerce_data_clean
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY SUBSTR(TRIM(Date), 7, 4), SUBSTR(TRIM(Date), 4, 2)
ORDER BY CAST(SUBSTR(TRIM(Date), 7, 4) AS INTEGER) ASC, CAST(SUBSTR(TRIM(Date), 4, 2) AS INTEGER) ASC;


-- -------------------------------------------------------------------------
-- 3. ROTACIÓN DE INVENTARIO (Top 10 Productos Estrella)
-- Objetivo: Identificar los artículos con mayor demanda acumulada.
-- -------------------------------------------------------------------------
SELECT 
    ProductName,
    SUM(Quantity) AS Unidades_Totales_Vendidas
FROM ecommerce_data_clean
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY ProductName
ORDER BY Unidades_Totales_Vendidas DESC
LIMIT 10;


-- -------------------------------------------------------------------------
-- 4. ESTRUCTURA DE INGRESOS POR SEGMENTO DE CLIENTE (B2B vs B2C)
-- Objetivo: Cuantificar la inyección de capital según la regla de volumen DAX.
-- -------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Quantity >= 50 THEN 'Cliente Mayorista (B2B)'
        ELSE 'Cliente Minorista (B2C)'
    END AS Segmento_Cliente,
    ROUND(SUM(Quantity * Price), 2) AS Suma_Venta_Total_GBP,
    ROUND(SUM(Quantity * Price) * 100.0 / 62965974.34, 2) AS Porcentaje_Contribucion
FROM ecommerce_data_clean
WHERE Quantity > 0 AND TransactionNo NOT LIKE 'C%'
GROUP BY 1;

