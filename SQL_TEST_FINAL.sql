

with obory as (
	select ff.fid 
	from z_field_ford ff
	join z_field_of_science fos on ff.sid = fos.sid
	where fos.name = 'Natural sciences'
),
articles_in_Q1 as (
	select distinct a.aid, yfj.fid
	from z_article a
	join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
	where yfj.fid in (select * from obory) and yfj.ranking = 'Q1'
),
articles_by_homolce as (
	select distinct a.aid, a.fid
	from articles_in_Q1 a
	join z_article_institution ai on a.aid = ai.aid
	join z_institution i on ai.iid = i.iid
	where i.name = 'Nemocnice Na Homolce'
),
articles_with_count as (
	select distinct ah.aid, ah.fid, COUNT(aa.rid) ac
	from articles_by_homolce ah
	join z_article_author aa on ah.aid = aa.aid
	group by ah.aid, ah.fid
),
filtered as (
	select ff.fid, ff.name, ISNULL(awc.ac, 0) avg_count_prep
	from obory o
	join z_field_ford ff on o.fid = ff.fid
	left join articles_with_count awc on o.fid = awc.fid
)
--select o.fid, ff.name, AVG(cast(awc.ac as float)) as prumerny_pocet_autorů

--join z_field_ford ff on ff.fid = awc.fid
select f.fid, f.name, AVG(cast(f.avg_count_prep as float))
from filtered f
group by f.fid;

-----------

with articles_in_decil as (
	select distinct a.aid, a.year
	from z_article a
	join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
	where yfj.ranking = 'Decil'
),
articles_by_year as (
	select ad.aid, ad.year
	from articles_in_decil ad
	where ad.year between 2018 and 2020
),
all_articles as (
	select i.iid, ay.year
	from articles_by_year ay
	join z_article_institution ai on ay.aid = ai.aid
	join z_institution i on i.iid = ai.iid
	where i.town like '%Olomouc%' or i.town like '%Ostrava%'
),
filtered as (
select distinct i.iid, COUNT(distinct aa.year) c
from all_articles aa
join z_institution i on aa.iid = i.iid
group by i.iid
having COUNT(distinct aa.year) = 3
)
select *
from z_institution i
join filtered f on f.iid = i.iid

------

with instituce_agro as (
	select i.iid
	from z_institution as i
	where i.name LIKE '%agro%'
),
articles_in_agro as (
	select distinct ai.aid
	from z_article_institution ai
	join instituce_agro ia on ai.iid = ia.iid
),
authors_in_art as (
	select aa.rid, COUNT(aia.aid) pocet
	from z_article_author aa
	join articles_in_agro aia on aia.aid = aa.aid
	group by aa.rid
	having COUNT(aia.aid) >= 2
)
select *
from z_author a
where a.rid in (select rid from authors_in_art)