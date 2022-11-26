

CREATE TABLE gold_signup(userid integer,gold_signup_date date);

INSERT INTO 
gold_signup(userid,gold_signup_date)
VALUES (1,'09-22-2017'),(2,'08-15-2017'),(3,'04-21-2017'),(6,'02-10-2017');

SELECT * FROM gold_signup

CREATE TABLE users(userid integer,signup_date date);

INSERT INTO 
users(userid,signup_date)
VALUES (1,'09-2-2014'),(2,'01-15-2015'),(3,'04-11-2014'),(4,'02-1-2017');

SELECT * FROM users

CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price)
VALUES 
(1,'p1',980),
(2,'p2',900),
(3,'p3',330),
(4,'p4',880),
(5,'p5',1180);

CREATE TABLE sales(userid integer,created_date date,product_id integer);

INSERT INTO sales(userid,created_date,product_id)
VALUES 
(1,'04-19-2017',2),(3,'12-18-2019',1),(2,'07-20-2020',3),(1,'10-23-2019',2),
(1,'03-19-2018',5),(3,'12-20-2016',2),(1,'11-09-2016',1),(1,'05-20-2016',6),
(2,'09-24-2017',4),(4,'11-03-2011',5),(4,'01-01-2015',4),(3,'12-07-2017',1),
(2,'09-10-2018',3),(3,'12-15-2016',2),(4,'11-08-2017',2),(3,'11-10-2016',5);

SELECT * FROM sales
SELECT * FROM product



1. What is the total amount each customer spent on zomato?

SELECT a.userid,sum(b.price) total_amount_spent from sales a inner join product b on a.product_id=b.product_id
group by a.userid

2. How many days has each customer visited the zomato?

select userid,COUNT(distinct created_date) total_days from sales group by userid

3. What was the first product purchesed by each costomer?

select * ,rank() over(partition by userid order by created_date) rnk from sales

select * from (select * ,rank() over(partition by userid order by created_date) rnk from sales) a where rnk=1

4. What is the most purchesed product on the menu and how many times was it purchesed by all customer?

select product_id,count(product_id) cnt from sales group by product_id order by count(product_id) desc

select userid,count(product_id) cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid

5. Which item is most popular for each customer?

select * from
(select *,rank() over (partition by userid order by product_cnt desc) rnk from
(select userid,product_id,count(product_id) product_cnt from sales group by userid,product_id)a)b where rnk=1



6. which item was purchesed first by the customer after they become a member?

select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
gold_signup b on a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk=1


7. Which item was purchesed just before the customer become a member?

select * from
(select c.*,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
gold_signup b on a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1


8. What is the total order and amount spent for each member before thry become a member?

select c.*,d.price from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
gold_signup b on a.userid=b.userid and create d_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id


9. If buying each product generates points for example 5Rs= 2 zomato points and each product id has different purchesing points for eg for p1 5Rs = 1 zomato points
    for p2 10Rs = 5 zomato points and p3 5Rs = 1 zomato point

--Total price For each product_id
select c.userid,c.product_id,sum(price) total_price from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id

select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
 when product_id=4 then 3 when product_id=5 then 4 else 0 end as points from
(select c.userid,c.product_id,sum(price) total_price from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d

-- for product_id =1 1point=5Rs  for product_id =2 1point=2Rs  for product_id =3 1point=5Rs  for product_id =4 1point=3Rs  for product_id =5 1point=4Rs

select e.*,total_price/points total_point_earn from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
 when product_id=4 then 3 when product_id=5 then 4 else 0 end as points from
(select c.userid,c.product_id,sum(price) total_price from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d) e

--For each customer total earn ponts

select userid,sum(total_point_earn) from
(select e.*,total_price/points total_point_earn from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 
 when product_id=4 then 3 when product_id=5 then 4 else 0 end as points from
(select c.userid,c.product_id,sum(price) total_price from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id) d) e)f group by userid
 
