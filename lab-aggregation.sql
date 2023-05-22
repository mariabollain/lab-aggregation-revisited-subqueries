use sakila;

# 1. Select the first name, last name, and email address of all the customers who have rented a movie.

SELECT 
    C.first_name, C.last_name, C.email
FROM
    customer C
        JOIN
    rental R USING (customer_id)
GROUP BY customer_id;

# 2. What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made).

SELECT 
    C.customer_id,
    CONCAT(C.first_name, ' ', C.last_name) AS customer_name,
    ROUND(AVG(P.amount), 2) AS avg_payment
FROM
    customer C
        JOIN
    payment P USING (customer_id)
GROUP BY customer_id , customer_name
ORDER BY avg_payment DESC;

# 3. Select the name and email address of all the customers who have rented the "Action" movies.
## Write the query using multiple join statements

SELECT 
    CONCAT(C.first_name, ' ', C.last_name) AS customer_name,
    C.email
FROM
    customer C
        JOIN
    rental R USING (customer_id)
        JOIN
    inventory I USING (inventory_id)
        JOIN
    film_category F USING (film_id)
        JOIN
    category CA USING (category_id)
WHERE
    CA.name = 'Action'
GROUP BY C.customer_id; # avoids showing the same customer more than once

SELECT 
    CONCAT(C.first_name, ' ', C.last_name) AS customer_name,
    C.email, 
    C.customer_id,
    I.inventory_id,
    COUNT(DISTINCT(F.film_id)),
    CA.category_id
FROM
    customer C
        JOIN
    rental R USING (customer_id)
        JOIN
    inventory I USING (inventory_id)
        JOIN
    film_category F USING (film_id)
        JOIN
    category CA USING (category_id)
WHERE
    CA.name = 'Action';

## Write the query using sub queries with multiple WHERE clause and IN condition

SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name, email
FROM
    customer
WHERE
    customer_id IN (SELECT  # since we are selecting the customer_id here, there's no need to group by 
            customer_id
        FROM
            rental
        WHERE
            inventory_id IN (SELECT 
                    inventory_id
                FROM
                    inventory
                WHERE
                    film_id IN (SELECT 
                            film_id
                        FROM
                            film_category
                        WHERE
                            category_id IN (SELECT 
                                    category_id
                                FROM
                                    category
                                WHERE
                                    name = 'Action')))); 
                                    
## Verify if the above two queries produce the same results or not
### Both subqueries produce the same result (510 rows).

# 4. Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment. 
# If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4, the label should be medium, and if it is more than 4, then it should be high.

ALTER TABLE payment
ADD payment_classification VARCHAR(20);

SET SQL_SAFE_UPDATES = 0;

UPDATE payment SET payment_classification = 
CASE 
WHEN amount <= 2 THEN "low"
WHEN amount > 2 AND amount <= 4 THEN "medium"
WHEN amount > 4 THEN "high" 
END;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM payment;
