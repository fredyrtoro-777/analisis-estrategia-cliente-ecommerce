# 📈 Optimización Comercial y Segmentación de Clientes: Análisis de E-commerce UK

## 📌 1. Contexto del Negocio
Este proyecto analiza un conjunto de datos transaccionales de una tienda minorista en línea con sede en el Reino Unido. La empresa vende regalos y artículos para el hogar a nivel global, atendiendo tanto a consumidores finales (B2C) como a pequeñas empresas que compran al por mayor (B2B).

* **Volumen de datos:** 536,350 transacciones operativas analizadas.
* **Periodo de análisis:** Historial transaccional de 1 año.

---

## ⚠️ 2. El Reto de Negocio (Problema)
El equipo de estrategia comercial identificó que los datos crudos presentaban inconsistencias críticas que bloqueaban la toma de decisiones:
1. **Configuración Regional:** Precios indexados con punto decimal (`.`) y fechas en formato norteamericano (`MM/DD/AAAA`) con longitudes de dígitos variables.
2. **Impacto de Cancelaciones:** Pérdida de ingresos provocada por pedidos cancelados debido a quiebres de stock.
3. **Falta de Segmentación:** Incapacidad de diferenciar el valor financiero de los clientes comunes frente a los compradores mayoristas.

---

## 🔎 3. Objetivos del Análisis
Utilizando **SQL y Power BI**, se dio respuesta a las siguientes preguntas clave de la gerencia:
* ¿Cuál es la tendencia de ventas mensual y cómo afectan las cancelaciones?
* ¿Cuáles son los productos más vendidos para optimizar el inventario?
* ¿Cómo segmentar a los clientes según su volumen de compra y rentabilidad?
* ¿Cuántos productos compra el cliente en promedio en cada transacción?

## 🛠️ 4. Arquitectura de la Solución (Metodología ETL)
Para garantizar la escalabilidad y automatización del negocio, y considerando la magnitud de registros, se estructuró un flujo de **Extracción, Transformación y Carga (ETL)** nativo en **Power BI Desktop (Power Query)**:

1. **Ingesta:** Conexión directa al archivo CSV crudo de 536,350 filas.
2. **Parseo de Fechas:** Se aplicó una transformación avanzada mediante *Configuración Regional (Inglés de EE. UU.)* para interpretar las fechas de longitud variable, convirtiendo el texto en un tipo de dato `Date` (Calendario) limpio.
3. **Estandarización Numérica:** Se corrigieron los puntos decimales comerciales a comas del sistema, tipificando la columna `Price` como número decimal y `Quantity` como entero.
4. **Estructura Granular**: Se identificó que el dataset opera bajo un modelo de líneas de detalle por transacción (donde un único TransactionNo agrupa múltiples registros de productos). Para mitigar duplicidades en el volumen operativo, todas las métricas de conteo de órdenes se desarrollaron bajo la lógica de valores únicos corporativos (DISTINCT), garantizando la integridad de los KPIs financieros.

---

## 📊 5. Hallazgos Estratégicos e Insights de Negocio

### A. Diagnóstico de Cancelaciones (Falta de Stock)
Tras evaluar la integridad del dataset en la etapa de carga, se identificaron las transacciones negativas y de código 'C' (Canceladas). Se diseñó una métrica de clasificación en lenguaje DAX (`Estado_Transaccion = IF([Quantity] < 0 || LEFT([TransactionNo], 1) = "C", "Cancelado", "Efectivo")`) para aislar el impacto operativo de las órdenes insatisfechas:

* **Ventas Efectivas:** 527,765 registros (**98.40%**).
* **Cancelaciones por Quiebre de Stock:** 8,585 registros (**1.60%**).

### B. Tendencia de Ventas Mensuales y Estacionalidad (Eje Temporal)
Al aislar los ingresos reales (excluyendo cancelaciones) mediante la columna calculada `Venta_Total = [Quantity] * [Price]`, se descubrió un comportamiento estacional crítico en el último trimestre:
* **Pico Histórico de Ventas:** Noviembre de 2019 con un récord de **£7,861,197.12** (~£7.86M).
* **Concentración Trimestral:** Septiembre (£6.63M), Octubre (£7.24M) y Noviembre (£7.86M) concentran el mayor volumen del año. Esto demuestra que los clientes (minoristas y corporativos) anticipan sus compras navideñas entre 30 y 60 días antes, generando una contracción drástica en Diciembre (£2.51M) cuando el stock ya ha sido distribuido.

