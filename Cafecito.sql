SELECT * FROM coffee_shop_sales

#Total de cantidades vendidas
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5 -- Para el mes de mayo


/*
Esta consulta calcula la cantidad total de productos vendidos por mes para los meses de Abril y Mayo,
y determina el porcentaje de crecimiento o decrecimiento mes a mes (MoM)
en la cantidad total vendida. Utiliza una función de ventana (LAG) para comparar
la cantidad vendida del mes actual con la del mes anterior.
*/

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- - - - - - - - - - - - - - - - - - - - - - - -- - - - --
/*
Esta consulta calcula las métricas clave de ventas para un día específico.
Obtiene el total de ventas (ingresos), la cantidad total de productos vendidos
y el número total de órdenes.
*/

SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; -- Para 18 Mayo 2023

/*
Esta consulta calcula y formatea las métricas clave de ventas para un día específico.
Obtiene el total de ventas (ingresos), el número total de órdenes y la cantidad total de productos vendidos
para la fecha '2023-05-18', presentando los resultados en miles (con el sufijo 'K')
y redondeados a un decimal.
*/
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023
    
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

/*
Esta consulta calcula el promedio de ventas diarias para el mes de Mayo.
Primero, una subconsulta calcula el total de ventas para cada día de Mayo,
y luego la consulta externa calcula el promedio de esas ventas diarias.
*/

SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

/*Agrupa las transacciones por cada día del mes y suma las ventas correspondientes,
presentando los resultados ordenados por el día del mes.
*/

SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
Esta consulta categoriza las ventas diarias del mes de Mayo 'Por encima del promedio',
'Por debajo del promedio' o 'Promedio'.
Primero, una subconsulta calcula las ventas totales para cada día de Mayo y el promedio
general de ventas diarias de todo el mes. Luego, la consulta externa compara las ventas
de cada día con ese promedio para asignar una categoría.
*/

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
Esta consulta calcula el total de ventas del mes de Mayo, diferenciando entre
ventas realizadas durante los fines de semana ('Weekends') y las ventas realizadas
durante los días de semana ('Weekdays').
*/

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'FindeSemana'
        ELSE 'DiasdeSemana'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'FindeSemana'
        ELSE 'DiasdeSemana'
    END;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
Calcula las ventas totales para cada categoría de producto
y presenta los resultados ordenados de la categoría con más ventas a la de menos.
*/

SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC

-- - - - - - -

#Ventas por producto top 10

SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10
 
-- - - - - - - - -
#Ventas por dia/H
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
-- - - - - - -  - - - - -  -- - - - - - - - - - -

#Ventas de la semana del mes de Mayo

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
    -- - - - - - - - - - - - - - - - - - - - - - - -

#Ventas por hora en el mes de mayo
    
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);



