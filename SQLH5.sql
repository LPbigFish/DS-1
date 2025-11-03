/*
1. Vypište všechny autory článků na kterých jsou uvedeny instituce z Ostravy 
   (z_institution.name obsahuje slovo Ostrava, jméno města může být 
   např. Ostrava nebo Ostrava-Poruba).
   Vypište rid a jméno autora, výsledek setřiďte dle rid vzestupně.
*/


select distinct a.rid, a.name
from z_author a
         join z_article_author aa on a.rid = aa.rid
         join z_article_institution ai on aa.aid = ai.aid
         join z_institution i on ai.iid = i.iid
where i.town like 'Ostrava%'
order by a.rid


/*
2. Vypište všechny články v časopisech, které byly (v roce vydání článku) 
   hodnoceny jako Decil (z_year_field_journal.ranking='Decil') a u kterých 
   je uvedena instituce 'Vysoká škola báňská - Technická univerzita Ostrava'.
   Vypište aid a název článku, výsledek bude setřízen dle aid vzestupně.

*/


select distinct a.aid, a.name
from z_article a
         join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
where yfj.ranking = 'Decil'
  and exists(select 1
             from z_institution i
                      join z_article_institution ai on i.iid = ai.iid and a.aid = ai.aid
             where i.name = 'Vysoká škola báňská - Technická univerzita Ostrava')
order by a.aid


/*
10. Vypište pro jednotlivé obory FORD nejvyšší počet autorů na jednom článku 
    (takových článků může být více). Neuvažujte obory FORD s nulovým počtem článků.
    Vypište fid a název oboru FORD, a.aid článku a počet autorů článku.
    Setřiďte podle počtu autorů sestupně.
*/

with cte as
         (select COUNT(distinct aa.rid) as cnt, ff.fid, ff.name, a.aid
          from z_article a
                   join z_article_author aa on a.aid = aa.aid
                   join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                   join z_field_ford ff on ff.fid = yfj.fid
          group by a.aid, ff.fid, ff.name)
select *
from cte as ct
where ct.cnt = (select max(cte.cnt)
                from cte
                where ct.fid = cte.fid)


-- 3.
-- Nalezněte obory FORD, ve kterých v roce 2017 nikdy nepublikovaly instituce z Brna.
-- Setřiďte výsledek podle fid.
select *
from z_field_ford
where z_field_ford.fid NOT IN (select distinct zyfj.fid
                               from z_institution zi
                                        join dbo.z_article_institution zai on zi.iid = zai.iid
                                        join dbo.z_article za on zai.aid = za.aid
                                        join z_year_field_journal zyfj on za.jid = zyfj.jid and za.year = zyfj.year
                               where zi.town = 'Brno'
                                 and zyfj.year = 2017
                               group by zyfj.fid)
order by fid;



-- 4.
-- Nalezněte instituce, které mají v názvu slovo "chemie" a v roce 2017 měly více článků
-- v prvním decilu (z_year_field_journal.ranking='Decil') než v roce 2020.
with clanky_2017 as (select z_institution.iid, count(distinct za.aid) as pocet_clanku
                     from z_institution
                              join dbo.z_article_institution zai on z_institution.iid = zai.iid
                              join dbo.z_article za on zai.aid = za.aid
                              join z_year_field_journal zyfj on za.jid = zyfj.jid and za.year = zyfj.year
                     where zyfj.year = 2017
                       and zyfj.ranking = 'Decil'
                     group by z_institution.iid),
     clanky_2020 as (select z_institution.iid, count(distinct za.aid) as pocet_clanku
                     from z_institution
                              join dbo.z_article_institution zai on z_institution.iid = zai.iid
                              join dbo.z_article za on zai.aid = za.aid
                              join z_year_field_journal zyfj on za.jid = zyfj.jid and za.year = zyfj.year
                     where zyfj.year = 2020
                       and zyfj.ranking = 'Decil'
                     group by z_institution.iid)
select *
from z_institution zi
         left join clanky_2017 on zi.iid = clanky_2017.iid
         left join clanky_2020 on zi.iid = clanky_2020.iid
where name like '%chemie%'
  and clanky_2017.pocet_clanku > clanky_2020.pocet_clanku;





