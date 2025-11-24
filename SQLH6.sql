delete from language where name = 'Mandarin';



alter table category
alter column name varchar(50)


alter table customer
add phone varchar(20) not null

alter table film
add creator_staff_id tinyint null

alter table film
add constraint CHK_length
	CHECK (length < 450)

create table reservation(
	reservation_id int not null primary key identity,
	reservation_date date not null default CURRENT_TIMESTAMP,
	end_date date not null,
	customer_id int not null,
	film_id int not null,
	staff_id tinyint null,

	constraint FK_customer_reservation
		foreign key (customer_id)
			references customer(customer_id),
	constraint FK_film_reservation
		foreign key (film_id)
			references film(film_id),
	constraint FK_film_staff
		foreign key (staff_id)
			references staff(staff_id) )

DROP table reservation


-- 15.
alter table staff
add constraint chk_email CHECK (email LIKE '%@%')

update staff
set email = 'herold@gmail.com'
where staff_id = 1

-- 23.

create table rating (
	rating_id int not null primary key identity,
	name varchar(10) not null,
	description text null,
);

insert into rating (name) (select distinct film.rating from film)

select * from rating;

alter table film
add rating_id int null;

alter table film
add constraint fk_film_rating
	foreign key (rating_id)
		references rating(rating_id);

update film
set rating_id = (
	select rating_id
	from rating
	where film.rating = rating.name
)

alter table film
alter column rating_id int not null;

select f.title, r.name from film f
join rating r on r.rating_id = f.rating_id

alter table film
drop constraint DF__film__rating__5812160E

alter table film
drop constraint CHECK_special_rating

alter table film
drop column rating