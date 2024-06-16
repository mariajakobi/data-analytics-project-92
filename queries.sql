with seller_name as
	(select	employee_id,
	concat(employees.first_name, ' ', employees.last_name) as seller
	from employees)
select
seller_name.seller as seller,
round(sum(products.price * sales.quantity),0) as income,
count(sales.sales_id) as operations
from sales
inner join products on products.product_id = sales.product_id
inner join seller_name on seller_name.employee_id = sales.sales_person_id
group by seller_name.seller
order by sum(products.price * sales.quantity) desc 
limit 10;

--в таблице отражается количество сделок, совершенных подавцами и общая сумма выручки. отражены первые 10

with seller_name as
	(select	employee_id,
	concat(employees.first_name, ' ', employees.last_name) as seller
	from employees),
	income_all as
	(select
	sales.sales_person_id, 
	round(sum(products.price * sales.quantity), 0) as income
	from sales
	inner join products on products.product_id = sales.product_id
	group by sales.sales_person_id)
select
seller_name.seller as seller,
income_all.income as income
from income_all
inner join seller_name on seller_name.employee_id = income_all.sales_person_id
where income_all.income < (select round(avg(income_all.income), 0) as avg_inc from income_all)
group by seller_name.seller, income_all.income
order by income_all.income desc 
;

--сначала формируется временная таблица для объединения имени и фамилии, затем соединяются таблицы продажи и продукт для расчета стоимости, также присоединятемя таблица с именем. так получаем колонку с именем продавца и его выручкой

with seller_name as
	(select	employee_id,
	concat(employees.first_name, ' ', employees.last_name) as seller
	from employees)
select
sn.seller as seller,
to_char(s.sale_date, 'Day') as day_of_week,
round(sum(p.price * s.quantity),0) as income
from sales s
inner join products p  on s.product_id = p.product_id
inner join seller_name sn on sn.employee_id = s.sales_person_id
group by sn.seller, to_char(s.sale_date, 'Day')
order by sn.seller
;

--формируем ьаблицу с именами продавцов, затем соединяем таблицы для получеия выручки по каждому продавцу и группируем результат по продавцу и дням недели


select case 
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
	end as age_category,
count(distinct s.customer_id) as age_count
from sales s 
inner join customers c on s.customer_id = c.customer_id 
group by age_category
order by age_category asc
;
--используя case формируем новый столбец указываем критерии , затем считаем количество соответствующее критериям

select
to_char(s.sale_date, 'YYYY-MM') as selling_month,
count(distinct s.customer_id) as total_customers,
round(sum(p.price*s.quantity),0) as income
from sales s 
inner join customers c on s.customer_id = c.customer_id
inner join products p on s.product_id = p.product_id 
group by to_char(s.sale_date, 'YYYY-MM')
order by to_char(s.sale_date, 'YYYY-MM')
;
--собираем данные по покупателям, общая сумма получается при умножении количество на цену товара, при этом данные группируются по покупателям и дате. также расчитывается общее количество покупателей по месяцам

with first_date as
	(select 
	distinct s.customer_id as customer_id,
	first_value (s.sale_date) over (partition by s.customer_id order by s.sale_date) as first_sale_date
	from sales s 
	inner join products p on s.product_id = p.product_id
	), 
	customer_name as 
	(select
	customer_id,
	concat(first_name, ' ', last_name) as customer
	from customers)
select
distinct cn.customer as customer,
s.sale_date as sale_date ,
concat(employees.first_name, ' ', employees.last_name) as seller
from sales s
left join customer_name cn on cn.customer_id = s.customer_id
inner join products p on s.product_id = p.product_id
inner join employees on employees.employee_id = s.sales_person_id 
left join first_date fd on s.customer_id = fd.customer_id
where s.sale_date = fd.first_sale_date and s.quantity * p.price = 0
order by customer
;
--сначала создаются временные таблицы, в одной создаются имена покупателей в другой продажи с датой первой покупки, далее таблицы объединяются по покупателю и первой покупке с условием акциию





