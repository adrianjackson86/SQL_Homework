use sakila;
-- select * from sakila.actor;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name," ",last_name) as Actor from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id
	  ,first_name
      ,last_name
from actor
where first_name like ("Joe");

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id
	  ,first_name
      ,last_name
from actor
where last_name like ("%gen%");

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id
	  ,first_name
      ,last_name
from actor
where last_name like ("%li%")
order by last_name
		 ,first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id
	  ,country
from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_update;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name
	  ,count(*) as "actor count"
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select a.last_name
	  ,a.number
from (
select last_name
	  , count(*) as "number"
from actor
group by last_name) a
where a.number >= 2
group by last_name;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name= CASE
   WHEN first_name="HARPO" THEN "GROUCHO"
   ELSE first_name
END;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;
-- 'CREATE TABLE `address` (
--   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--   `address` varchar(50) NOT NULL,
--   `address2` varchar(50) DEFAULT NULL,
--   `district` varchar(20) NOT NULL,
--   `city_id` smallint(5) unsigned NOT NULL,
--   `postal_code` varchar(10) DEFAULT NULL,
--   `phone` varchar(20) NOT NULL,
--   `location` geometry NOT NULL,
--   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   PRIMARY KEY (`address_id`),
--   KEY `idx_fk_city_id` (`city_id`),
--   SPATIAL KEY `idx_location` (`location`),
--   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name
	  ,last_name
      ,address
      ,address2
from staff s
join address a
on s.address_id = a.address_id; 

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select concat(s.first_name," ",s.last_name) as Full_Name
	   ,sum(p.amount)
from staff s
join payment p
on s.staff_id = p.staff_id
group by concat(s.first_name," ",s.last_name);

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title
	   ,count(fa.actor_id) as actor_count
from film f
inner join film_actor fa
on f.film_id = fa.film_id
group by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title
	  ,f.description
      ,f.rental_rate
      ,count(f.title) as on_hand_inv
from film f
join inventory i
on f.film_id = i.film_id
where title = "Hunchback Impossible"
group by
	   f.title
	  ,f.description
      ,f.rental_rate;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select concat(c.last_name,",",c.first_name) as Full_Name
	  -- ,c.first_name
      -- ,c.last_name
      ,sum(p.amount) as total_customer_payment
from customer c
join payment p
on c.customer_id = p.customer_id
-- only active customers?
-- where c.active = 1
group by
concat(c.last_name,",",c.first_name)
order by
c.last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- language.language_id = 1 (English)
select a.*
from
(select *
from film
where title like ("K%")
or title like ("Q%")
and language_id = 1) a;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select distinct concat(actors.first_name," ",actors.last_name) as Actor_Name
	  ,f.title as Movie_Title
from
(select a.*
from actor a
join film_actor fa
on a.actor_id = fa.actor_id) actors
join film_actor fa
on actors.actor_id = fa.actor_id
join film f
on fa.film_id = f.film_id
where f.title = "Alone Trip";

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- Canada is country_id = 20
select cust.first_name
	  ,cust.last_name
      ,cust.email
from customer cust
join
(select a.*
from address a
where city_id IN (select city_id
from city
where country_id = 20)) final
on cust.address_id = final.address_id;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- category_id = 8, family
-- Apache Divine is NC-17.....
select f.title
	  ,f.description
      ,f.rating
      ,f.rental_rate
from film f
join film_category fc
on f.film_id = fc.film_id
where fc.category_id = 8;

-- 7e. Display the most frequently rented movies in descending order.
select f.title as "Movie Title"
	  ,count(r.inventory_id) as "Times Rented"
from inventory i
join film f
on i.film_id = f.film_id
join rental r
on r.inventory_id = i.inventory_id
group by f.title
order by count(r.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id as "Store ID"
      ,sum(p.amount) "Cash Brought In"
from store s
join customer c
on s.store_id = c.store_id
join payment p
on c.customer_id = p.customer_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id
	  ,c.city
      ,co.country
from store s
join address a
on s.address_id = a.address_id
join city c
on c.city_id = a.city_id
join country co
on co.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name as "Genre"
      ,sum(p.amount) as "Gross Revenue"
from category cat -- name, category_id
join film_category fc
on cat.category_id = fc.category_id
join inventory i
on i.film_id = fc.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by cat.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_GenreRevenue AS
select cat.name as "Genre"
      ,sum(p.amount) as "Gross Revenue"
from category cat -- name, category_id
join film_category fc
on cat.category_id = fc.category_id
join inventory i
on i.film_id = fc.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by cat.name
order by sum(p.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from Top_GenreRevenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top_GenreRevenue;


