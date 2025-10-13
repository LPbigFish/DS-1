-- 1.
SELECT rating, COUNT(*)
from film
group by rating
-- 2.
select customer_id, COUNT(last_name)
from customer
group by customer_id
-- 3.
select customer_id, SUM(payment.amount) as total_amount
from payment
group by customer_id
order by total_amount desc
-- 5.
select YEAR(p.payment_date), MONTH(p.payment_date), SUM(p.amount) as total
from payment as p
group by YEAR(p.payment_date), MONTH(p.payment_date)
-- 6.
select COUNT(i.inventory_id) as total_copies, i.store_id
from inventory as i
group by store_id
having COUNT(i.inventory_id) > 2300
-- 8.
select YEAR(p.payment_date) as year, MONTH(p.payment_date) as month
from payment as p
group by YEAR(p.payment_date), MONTH(p.payment_date)
having SUM(p.amount) > 20000
-- 10.
select l.name, COUNT(f.film_id)
from film as f
join language as l on l.language_id = f.language_id
group by l.name
-- 12.
select l.name, COUNT(f.film_id)
from language as l
left join film as f on l.language_id = f.language_id
group by l.name

-- 18.
select distinct f.title, SUM(p.amount) as total_profit
from film as f
join inventory as i on i.film_id = f.film_id
join rental as r on r.inventory_id = i.inventory_id
join payment as p on p.rental_id = r.rental_id
group by f.film_id, f.title
having SUM(p.amount) > 100
order by total_profit desc

-- 15.
select a.first_name, a.last_name, count(fa.actor_id) as total_movies
from actor as a
join film_actor as fa on fa.actor_id = a.actor_id
group by a.actor_id, a.first_name, a.last_name
having COUNT(fa.actor_id) > 20
order by total_movies desc

-- 24.
select c.customer_id, SUM(p.amount) as total_payments
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.rental_id = p.rental_id
	and MONTH(r.rental_date) = 6
group by c.customer_id