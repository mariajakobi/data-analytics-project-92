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