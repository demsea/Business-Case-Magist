# here I am getting to know the data of Magist, our possible contractor in Brazil
# we have to figure ou if they are a good fit to our company

USE magist;

SELECT DISTINCT price, COUNT(*)
FROM order_items
GROUP BY price;

# there is 112 650 items were ordered durig this period
SELECT COUNT(*)
FROM order_items;


#to figure out the main price_category delivered for an item
WITH prices AS (
	SELECT price,
    CASE 
		WHEN price <= 100 THEN '100 up'
        WHEN price <= 200 THEN '101-200'
        WHEN price <= 300 THEN '201-300'
        WHEN price <= 400 THEN '301-400'
        WHEN price <= 500 THEN '401-500'
        WHEN price <= 600 THEN '501-600'
        WHEN price <= 700 THEN '601-700'
        WHEN price <= 800 THEN '701-800'
        WHEN price <= 900 THEN '801-900'
        WHEN price <= 1000 THEN '901-1000'
        WHEN price <= 1500 THEN '1001-1500'
        WHEN price <= 2000 THEN '1501-2000'
        ELSE '2001 and higher'
	END AS 'price_category'
	FROM order_items
)

SELECT price_category, COUNT(*)
FROM prices
GROUP BY price_category;

/* 99276 items delivered were in the price category 0-200 and out of it 72337 in the category 0-100
	112650 - 100%
	99276 - x%->  x= 88% is in the price category 0-200
    
    Our AVG item price is 540, if we count all items delivered from 500 and higher, its 3216 items, which is just 
    2,85%. So they are not very experienced delivering expensive items
    
*/

SELECT DISTINCT order_status
FROM orders;

SELECT *
FROM order_reviews a LEFT JOIN orders b 
	ON a.order_id=b.order_id
    LEFT JOIN order_items c
    ON b.order_id = c.order_id;


# orders_payment payment for order is divided into parts sometimes, when instalment is 2 or more 
# it is equal to order_items table price + freight_value

SELECT order_id, COUNT(*)
FROM order_payments
GROUP BY order_id;

SELECT *
FROM order_payments
WHERE order_id = '00e6bc6b166eb28b4502c1cad4457248';

SELECT *
FROM order_items
WHERE order_id='00e6bc6b166eb28b4502c1cad4457248';



# how many orders in the dataset  = 99.441
SELECT COUNT(order_id)
FROM orders;

#how many orders are actualy delivered (also %) = 96.478 (or 97 % )
SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status;

#is the customer base is growing? it was definetely growing in 2017 and up till March 2018, then a bit lowered 

SELECT EXTRACT(YEAR_MONTH FROM `order_purchase_timestamp`) AS purchase_date, COUNT(*)
FROM orders
GROUP BY purchase_date
ORDER BY purchase_date;

#how many products in the products table = 32951

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id;

SELECT COUNT(product_id)
FROM products;

#which are the categories with the most products that sellers propose
# Answer: not tech, closest is computer accessories on the 7th place
SELECT b.product_category_name_english, COUNT(a.product_id) AS product_number
FROM products a LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
GROUP BY b.product_category_name_english
ORDER BY product_number DESC;


#how many of this products were involved in the actual transaction?
#Answer: not tech, comp accessories on the 5th place, watches 7th
SELECT b.product_category_name_english, COUNT(a.product_id) AS product_number
FROM order_items c LEFT JOIN products a 
	ON c.product_id = a.product_id
	LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
GROUP BY b.product_category_name_english
ORDER BY product_number DESC;


# MIN and MAX prices, AVG
SELECT MAX(price), MIN(price), AVG(price)
FROM order_items;


#what is the highest someone payed for an order = 13664
SELECT order_id, ROUND(SUM(payment_value), 2) AS order_total
FROM order_payments
GROUP BY order_id
ORDER BY order_total DESC;


#AVG order = 160

WITH average AS(
SELECT order_id, ROUND(SUM(payment_value), 2) AS order_total
FROM order_payments
GROUP BY order_id
ORDER BY order_total DESC)

SELECT AVG(order_total)
FROM average;


#reviews per order, that actually happened and were delivered by categories
# for electronics, comp acessories it is 4 star in Average

SELECT b.product_category_name_english, COUNT(a.product_id) AS product_number, 
	MAX(d.review_score), MIN(d.review_score), AVG(d.review_score)
FROM order_reviews d LEFT JOIN orders o
	ON d.order_id = o.order_id
	LEFT JOIN order_items c
	ON d.order_id = c.order_id 
    LEFT JOIN products a 
	ON c.product_id = a.product_id
	LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY b.product_category_name_english
ORDER BY product_number DESC;



#Suppliers

# there is 112 650 items were ordered durig this period (32951 distinct items, so everything is selling)
SELECT COUNT(product_id)
FROM order_items;

#overall number of products_id offered by suppliers = 32951
SELECT COUNT(DISTINCT product_id)
FROM order_items;

#categories of tech products are : 'computers_accessories','watches_gifts','telephony','electronics','consoles_games',
#'fixed_telephony','audio','dvds_blu_ray','computers','tablets_printing_image','pc_gamer','cds_dvds_musicals')
                                            

