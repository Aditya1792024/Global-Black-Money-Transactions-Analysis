-- Created new database
create database SQL_project;
use SQL_project;

-- =======================================================================================================================
-- Q1 Provide an overview of the dataset.
select * from BM_Transactions;


-- =======================================================================================================================
/* Q2 Create a result set displaying the total number of transactions, total countries involved, total unique industries, 
total tax haven countries, total people involved, and total financial institutions involved.*/

select count(distinct Transaction_ID) as 'Total Transctions', 
count(distinct Country) as 'Total Countries',
count(distinct Destination_Country) as 'Total Destination Countries',
count(distinct Transaction_Type) as 'Total Transaction types', 
count(distinct Industry) as 'Total Industries involved',
count(distinct Tax_Haven_Country) as 'Total Tax haven countries',
count(distinct Person_Involved) as 'Total Persons involved',
count(distinct Financial_Institution) as 'Total Financial institutions involved'
from dbo.BM_Transactions;


-- ==========================================================================================================================
/*Q3 Compare countries, industries, and transaction types based on total transactions, total amount, amount per transaction, 
money laundering risk score, and transactions per month.*/

-- Country-wise
select Country, 
round(sum(Amount_USD)/1000000000, 2) as 'Total Amount in billions', 
count(Transaction_ID) as 'Total Transactions',
round(cast(count(Transaction_ID) as float)/12, 2) as 'Transactions per month',
round(sum(Amount_USD)/(count(Transaction_ID)*1000000), 2) as 'Amount per Transaction (in millions)',
round(avg(cast(Money_Laundering_Risk_Score as float)),2) as 'Risk Score'
from BM_Transactions
group by Country order by [Total Amount in billions] desc;

-- Industry-wise 
select Industry, 
round(sum(Amount_USD)/1000000000, 2) as 'Total Amount in billions', 
count(Transaction_ID) as 'Total Transactions',
round(cast(count(Transaction_ID) as float)/12, 2) as 'Transactions per month',
round(sum(Amount_USD)/(count(Transaction_ID)*1000000), 2) as 'Amount per Transaction (in millions)',
round(avg(cast(Money_Laundering_Risk_Score as float)),2) as 'Risk Score'
from BM_Transactions
group by Industry order by [Total Amount in billions] desc;

-- Transaction type-wise 
select Transaction_Type, 
round(sum(Amount_USD)/1000000000, 3) as 'Total Amount in billions', 
count(Transaction_ID) as 'Total Transactions',
round(cast(count(Transaction_ID) as float)/12, 2) as 'Transactions per month',
round(sum(Amount_USD)/(count(Transaction_ID)*1000000), 3) as 'Amount per Transaction (in millions)',
round(avg(cast(Money_Laundering_Risk_Score as float)),2) as 'Risk Score'
from BM_Transactions
group by Transaction_Type order by [Total Amount in billions] desc;

-- ==================================================================================================================
-- Q4 Identify countries from and to which above-average black money amounts have been transferred.

/*go
create view view1 as
select Destination_Country as Country, sum(Amount_USD) as 'Total Amount' 
from BM_Transactions
group by Destination_Country;
go

go
create view view2 as
select Country as Country, sum(Amount_USD) as 'Total Amount' 
from BM_Transactions
group by Country;
go*/

-- Countries from where above average black money amount transactioned.
select Country as Country, 
round(sum(Amount_USD)/1000000000, 2) as 'Total Amount in billions',
round(avg(cast(Money_Laundering_Risk_Score as float)), 2) as 'Risk score'
from BM_Transactions
group by Country
having sum(Amount_USD) >= (select avg([Total Amount]) from view2)
order by [Risk score] desc;

-- Countries to which above average black money amount transactioned.
select Destination_Country as Country ,
round(sum(Amount_USD)/1000000000, 2) as 'Total Amount in billions',
round(avg(cast(Money_Laundering_Risk_Score as float)), 2) as 'Risk score'
from BM_Transactions
group by Destination_Country
having sum(Amount_USD) >= (select avg([Total Amount]) from view1)
order by [Risk score] desc;


-- =========================================================================================================================
-- Q5 Determine the total transactions that occurred each month for every country.

