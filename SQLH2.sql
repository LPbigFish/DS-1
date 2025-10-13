-- 1.
SELECT * from city JOIN country ON city.country_id = country.country_id;
-- 2.
SELECT film.title, language.name from film JOIN language ON film.language_id = language.language_id;
-- 3.
SELECT r.rental_id from rental as r JOIN customer as c ON r.customer_id = c.customer_id WHERE c.last_name LIKE 'SIMPSON';
-- 4.
SELECT a.address from address as a JOIN customer as c ON a.address_id = c.customer_id WHERE c.last_name LIKE 'SIMPSON';
-- 5.
SELECT cu.first_name, cu.last_name, a.address, c.city from customer as cu JOIN address as a ON cu.address_id = a.address_id LEFT JOIN city as c ON a.city_id = c.city_id;
-- 6.
SELECT c.first_name, c.last_name, ci.city from customer as c join address on c.address_id = address.address_id join city as ci on ci.city_id = address.city_id;
-- 7.
SELECT rental.rental_id, s.first_name, c.first_name, f.title 
from rental 
join inventory as i on rental.inventory_id = i.inventory_id 
join film as f on f.film_id = i.film_id 
join staff as s on s.staff_id = rental.staff_id 
join customer as c on c.customer_id = rental.customer_id;
-- 9.
SELECT
a.first_name, a.last_name, f.title
FROM film_actor as fa
join actor as a on a.actor_id = fa.actor_id
join film as f on f.film_id = fa.film_id;
-- 12.
SELECT DISTINCT a.actor_id, a.first_name, a.last_name, c.category_id, c.name
FROM film as f
join film_category as fc on f.film_id = fc.film_id
join category as c on fc.category_id = c.category_id
join film_actor as fa on f.film_id = fa.film_id
join actor as a on fa.actor_id = a.actor_id
ORDER BY a.actor_id;
-- 14.
SELECT DISTINCT f.title
from inventory as i
join film as f on f.film_id = i.film_id;