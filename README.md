# analisis-estrategia-cliente-ecommerce
Análisis estratégico de datos transaccionales de comercio electrónico para la segmentación de clientes, optimización de inventario y retención de usuarios mediante SQL.

# 📈 Análisis Estratégico de Clientes y Ventas - E-commerce UK

## 📌 1. Contexto del Negocio
Este proyecto analiza un conjunto de datos transaccionales de una tienda minorista en línea con sede en el Reino Unido. La empresa vende regalos y artículos para el hogar a nivel global, atendiendo tanto a consumidores finales (B2C) como a pequeñas empresas que compran al por mayor (B2B).

* **Volumen de datos:** 536,350 transacciones analizadas.
* **Periodo:** 1 año de historial operativo.

---

## ⚠️ 2. El Reto de Negocio (Problema)
El equipo de estrategia comercial identifica dos problemas críticos:
1. Se desconoce el impacto financiero real de las cancelaciones de pedidos (provocadas por quiebres de stock).
2. No existe una segmentación clara entre clientes comunes y compradores mayoristas, lo que impide diseñar campañas de marketing eficientes.

---

## 🔎 3. Objetivos del Análisis
Utilizando **SQL**, se dio respuesta a las siguientes preguntas clave de la gerencia:
* ¿Cuál es la tendencia de ventas mensual y cómo afectan las cancelaciones?
* ¿Cuáles son los productos más vendidos para optimizar el inventario?
* ¿Cómo segmentar a los clientes según su volumen de compra y rentabilidad?

---

## 📊 4. Hallazgos y Soluciones Técnicas (SQL)

### A. Diagnóstico de Calidad de Datos e Impacto de Cancelaciones
Antes de evaluar los ingresos, se realizó un control de calidad sobre los **536,350 registros** del dataset. Se ejecutó una consulta de agregación y conteo que arrojó los siguientes resultados exactos:

*   **Ventas Efectivas:** 527,765 registros (**98.40%** del total).
*   **Cancelaciones / Devoluciones:** 8,585 registros (**1.60%** del total).

Se ejecutó la siguiente consulta para medir la proporción exacta de este problema:

```sql
SELECT 
    CASE 
        WHEN Quantity < 0 OR TransactionNo LIKE 'C%' THEN 'Cancelaciones / Devoluciones'
        ELSE 'Ventas Efectivas'
    END AS Estado_Transaccion,
    COUNT(*) AS Cantidad_Registros,
    ROUND(COUNT(*) * 100.0 / 536350, 2) AS Porcentaje_Del_Total
FROM Sales_Transaction_v stv
GROUP BY 1;
```
---

### B. Limpieza de Datos y Gestión de Cancelaciones
Se identificó que las transacciones que inician con 'C' o tienen cantidades negativas representan pedidos cancelados por falta de stock. 

```sql
-- Consulta para medir el impacto de las cancelaciones
SELECT 
    COUNT(CASE WHEN Cantidad < 0 THEN 1 END) AS Total_Cancelaciones,
    SUM(CASE WHEN Cantidad < 0 THEN (Cantidad * Precio) END) AS Dinero_Perdido_GBP
FROM ecommerce_table;
```

### C. Segmentación de Clientes (B2B vs B2C)
Para separar a los clientes minoristas de las empresas, se aplicó una lógica de agregación por volumen:

```sql
-- Segmentación estratégica de clientes
SELECT 
    CustomerNo,
    SUM(Cantidad * Precio) AS Gasto_Total,
    AVG(Cantidad) AS Promedio_Productos_Por_Pedido,
    CASE 
        WHEN AVG(Cantidad) >= 50 THEN 'Cliente Mayorista (B2B)'
        ELSE 'Cliente Minorista (B2C)'
    END AS Segmento_Cliente
FROM ecommerce_table
WHERE Cantidad > 0
GROUP BY CustomerNo
ORDER BY Gasto_Total DESC;
```

---

## 💡 5. Recomendaciones Estratégicas para la Gerencia

**Mitigación de Quiebres de Stock:** Aunque el **1.60%** de cancelaciones parece un margen controlado, representa **8,585 órdenes insatisfechas** en un año. Tomando en cuenta que el contexto del negocio indica que los clientes cancelan porque exigen recibir todo su pedido junto, este porcentaje impacta directamente la fidelidad del cliente (*LTV*). Se recomienda implementar un sistema de alertas de inventario mínimo en los productos con mayor frecuencia de compra para anticipar el reabastecimiento antes de llegar a cero.
* **Plan de Retención B2B:** El segmento mayorista genera el X% de los ingresos. Se recomienda diseñar un programa de fidelización con descuentos por volumen acumulado.
* **Control de Stock Crítico:** Los productos [Mencionar Top 3 productos más vendidos] concentran la mayor demanda. Se debe automatizar una alerta de inventario mínimo para evitar cancelaciones por falta de existencias.
* **Estrategia Logística:** El 80% de los compradores están concentrados en el Reino Unido, pero los países de Europa presentan un ticket promedio más alto. Se sugiere pautar publicidad digital segmentada en esas regiones con envíos gratis en compras superiores a £100.

