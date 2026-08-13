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

## 🛠️ 4. Arquitectura de la Solución (Metodología ETL)
Para garantizar la escalabilidad y automatización del negocio, y considerando la magnitud de registros, se estructuró un flujo de **Extracción, Transformación y Carga (ETL)** nativo en **Power BI Desktop (Power Query)**:

1. **Ingesta:** Conexión directa al archivo CSV crudo de 536,350 filas.
2. **Parseo de Fechas:** Se aplicó una transformación avanzada mediante *Configuración Regional (Inglés de EE. UU.)* para interpretar las fechas de longitud variable, convirtiendo el texto en un tipo de dato `Date` (Calendario) limpio.
3. **Estandarización Numérica:** Se corrigieron los puntos decimales comerciales a comas del sistema, tipificando la columna `Price` como número decimal y `Quantity` como entero.

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

### D. Estructura de Ingresos por Segmento de Cliente
Se creó una regla de negocio en lenguaje **DAX** (`Segmento_Cliente = IF([Quantity] >= 50, "Cliente Mayorista (B2B)", "Cliente Minorista (B2C)")`) para medir la procedencia del dinero:
* **Segmento Minorista (B2C):** Genera **£40,377,087.46 (64.12%)** de los ingresos generales.
* **Segmento Mayorista (B2B):** Genera **£22,588,886.88 (35.88%)** de los ingresos totales.
* *Insight:* Menos del 2% de los clientes (compradores al por mayor) inyectan más de un tercio del capital del e-commerce.

---

## 💡 6. Recomendaciones Estratégicas para la Gerencia
* **Mitigación de Pérdidas:** Automatizar alertas de inventario mínimo (*Safety Stock*) exclusivamente para los productos del Top 5 (*Paper Craft, Ceramic Jars*), erradicando las 8,585 órdenes canceladas anuales por quiebres de stock.
* **Fidelización B2B:** Diseñar un programa de beneficios corporativos (descuentos por volumen acumulado) para retener al segmento Mayorista, dado que representan el 35.88% de los ingresos totales con un costo de adquisición por cliente (CAC) sumamente bajo.

---

## 💻 7. Anexo: Lógica de Código SQL Equivalente
Para demostrar competencias técnicas en entornos de bases de datos relacionales, en el archivo `consultas.sql` de este repositorio se adjunta el código fuente equivalente que resuelve estas mismas preguntas de negocio mediante consultas puras, funciones de agregación, condicionales `CASE WHEN` y manipulación avanzada de cadenas de texto.










---



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

## B. Tendencia de Ventas Mensuales y Estacionalidad Comercial
Al analizar la línea de tiempo de ingresos reales (excluyendo cancelaciones), se identificó un comportamiento estacional crítico concentrado en el tercer y cuarto trimestre del año (Q3 y Q4):

* **Pico Histórico de Ventas:** Noviembre de 2019 con un total de **£7,861,197.12** (€7.86M).
* **Comportamiento Trimestral:** Se evidencia un crecimiento acelerado a partir de Septiembre (£6.63M) y Octubre (£7.24M), impulsado por el abastecimiento anticipado de regalos y artículos del hogar para la temporada de fin de año.
  
* **💡Hallazgo Operativo:** En Diciembre de 2019 se registra una contracción drástica de ingresos (£2.51M), lo que confirma que el ciclo de compra de los clientes (tanto mayoristas como minoristas) concluye antes de iniciar el mes festivo.
  
### C. Análisis de Rotación de Inventario (Top 10 Productos)
Se aisló el comportamiento de los artículos del catálogo para identificar los productos "estrella" que sostienen el volumen operativo de la tienda (medido en unidades vendidas acumuladas):

1. **Paper Craft Little Birdie:** 80,995 unidades.
2. **Medium Ceramic Top Storage Jar:** 78,033 unidades.
3. **Popcorn Holder:** 56,921 unidades.
4. **World War 2 Gliders Asstd Designs:** 55,047 unidades.
5. **Jumbo Bag Red Retrospot:** 48,478 unidades.

#### 💡 Impacto en la Estrategia de Suministro:
Los dos productos principales concentran más de 159,000 unidades comercializadas en el año. Considerando que el dataset reporta un 1.60% de cancelaciones generales por falta de stock, la recomendación comercial directa es automatizar un inventario de seguridad (*Safety Stock*) exclusivo para este Top 5. Esto garantizará que nunca ocurra un quiebre de stock en los productos de máxima tracción.

### D. Segmentación Estratégica de Clientes (B2B vs B2C)
Se aplicó una regla de negocio basada en el volumen promedio de compra para clasificar el comportamiento del consumidor y entender de dónde proviene el valor financiero de la empresa:

* **Segmento Minorista (B2C):** Genera **£40,377,087.46 (64.12%)** de los ingresos. Representa el núcleo del volumen masivo de transacciones cotidianas.
* **Segmento Mayorista (B2B):** Genera **£22,588,886.88 (35.88%)** de los ingresos. Concentra más de un tercio del valor comercial de la tienda a través de compras al por mayor.

#### 💡 Recomendación de Estrategia de Clientes:
El segmento mayorista es el motor de rentabilidad por transacción del e-commerce. Para potenciar el negocio, se recomienda al equipo de marketing estructurar un programa de beneficios exclusivos (Account-Based Marketing) enfocado en estos compradores de volumen, asegurando contratos de suministro anuales que estabilicen el flujo de caja del negocio.


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
