SELECT * FROM order_detail_events

SELECT * FROM order_detail

SELECT * FROM order_header

SELECT * FROM annulation

--------------------------------------------------------------------

-- ### Nombre total de commandes ?

SELECT COUNT(id) as total_orders
FROM order_detail


-- ###  Nombre de commandes par statut ?

SELECT status, COUNT(id) as total_orders
FROM order_detail
GROUP BY status
ORDER BY 2 DESC;

-- ### Nombre d’articles vendus par vendeur?  ("Delivered", "Shipped", "Accepted")

SELECT seller_id, COUNT(order_id)
FROM order_header
WHERE status IN ('Delivered', 'Shipped', 'Accepted')
GROUP BY 1
ORDER BY 2 DESC

-- ### Classement des clients par valeur totale de commandes et par nombre de commandes (uniquement pour les clients ayant passé plus de 3 commandes).

SELECT customer_reference as customer, ROUND(SUM(totalprice_sellingprice::"numeric"),2) as total_orders_values, COUNT(*) as total_orders
FROM order_header
GROUP BY 1 
HAVING COUNT(*) > 3
ORDER BY 2 DESC;

-- ### Vitesse de livraison (écart entre la création et la livraison) pour les commandes comprenant au moins un article annulé.


SELECT delivers_by_days
FROM (
    SELECT *,
           (update_date - create_date) AS delivers_by_days
    FROM order_header
    WHERE status = 'Cancelled'
) AS t1
ORDER BY 1 DESC;


-- ### Valeur moyenne des commandes annulées ?

SELECT ROUND(AVG(totalprice_sellingprice::"numeric"),2) AS avg_value_cancelled_orders
FROM order_header
WHERE status = 'Cancelled'

-- ### Liste des vendeurs ayant au moins 3 commandes annulées?

SELECT seller_id as sellers, COUNT(*) as number_of_cancelled_orders 
FROM order_header
WHERE status = 'Cancelled'
GROUP BY 1
HAVING COUNT(*) >= 3
ORDER BY 2 DESC;



-- ### Identification des clients ayant repassé une commande après une annulation.

SELECT 
    o2.customer_reference,
    COUNT(*) AS total_other_status
FROM order_header o2
INNER JOIN (
    SELECT 
        customer_reference AS customers, 
        MIN(create_date) AS min_date, 
        COUNT(*) AS total_cancelled
    FROM order_header
    WHERE status = 'Cancelled'
    GROUP BY customer_reference
) t1
    ON t1.customers = o2.customer_reference
WHERE 
    o2.status IN ('Delivered', 'Shipped', 'Accepted')
    AND t1.min_date < o2.create_date
GROUP BY 
    o2.customer_reference;