#how many of this tech products were involved in the actual transaction, comparing to the other categories
#tech 23.268(20,7%), other 89.382 (79,3%)

# AVG price for tech category 133, comparing to Eniac AVG price 540
# AVG order = 160
# AVG price = 120
SELECT 
	CASE WHEN b.product_category_name_english IN ('computers_accessories',
											'watches_gifts',
                                            'telephony',
                                            'electronics',
                                            'consoles_games',
                                            'fixed_telephony',
                                            'audio',
                                            'dvds_blu_ray',
                                            'computers',
                                            'tablets_printing_image',
                                            'pc_gamer',
                                            'cds_dvds_musicals') THEN 'tech category'
		ELSE 'other'
        END AS category,
    COUNT(a.product_id) AS product_number, AVG(c.price), MAX(c.price), MIN(c.price)
FROM order_items c LEFT JOIN products a 
	ON c.product_id = a.product_id
	LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
GROUP BY category
ORDER BY product_number DESC;




#if the tech products are popular? are expensive tech products popular?

#99276 items delivered were in the price category 0-200 and out of it 72337 in the category 0-100
/* 112650 - 100%
	99276 - x%->  x= 88% is in the price category 0-200
    
    let's consider an expensive product is the one with the price 500 and higher, as 
    
    Our AVG item price is 540, if we count all items delivered from 500 and higher, its 3216 items, which is just 
    2,85%. So they are not very experienced delivering and selling expensive items
  
  if we take only tech products - expensive products are not very popular, out of 23.268 tech product sold, 
  #there are only 1137 with the price 500 euro and higher (4,9%).
*/
WITH prices AS (
	SELECT price,
    CASE 
		WHEN price <= 100 THEN '100 up'
        WHEN price <= 200 THEN '101-200'
        WHEN price <= 300 THEN '201-300'
        WHEN price <= 400 THEN '301-400'
        WHEN price <= 500 THEN '401-500'
        WHEN price <= 600 THEN '501-600'
        WHEN price <= 700 THEN '601-700'
        WHEN price <= 800 THEN '701-800'
        WHEN price <= 900 THEN '801-900'
        WHEN price <= 1000 THEN '901-1000'
        WHEN price <= 1500 THEN '1001-1500'
        WHEN price <= 2000 THEN '1501-2000'
        ELSE '2001 and higher'
	END AS 'price_category'
	FROM order_items
)

SELECT price_category, COUNT(*)
FROM prices
GROUP BY price_category;


WITH tech_prices AS (
	SELECT price,
    CASE 
		WHEN price <= 100 THEN '100 up'
        WHEN price <= 200 THEN '101-200'
        WHEN price <= 300 THEN '201-300'
        WHEN price <= 400 THEN '301-400'
        WHEN price <= 500 THEN '401-500'
        WHEN price <= 600 THEN '501-600'
        WHEN price <= 700 THEN '601-700'
        WHEN price <= 800 THEN '701-800'
        WHEN price <= 900 THEN '801-900'
        WHEN price <= 1000 THEN '901-1000'
        WHEN price <= 1500 THEN '1001-1500'
        WHEN price <= 2000 THEN '1501-2000'
        ELSE '2001 and higher'
	END AS 'price_category'
	FROM order_items c LEFT JOIN products a 
	ON c.product_id = a.product_id
	LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
    WHERE b.product_category_name_english IN ('computers_accessories',
											'watches_gifts',
                                            'telephony',
                                            'electronics',
                                            'consoles_games',
                                            'fixed_telephony',
                                            'audio',
                                            'dvds_blu_ray',
                                            'computers',
                                            'tablets_printing_image',
                                            'pc_gamer',
                                            'cds_dvds_musicals')
)

SELECT price_category, COUNT(*)
FROM tech_prices
GROUP BY price_category;


#OR shorter
WITH tech_prices AS (
	SELECT price,
    CASE 
		WHEN price <= 100 THEN '100 up'
        WHEN price <= 200 THEN '101-200'
        WHEN price <= 500 THEN '201-500'
        ELSE '501 and higher'
	END AS 'price_category'
	FROM order_items c LEFT JOIN products a 
	ON c.product_id = a.product_id
	LEFT JOIN product_category_name_translation b
	ON a.product_category_name = b.product_category_name
    WHERE b.product_category_name_english IN ('computers_accessories',
											'watches_gifts',
                                            'telephony',
                                            'electronics',
                                            'consoles_games',
                                            'fixed_telephony',
                                            'audio',
                                            'dvds_blu_ray',
                                            'computers',
                                            'tablets_printing_image',
                                            'pc_gamer',
                                            'cds_dvds_musicals')
)

SELECT price_category, COUNT(*)
FROM tech_prices
GROUP BY price_category;


SELECT product_id, COUNT(*)
FROM order_items
GROUP BY product_id;

SELECT YEAR(shipping_limit_date) AS our_year, MONTH(shipping_limit_date) AS our_month, COUNT(order_id)
FROM order_items
GROUP BY our_year, our_month;