with jan as(
select Country, count(Transaction_ID) as 'January' from BM_Transactions
where month(Date) = 1 and year(Date) = 2013 group by Country
),
feb as(
select Country, count(Transaction_ID) as 'February' from BM_Transactions
where month(Date) = 2 and year(Date) = 2013 group by Country
),
mar as(
select Country, count(Transaction_ID) as 'March' from BM_Transactions
where month(Date) = 3 group by Country
),
apr as(
select Country, count(Transaction_ID) as 'April' from BM_Transactions
where month(Date) = 4 group by Country
),
may as(
select Country, count(Transaction_ID) as 'May' from BM_Transactions
where month(Date) = 5 group by Country
),
jun as(
select Country, count(Transaction_ID) as 'June' from BM_Transactions
where month(Date) = 6 group by Country
),
jul as(
select Country, count(Transaction_ID) as 'July' from BM_Transactions
where month(Date) = 7 group by Country
),
aug as(
select Country, count(Transaction_ID) as 'August' from BM_Transactions
where month(Date) = 8 group by Country
),
sep as(
select Country, count(Transaction_ID) as 'September' from BM_Transactions
where month(Date) = 9 group by Country
),
oct as(
select Country, count(Transaction_ID) as 'October' from BM_Transactions
where month(Date) = 10 group by Country
),
nov as(
select Country, count(Transaction_ID) as 'November' from BM_Transactions
where month(Date) = 11 group by Country
),
dec as(
select Country, count(Transaction_ID) as 'December' from BM_Transactions
where month(Date) = 12 group by Country
)
select j.Country as 'Country', j.January as 'January', f.February as 'February', m.March as 'March', ar.April as 'April', 
my.May as 'May', ju.June as 'June', jl.July as 'July', au.August as 'August', s.September as 'September',
o.October as 'October', n.November as 'November', dc.December as 'December'
from jan j
join feb f on j.Country = f.Country
join mar m on j.Country = m.Country
join apr ar on j.Country = ar.Country
join may my on j.Country = my.Country
join jun ju on j.Country = ju.Country
join jul jl on j.Country = jl.Country
join aug au on j.Country = au.Country
join sep s on j.Country = s.Country
join oct o on j.Country = o.Country
join nov n on j.Country = n.Country
join dec dc on j.Country = dc.Country;


-- =======================================================================================================================
-- Q6 Identify the top 2 most preferred transaction types in each industry.

with cte1 as(
select Industry, Transaction_Type as 'Transaction Type', 
COUNT(Transaction_ID) as 'Total Transactions', round(sum(Amount_USD),2) as 'Total Amount',
DENSE_RANK() over (partition by Industry order by sum(Amount_USD) desc) as Ranking,
round(avg(cast(Money_Laundering_Risk_Score as float)), 2) as 'Risk score'
from BM_Transactions
group by Industry, Transaction_Type
)
select Industry, [Transaction Type], [Total Transactions], round([Total Amount]/1000000, 2) as 'Total Amount in millions',
[Risk score]
from cte1
where Ranking in (1, 2)
order by Industry, [Total Transactions] desc;


-- =======================================================================================================================
-- Q7 Determine the most preferred transaction types in the top 5 countries involved in illegal money activities.

with cte2 as(
select Country, round(sum(Amount_USD),2) as 'Total Amount', DENSE_RANK() over (order by sum(Amount_USD) desc) as Ranking 
from BM_Transactions
group by Country
),
cte3 as(
select Country, Transaction_Type as 'Transaction Type', round(sum(Amount_USD),2) as 'Total Amount', 
DENSE_RANK() over (partition by Country order by sum(Amount_USD) desc) as Ranking 
from BM_Transactions
group by Country, Transaction_Type
)
select cte2.Country as Country, cte3.[Transaction Type] as 'Transaction Type' from cte2
join cte3 on cte2.Country = cte3.Country
where (cte2.Ranking between 1 and 5) and (cte3.Ranking in (1,2));


-- =======================================================================================================================
-- Q8 Identify the most preferred destination countries for transferring black money.

with cte4 as(
select Country, Destination_Country as 'Destination Country', count(Transaction_ID) as 'Total Transactions',
round(sum(Amount_USD)/1000000, 2) as 'Total Amount in millions',
DENSE_RANK() over (partition by Country order by sum(Amount_USD) desc) as Ranking
from BM_Transactions
group by Country, Destination_Country
)
select * from cte4
where Ranking <= 3
order by Country, Ranking;


-- =======================================================================================================================
-- Q9 Identify the most preferred tax haven countries.

select Tax_Haven_Country as 'Country Name', 
count(Transaction_ID) as 'Total Transactions',
round(sum(Amount_USD)/1000000000,2) as 'Total Amount in billions'
from BM_Transactions
group by Tax_Haven_Country
order by [Total Amount in billions] desc;


-- =======================================================================================================================
-- Q10 List the top 200 individuals involved in high-amount black money transactions.

