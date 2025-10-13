-- 1.
SELECT f.film_id, f.title
from film as f
where f.film_id in (
	select film_id
	from film_actor
	where actor_id = 1
)

-- 2.
select film_id
from film_actor
where actor_id = 1

-- 3.
select distinct f.film_id, f.title
from film as f
where f.film_id in (
	select film_id
	from film_actor
	where actor_id = 1
) and f.film_id in (
	select film_id
	from film_actor
	where actor_id = 10
)

-- 5.
select distinct film_id
from film_actor
where film_id not in (
	select film_id
	from film_actor
	where actor_id = 1
)

-- 6.
select distinct f.film_id, f.title
from film as f
where exists (
	select 1
	from film_actor
	where (actor_id = 1 or actor_id = 10) and f.film_id = film_actor.film_id
) and not (
	exists (
		select 1 from film_actor where actor_id = 1  and f.film_id = film_actor.film_id
	) and exists (
		select 1 from film_actor where actor_id = 10 and f.film_id = film_actor.film_id
	)
)

-- 11.
select c.first_name, c.last_name
from customer as c
where exists (
	select 1 from actor as a where a.last_name = c.last_name
)

-- 12.
select f.title, f.length
from film as f
where exists (
	select 1 from film as fs where fs.length = f.length and fs.film_id <> f.film_id
) order by f.length

-- 13.
select f.title, f.length
from film as f
where f.length < ANY (
	select fs.length from film as fs 
	join film_actor as fa on fs.film_id = fa.film_id 
	join actor as a on a.actor_id = fa.actor_id 
	where a.first_name = 'BURT' and a.last_name = 'POSEY'
)

-- 14. 
select a.first_name, a.last_name
from actor as a
where exists (
	select 1 from 
	film as f
	join film_actor as fa on fa.actor_id = a.actor_id and fa.film_id = f.film_id
	where f.length < 50
)

-- 15.
select f.title
from film as f
where 2 < ANY (
	select f.film_id
	from rental as r
	join inventory as i on r.inventory_id = i.inventory_id and i.film_id = f.film_id
)

-- 22.
select *
from customer as c
where not exists (
	select MONTH(rental.rental_date)
	from rental
	where rental.customer_id = c.customer_id
	and month(rental_date) not between 6 and 8
) and c.customer_id in (select customer_id from rental)