### C. Análisis de Rotación de Inventario (Top Productos)
Se aplicó un filtro de visualización *Top 10* basado en volumen acumulado para identificar los artículos que sostienen la operación:
1. **Paper Craft Little Birdie:** 80,995 unidades vendidas.
2. **Medium Ceramic Top Storage Jar:** 78,033 unidades vendidas.
3. **Popcorn Holder:** 56,921 unidades vendidas.
4. **World War 2 Gliders Asstd Designs:** 55,047 unidades.
5. **Jumbo Bag Red Retrospot:** 48,478 unidades.

#### 💡 Impacto en la Estrategia de Suministro:
Los dos productos principales concentran más de 159,000 unidades comercializadas en el año. Considerando que el dataset reporta un 1.60% de cancelaciones generales por falta de stock, la recomendación comercial directa es automatizar un inventario de seguridad (*Safety Stock*) exclusivo para este Top 5. Esto garantizará que nunca ocurra un quiebre de stock en los productos de máxima tracción.

### D. Estructura de Ingresos por Segmento de Cliente
Se creó una regla de negocio en lenguaje **DAX** (`Segmento_Cliente = IF([Quantity] >= 50, "Cliente Mayorista (B2B)", "Cliente Minorista (B2C)")`) para medir la procedencia del dinero:
* **Segmento Minorista (B2C):** Genera **£40,377,087.46 (64.12%)** de los ingresos generales.
* **Segmento Mayorista (B2B):** Genera **£22,588,886.88 (35.88%)** de los ingresos totales.
* *Insight:* Menos del 2% de los clientes (compradores al por mayor) inyectan más de un tercio del capital del e-commerce.

### E. Dimensión del Carrito de Compras y Solución al Sesgo Estadístico
Para responder a la métrica de volumen por transacción, se evaluó inicialmente un promedio convencional, el cual arrojó una cifra distorsionada de 282.54 unidades por pedido debido al peso de las compras masivas corporativas (B2B). Debido a las brechas extremas entre los compradores minoristas (B2C) y los mayoristas (B2B), el promedio global pierde validez representativa, ya que los valores atípicos (*outliers*) corporativos sesgan el indicador hacia arriba, ocultando el comportamiento del consumidor común.

* **Enfoque Práctico Aplicado:** Para corregir este sesgo provocado por valores atípicos (*outliers*) sin saturar el reporte con múltiples indicadores, se sustituyó el promedio por la **Mediana Comercial** utilizando la función avanzada **`MEDIANX`** en lenguaje DAX.
* **Resultado Definitivo:** La mediana se estableció en **[122]** unidades por orden de compra. 
* **Impacto Comercial:** Este número representa con total fidelidad el comportamiento del cliente central y típico del negocio, demostrando que las decisiones estratégicas de empaque o promociones del e-commerce deben diseñarse basándose en carritos reales y no en promedios ciegos inflados por el canal mayorista.

---

## 💡 6. Recomendaciones Estratégicas para la Gerencia
* **Mitigación de Pérdidas:** Automatizar alertas de inventario mínimo (*Safety Stock*) exclusivamente por lo menos para los productos del Top 5, erradicando las 8,585 órdenes canceladas anuales por quiebres de stock.
* **Fidelización Clientes B2B:** 
El segmento mayorista es el motor de rentabilidad por transacción del e-commerce dado que representan el 35.88% de los ingresos totales con un costo de adquisición por cliente (CAC) sumamente bajo. Para potenciar el negocio, se recomienda al equipo de marketing estructurar un programa de beneficios exclusivos (Account-Based Marketing) enfocado en estos compradores de volumen, asegurando contratos de suministro anuales que estabilicen el flujo de caja del negocio. 

---

## 💻 7. Anexo: Lógica de Código SQL Equivalente
Para demostrar competencias técnicas en entornos de bases de datos relacionales, en el archivo `consultas.sql` de este repositorio se adjunta el código fuente equivalente que resuelve estas mismas preguntas de negocio mediante consultas puras, funciones de agregación, condicionales `CASE WHEN` y manipulación avanzada de cadenas de texto.










---





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