select top 200 Person_Involved as 'Person Involved', count(Transaction_ID) as 'Total Transactions', 
round(sum(Amount_USD)/1000000, 2) as 'Total Amount in millions',
round((sum(Amount_USD)/count(Transaction_ID))/1000000, 2) as 'Amount per transaction in miilions'
from BM_Transactions
group by Person_Involved
order by [Total Amount in millions] desc;



-- =======================================================================================================================
-- Q11 List the top 2 transaction types based on the total number of shell companies involved per transaction.

with shell1 as(
select Transaction_Type as 'Transaction Types', 
round(cast(sum(Shell_Companies_Involved) as float)/cast(count(Transaction_ID) as float), 2) 
as 'Shell companies involved per transaction',
DENSE_RANK() over (order by round(cast(sum(Shell_Companies_Involved) as float)/cast(count(Transaction_ID) as float), 2) desc) as Ranking
from BM_Transactions
group by Transaction_Type
)
select [Transaction Types], [Shell companies involved per transaction] 
from shell1
where Ranking <= 2;


-- =======================================================================================================================
-- Q12 Filter out transaction records which are not reported by authority yet.

select * from BM_Transactions
where Reported_by_Authority = 0;

-- =======================================================================================================================
-- Q13 Give country-wise percentage of reported transactions.

/*go
create view view3 as
select Country, count(Transaction_ID) as 'Reported Transactions' 
from BM_Transactions
where Reported_by_Authority = 1
group by Country;
go */

select Country, 
round(
(cast([Reported Transactions]as float)/(select count(Transaction_ID) from BM_Transactions where Reported_by_Authority=1))*100, 2 
) as '% of reported transactions'
from view3;



-- =========================================================================================================================
-- Some extra queries written for practicing purposes.
-- =========================================================================================================================


-- Top 3 industries having higher shell companies involvement per transaction
with shell2 as(
select Industry, 
round(cast(sum(Shell_Companies_Involved) as float)/cast(count(Transaction_ID) as float), 2) 
as 'Shell companies involved per transaction',
DENSE_RANK() over (order by round(cast(sum(Shell_Companies_Involved) as float)/cast(count(Transaction_ID) as float), 2) desc) as Ranking
from BM_Transactions
group by Industry
)
select Industry, [Shell companies involved per transaction] 
from shell2
where Ranking <= 3;




-- percent change in total transaction for each country in 2013
with jant as(
select Country, count(Transaction_ID) as 'Total Transactions', sum(Amount_USD) as 'Total Amount' from BM_Transactions
where MONTH(Date) = 1 and year(Date) = 2013 group by Country
),
dect as(
select Country, count(Transaction_ID) as 'Total Transactions', sum(Amount_USD) as 'Total Amount' from BM_Transactions
where MONTH(Date) = 12 group by Country
)
select j.Country as 'Country',
round((cast(d.[Total Transactions] - j.[Total Transactions] as float)/j.[Total Transactions])*100, 2) 
as 'Percent change in Total Transactions',
round((cast(d.[Total Amount] - j.[Total Amount] as float)/j.[Total Amount])*100, 2) 
as 'Percent change in Total Black Money Transactioned'
from jant j
join dect d on j.Country = d.Country
order by [Percent change in Total Black Money Transactioned] desc;

select DATETRUNC(month, Date) as 'Month', count(Transaction_ID) as 'Total Transactions'
from BM_Transactions
group by DATETRUNC(month, Date)
order by DATETRUNC(month, Date);
 


/* 
select Country, Year(Date) as "Year", count(Transaction_ID) from dbo.BM_Transactions
where Country = 'India' and Year(Date) = 2013
group by Country, Year(Date); 
*/


select Industry, round(AVG(cast(Money_Laundering_Risk_Score as float)),3) as 'Average ML Risk Score' 
from BM_Transactions
group by Industry order by AVG(cast(Money_Laundering_Risk_Score as float)) desc;


select Transaction_Type as Type, round(AVG(cast(Money_Laundering_Risk_Score as float)),3) as 'Average ML Risk Score'  
from BM_Transactions
group by Transaction_Type order by AVG(cast(Money_Laundering_Risk_Score as float)) desc;


/*
GO
create procedure TransactionCount
@MoneySource varchar(15)
as
begin
	select Industry, COUNT(Transaction_ID) as 'Total Transactions' 
	from dbo.BM_Transactions
	where Source_of_Money = @MoneySource
	group by Industry
	order by [Total Transactions] desc;
end;
GO
*/

-- Industry-wise Total Transactions which have legal source of money
exec TransactionCount @MoneySource = 'Legal';

-- Industry-wise Total Transactions which have illegal source of money
exec TransactionCount @MoneySource = 'Illegal';










