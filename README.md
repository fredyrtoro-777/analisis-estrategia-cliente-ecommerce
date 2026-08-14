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
* ¿Cuántos productos compra el cliente en promedio y cuál es el ticket promedio en cada transacción?

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
Al evaluar el volumen y el valor por transacción única (ID de Pedido) para comprender la verdadera tracción del negocio, se identificó una distribución altamente sesgada provocada por el peso del canal mayorista (B2B):

* **Volumen por Pedido:** El promedio convencional arrojó una cifra inflada de **282.54 unidades**, mientras que la **Mediana Comercial (`MEDIANX`)** se ubicó en **122 unidades** por orden de compra.
* **Valor por Pedido (Ticket de Compra):** Siguiendo la misma línea de consistencia metodológica para neutralizar el sesgo financiero de los valores atípicos (*outliers*), se calculó la **Mediana del Ticket de Compra** en lenguaje DAX. Este indicador clave se estableció en **£1,380.00** por transacción efectiva.
* **Impacto Comercial:** Una mediana de 122 unidades y £1,380 por pedido confirma que el e-commerce posee un cliente central institucionalizado o comercializador de alta capacidad, con un valor de artículo promedio que ronda las £11.31. Este hallazgo demuestra que las proyecciones de ingresos y las estrategias de precios de la compañía deben diseñarse bajo el cobijo de la mediana financiera, evitando que los promedios ciegos inflen artificialmente el conocimiento real del consumidor.

---

## 💡 6. Recomendaciones Estratégicas para la Gerencia
* **Mitigación de Pérdidas:** Automatizar alertas de inventario mínimo (*Safety Stock*) exclusivamente por lo menos para los productos del Top 5, erradicando las 8,585 órdenes canceladas anuales por quiebres de stock.
* **Fidelización Clientes B2B:** 
El segmento mayorista es el motor de rentabilidad por transacción del e-commerce dado que representan el 35.88% de los ingresos totales con un costo de adquisición por cliente (CAC) sumamente bajo. Para potenciar el negocio, se recomienda al equipo de marketing estructurar un programa de beneficios exclusivos (Account-Based Marketing) enfocado en estos compradores de volumen, asegurando contratos de suministro anuales que estabilicen el flujo de caja del negocio. 

---
## 💻 7. Anexo: Lógica de Código SQL Equivalente
Para demostrar competencias técnicas en entornos de bases de datos relacionales, en el archivo `consultas.sql` de este repositorio se adjunta el código fuente equivalente. Este script resuelve y valida de forma exacta las mismas preguntas core del negocio mediante consultas puras, funciones de agregación, agrupaciones temporales y condicionales `CASE WHEN`. 

Este anexo técnico funciona como un proceso de auditoría cruzada (Cross-Validation), garantizando que la base de datos local y el modelo de Business Intelligence en Power BI consoliden exactamente los mismos ingresos totales (£62,965,974.34) y tendencias operativas, asegurando un ecosistema de datos íntegro y confiable.

