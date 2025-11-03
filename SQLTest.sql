/*
2. Vypište všechny články v časopisech, které byly (v roce vydání článku)
   hodnoceny jako Decil (z_year_field_journal.ranking='Decil') a u kterých
   je uvedena instituce 'Vysoká škola báňská - Technická univerzita Ostrava'.
   Vypište aid a název článku, výsledek bude setřízen dle aid vzestupně.
*/
select distinct a.aid, a.name
from z_article as a
         join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
         join z_article_institution ai on a.aid = ai.aid
         join z_institution i on i.iid = ai.iid
where yfj.ranking = 'Decil'
  and i.name = N'Vysoká škola báňská - Technická univerzita Ostrava'

/*
Tento dotaz najde **unikátní články** (`DISTINCT A.aid, A.name`), které splňují **dvě podmínky najednou**:
1.  Jejich časopis byl v daném roce hodnocen jako 'Decil' (`YFJ.ranking = 'Decil'`).
2.  Jsou spojeny s VŠB (I.name = 'Vysoká škola báňská...'`).

Aby to zjistil, musí spojit (`JOIN`) čtyři tabulky:
* `Article` (pro název) $\rightarrow$ `Year_Field_Journal` (pro ranking)
* `Article` (pro název) $\rightarrow$ `Article_Institution` (vazba) $\rightarrow$ `Institution` (pro název instituce)

[cite_start]`DISTINCT` je nutný, protože jeden článek mohl dostat 'Decil' ve více oborech[cite: 112, 113], tak aby se ve výsledku neobjevil vícekrát. Nakonec se vše seřadí podle `aid`.
*/


/*
10. Vypište pro jednotlivé obory FORD nejvyšší počet autorů na jednom článku
    (takových článků může být více). Neuvažujte obory FORD s nulovým počtem článků.
    Vypište fid a název oboru FORD, a.aid článku a počet autorů článku.
    Setřiďte podle počtu autorů sestupně.
*/

with cnt as
    (select COUNT(distinct aa.rid) pocet_autoru, a.aid, ff.fid, ff.name
             from z_article a
                      join z_article_author aa on a.aid = aa.aid
                      join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                      join z_field_ford ff on yfj.fid = ff.fid
             group by a.aid, ff.fid, ff.name)
select *
from cnt as ct
where ct.pocet_autoru = (select MAX(cnt.pocet_autoru)
                         from cnt
                         where ct.fid = cnt.fid)

-- 3.
-- Nalezněte obory FORD, ve kterých v roce 2017 nikdy nepublikovaly instituce z Brna.
-- Setřiďte výsledek podle fid.


select *
from z_field_ford ff1
where ff1.fid not in (
select distinct yfj.fid
from z_article a
join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
join z_article_institution ai on a.aid = ai.aid
join z_institution i on ai.iid = i.iid
where i.town = 'Brno' and a.year = 2017
    )

-- 4.
-- Nalezněte instituce, které mají v názvu slovo "chemie" a v roce 2017 měly více článků
-- v prvním decilu (z_year_field_journal.ranking='Decil') než v roce 2020.

with clanky_2017 as (
    select i.iid, i.name, COUNT(distinct a.aid) pc
    from z_article a
    join z_article_institution ai on ai.aid = a.aid
    join z_institution i on ai.iid = i.iid
    join z_year_field_journal yfj on yfj.jid = a.jid and a.year = yfj.year
    where i.name like '%chemie%' and a.year = 2017 and yfj.ranking = 'Decil'
    group by i.iid, i.name
), clanky_2020 as (
    select i.iid, i.name, COUNT(distinct a.aid) pc
    from z_article a
    join z_article_institution ai on ai.aid = a.aid
    join z_institution i on ai.iid = i.iid
    join z_year_field_journal yfj on yfj.jid = a.jid and a.year = yfj.year
    where i.name like '%chemie%' and a.year = 2020 and yfj.ranking = 'Decil'
    group by i.iid, i.name
)
select *
from z_institution i
join clanky_2017 on clanky_2017.iid = i.iid
join clanky_2020 on clanky_2020.iid = i.iid
where clanky_2020.pc < clanky_2017.pc

/*
Nalezněte autory článků, jejichž instituce jsou z Prahy, kteří mají o 60 takových článků v časopisech hodnocených 'Decil' víc,
než je průměrný počet takových článků všech takových autorů. Vypište rid a jméno autora a počet takových článků,
výsledek bude setřízený dle počtu článků sestupně
*/
with articles_decil as
         (select aa.rid, COUNT(distinct aa.aid) as ac
          from z_article_institution ai
                   join z_institution i on i.iid = ai.iid
                   join z_article a on ai.aid = a.aid
                   join z_year_field_journal yfj on yfj.jid = a.jid and a.year = yfj.year
                   join z_article_author aa on a.aid = aa.aid
          where i.town = 'Praha'
            and yfj.ranking = 'Decil'
          group by aa.rid)
select distinct a.rid, a.name, ad.ac
from articles_decil ad
    join z_article_author aa on ad.rid = aa.rid
    join z_author a on a.rid = aa.rid
    where ((select AVG(art.ac) from articles_decil art) + 60) < ad.ac
    order by ad.ac desc

/*
Nalezněte instituce z Brna, které publikují články v oborech FORD, vědní oblast je 'Engineering and Technology' v letech 2019-2021.
Výsledek obsahuje instituce, které publikují:
 - články pouze v jednom oboru FORD této vědní oblasti
 - alespoň 10 článků celkem (bez omezení na rok a obor FORD)
Vypiš iid a název instituce, počet článků s omezením i počet článků celkem
*/
with fields as (select ff.fid
                from z_field_ford ff
                         join z_field_of_science fos on fos.sid = ff.sid
                where fos.name = 'Engineering and Technology'),
     institutions as (select distinct i.iid, i.name
                      from z_article_institution ai
                               join z_institution i on ai.iid = i.iid
                      where i.town = 'Brno'),
     articles as (select i.iid, COUNT(distinct ai.aid) ac
                  from institutions i
                           join z_article_institution ai on ai.iid = i.iid
                  group by i.iid),
    science as (select ai.iid, count(distinct a.aid) eng_ac, count(distinct yfj.fid) field_count
                from z_article_institution ai
                join z_article a on a.aid = ai.aid
                join z_year_field_journal yfj on a.jid = yfj.jid and yfj.year = a.year
                join fields f on yfj.fid = f.fid
                where ai.iid in (select iid from institutions) and a.year between 2019 and 2021
                group by ai.iid
                    )
select i.iid, name, eng_ac, ac
from institutions i
join articles a on i.iid = a.iid
join science s on s.iid = i.iid
where a.ac >= 10 and s.field_count = 1

/*
Nalezněte osoby s nejvyšším počtem článků v časopisech hodnocených v decilu, kde instituce článku sídlí v Hradci Králové.
Vypište rid a jméno osoby i počet článků v decilu
*/
with articles_in_decil as (select distinct a.aid
                           from z_article a
                                    join z_year_field_journal yfj on a.jid = yfj.jid and yfj.year = a.year
                                    join z_article_institution ai on ai.aid = a.aid
                                    join z_institution i on ai.iid = i.iid
                           where yfj.ranking = 'Decil'
                             and i.town = N'Hradec Králové'),
lidi as (select a.rid, a.name, COUNT(ad.aid) as ac
from z_article_author aa
join z_author a on aa.rid = a.rid
join articles_in_decil ad on aa.aid = ad.aid
group by a.rid, a.name)
select l.rid, l.name, l.ac
from lidi as l
where l.ac = (select MAX(ac) from lidi)



