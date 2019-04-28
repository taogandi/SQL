USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT (UPPER(first_name)," ", UPPER(last_name)) AS `Actor Name` 
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name LIKE 'Joe%';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name FROM actor 
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name FROM actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description. 
-- So create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor
ADD description BLOB; 

SELECT * from actor
LIMIT 5;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

SELECT * from actor
LIMIT 5;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as `number_of_actor`
FROM actor
GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as `number_of_actor`
FROM actor
GROUP BY last_name
HAVING number_of_actor > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
-- Get the actor_id for this actor
SELECT * FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- The actor_id is 172 

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS' AND actor_id = 172;

-- Now check for update
Select * FROM actor
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS' AND actor_id = 172;

-- Now check for update
Select * FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
CREATE TABLE address1 (
 address_id INTEGER(11) AUTO_INCREMENT NOT NULL,
 address VARCHAR(50) NOT NULL,
 address2 VARCHAR(50) NOT NULL,
 district VARCHAR(20) NOT NULL,
 city_id INTEGER(10) NOT NULL,
 postal_code VARCHAR(10) NOT NULL,
 location GEOMETRY NOT NULL,
 last_update timestamp,
 PRIMARY KEY (address_id)
);

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT st.first_name, st.last_name, ad.address
FROM staff st
JOIN address ad
ON st.address_id = ad.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT st.first_name, st.last_name, sum(py.amount) as "Amount_Rung_Up"
FROM payment py
JOIN staff st
ON py.staff_id = st.staff_id
GROUP BY st.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.film_id, f.title, count(fa.actor_id) as "Number_of_Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY fa.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.film_id, f.title, count(f.film_id) as "Number_of_Copy"
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = "HUNCHBACK IMPOSSIBLE"
GROUP BY f.film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT cus.first_name, cus.last_name, sum(py.amount) as "Total amount paid"
FROM payment py
JOIN customer cus
ON py.customer_id = cus.customer_id
GROUP BY cus.customer_id
ORDER BY cus.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title like "K%" OR title like "Q%" 
AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name IN ('ENGLISH')
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN 
  (
  SELECT film_id
  FROM film
  WHERE title = "ALONE TRIP"
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT cus.first_name, cus.last_name, cus.email
FROM customer cus
JOIN address ad
ON cus.address_id = ad.address_id
JOIN city cty
ON ad.city_id = cty.city_id
JOIN country cnt
ON cnt.country_id = cty.country_id
WHERE country = "CANADA";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film.title as "Film Title", category.name as "Movie Type"
FROM film
JOIN film_category 
ON film.film_id = film_category.film_id
JOIN category
ON film_category.category_id = category.category_id
WHERE category.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title as "Movie", count(rental.rental_id) as "Rent Times"
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY inventory.film_id
ORDER BY count(rental.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(payment.amount) as "Total_Revenue"
FROM store
JOIN inventory
ON store.store_id = inventory.store_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
JOIN country
ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as "Movie Genres", sum(payment.amount) as "Gross Revenue"
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.category_id
ORDER BY sum(payment.amount) DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `Top_five_genres` 
AS SELECT c.name as "Movie Genres", sum(py.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment py
ON r.rental_id = py.rental_id
GROUP BY c.category_id
ORDER BY sum(py.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM `Top_five_genres`;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW `Top_five_genres`;