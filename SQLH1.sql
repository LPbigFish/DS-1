-- 1.
SELECT email from customer where active is not null
-- 2.
select title,description from film where rating = 'G' order by title desc
-- 3.
select * from payment where payment_date >= '2006-01-01' AND amount < 2
-- 4.
select description from film where rating in ( 'G', 'PG' )
-- 5.
select description from film where rating in ( 'G', 'PG', 'PG-13' )
-- 6.
select description from film where rating not in ( 'G', 'PG', 'PG-13' )
-- 7.
select * from film where length > 50 AND rental_duration in ( 3, 5 )
-- 8.
select title from film where (title like '%RAINBOW%') or (title like '%TEXAS%')
-- 9.
select title from film where (description like '%And%') and (length between 80 and 90) and (rental_duration % 2) = 1
-- 10.
select distinct special_features from film where (replacement_cost between 14 and 16) order by special_features
-- 11.
select * from film where (rental_duration < 4 and rating != 'PG') or (rental_duration >= 4 and rating = 'PG')
-- 12.
select * from address where postal_code is not null
-- 13.
select distinct customer_id from rental where return_date is null
-- 14.
select YEAR(payment_date) as 'year', MONTH(payment_date) as 'month', DAY(payment_date) as 'day' from payment
-- 15.
select * from film where LEN(title) != 20
-- 16.
select rental_id, DATEDIFF(minute,rental_date, return_date) as rental_duration from rental
-- 17.
select customer_id, CONCAT(first_name, ' ', last_name) as full_name from customer
-- 18.
select coalesce(postal_code, '(prázdné)') from address
-- 19.
select concat(rental_date, '-', return_date) from rental where return_date is not null