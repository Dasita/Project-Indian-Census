select * from ProjectCensus.dbo.Data1;
select * from ProjectCensus.dbo.Data2;

--number of rows in our dataset

select count(*) from ProjectCensus.dbo.Data1;
select count(*) from ProjectCensus.dbo.Data2;


--dataset for Jharkhand and Bihar

select * from ProjectCensus.dbo.Data1 where State='Jharkhand' or State='Bihar';

--Or we can use IN as well

select * from ProjectCensus.dbo.Data1 where State in ('Jharkhand','Bihar');


--deleting population column from Data1

alter table ProjectCensus.dbo.Data1
drop column Population;


--calculating overall population of India

select sum(Population) Population from ProjectCensus.dbo.Data2;

--to calculate Average Literacy rate

select avg(Literacy)*100 Average_Literacy_rate from ProjectCensus.dbo.Data2;

--to calculate Average Growth rate by state

select State,avg(Growth)*100 Average_Growth_rate from ProjectCensus.dbo.Data1 group by state;

--average sex ratio

select State,round(avg([Sex-Ratio]),0) Average_Sex_ratio from ProjectCensus.dbo.Data1
group by state order by 2 desc;

--average literacy rate

select State,round(avg(Literacy),0) Average_Literacy_rate from ProjectCensus.dbo.Data1
group by state order by 2 desc;


--the main difference between WHERE and HAVING is, that WHERE is used to filter rows 
--whereas HAVING is used in aggregate results.

select State,round(avg(Literacy),0) Average_Literacy_rate from ProjectCensus.dbo.Data1
group by state having round(avg(Literacy),0)>90 order by 2 desc;

--top 3 state showing highest growth ratio

select top 3 State,round(avg(Growth)*100,0) Average_Growth_rate from ProjectCensus.dbo.Data1 group by state order by 2 desc;


--using limit function is used in mysql not in mssql server

--select State,round(avg(Growth)*100,0) Average_Growth_rate from ProjectCensus.dbo.Data1
--group by state order by 2 desc limit 3;


--bottom 3 state showing lowest sex ratio

select top 3 State,round(avg([Sex-Ratio]),0) Average_Sex_ratio from ProjectCensus.dbo.Data1
group by state order by 2 desc;


--top and bottom 3 states in literacy rate 

--creating a temporary table for top states
drop table if exists topstates;   --Delete the table if it exists
create table topstates
(State nvarchar(255),
Top_States float
)

--inserting our top result into the newly created table
insert into topstates
select State,round(avg(Literacy),0) Average_Literacy_rate from ProjectCensus.dbo.Data1
group by state;

select * from topstates order by 2 desc;

--creating a temporary table for bottom states
drop table if exists bottomstates;   --Delete the table if it exists
create table bottomstates
(State nvarchar(255),
Bottom_States float
)

--inserting our top result into the newly created table
insert into bottomstates
select State,round(avg(Literacy),0) Average_Literacy_rate from ProjectCensus.dbo.Data1
group by state;

select * from bottomstates order by 2 asc;

--combining the results
select * from (
select top 3 * from topstates order by 2 desc) a

union

select * from (
select top 3 * from bottomstates order by 2 asc) b order by 2 desc;

--states starting with letter a or b

select distinct state from ProjectCensus.dbo.Data1 where lower(state) like 'a%'
or lower(state) like 'b%';

--states starting with letter a and ending with letter h

select distinct state from ProjectCensus.dbo.Data1 where lower(state) like 'a%'
and lower(state) like '%h';





--joining both table 
--calculating the number of males and females in a particular state

select d.State,sum(d.Males) Male,sum(d.Females) Female from
(select District,State,round(Population/(Sex_ratio+1),0) Males,round((Population*Sex_ratio)/(Sex_ratio+1),0) Females from 
(select a.District,a.State,[sex-ratio]/1000 Sex_ratio,Population from ProjectCensus.dbo.Data1 a
inner join
ProjectCensus.dbo.Data2 b on a.District=b.District) c) d 
group by d.State order by 3 desc;


--calculating the total literacy rate of different states

select State,sum(Literate_People) Literate_People,sum(Illiterate_People) Illiterate_People from 
(select District,State,Population,round((Literacy_ratio*Population),0) Literate_People,round((1-Literacy_ratio)*Population,0) Illiterate_People from 
(select a.District,a.State,b.Literacy Literacy_ratio,Population from ProjectCensus.dbo.Data1 a
inner join
ProjectCensus.dbo.Data2 b on a.District=b.District) c) d 
group by State;


--Total population in previous census statewise
--population versus area, how much the area is reduced statewise
--Now, since we need to calculate Area/Pop, we will join the two tables, for that we will create a common key


select (g.Total_area/g.Previous_pop) Previous_area,g.Total_area/g.Current_pop Current_area from
(select x.*,y.Total_area from
(select '1' as keyy,f.* from
(select sum(e.Previous_pop) Previous_pop,sum(e.Current_pop) Current_pop from
(select d.State,sum(d.Previous_pop) Previous_pop,sum(d.Population) Current_pop from
(select District,State,round(Population/(1+Growth_rate),0) Previous_pop,Population from 
(select a.District,a.State,a.Growth Growth_rate,Population from ProjectCensus.dbo.Data1 a
inner join
ProjectCensus.dbo.Data2 b on a.District=b.District) c) d
group by d.State) e) f) x
inner join
(select '1' as keyy,n.* from
(select sum([Area (km2)]) Total_area from ProjectCensus.dbo.Data2) n) y
on x.keyy=y.keyy) g;



--window functions
--top 3 districts from each state with highest literacy rate

select a.* from
(select District,State,Literacy,rank() over(partition by State order by Literacy desc) rnk from
ProjectCensus.dbo.Data1) a where a.rnk in(1,2,3) order by State;





