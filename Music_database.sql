-- Question Set 1 - Easy 

/* Q1: Who is the senior most employee based on job title? */

select first_name, last_name, levels
from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country, count(*) as count 
from invoice
group by billing_country
order by billing_country desc
limit 1;


/* Q3: What are top 3 values of total invoice? */

select total
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city
 we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as total 
from invoice
group by billing_city
order by total desc
limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, sum(total) as total
from customer c
join invoice i on c.customer_id=i.customer_id
group by customer_id
order by total desc
limit 1 
;



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email, first_name, last_name 
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_line_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name="rock"
order by email asc;



/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select *
from artist;


select ar.name, count(track_id) as count 
from artist ar 
join album al on al.artist_id= ar.artist_id
join track t on t.album_id= al.album_id
where track_id in(
select t.track_id
from track t
join genre g on g.genre_id= t.genre_id
where g.genre_id=1)
group by name
order by count desc
limit 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds
from track
where milliseconds > (
    select avg(milliseconds) as average
    from track
    )
order by milliseconds desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and 
total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with cte as(
select  ar.artist_id,ar.name, sum(i.unit_price * i.quantity) as total_sales
from invoice_line i
join track t on i.track_id=t.track_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id=a.artist_id
group by artist_id, name
order by total_sales desc
limit 1) 

select ct.name, c.first_name, c.last_name ,sum(il.unit_price * il.quantity) as total_sales
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join cte ct on ct.artist_id= a.artist_id
group by 1,2,3
order by total_sales desc;



/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */


with cte as(
select i.billing_country,g.name, sum(quantity) as total_purchase,
  row_number() over(partition by i.billing_country order by billing_country asc) as rn  
from invoice i   
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by billing_country, g.name
order by i.billing_country asc, total_purchase desc)

select billing_country, name, total_purchase
from cte
where rn<=1;


with cte as(
select i.billing_country,g.name, sum(quantity) as total_purchase,
  row_number() over(partition by i.billing_country order by count(quantity) desc) as rn  
from invoice i   
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by billing_country, g.name
order by i.billing_country asc, total_purchase desc)

select billing_country, name, total_purchase
from cte 
where rn<=1;

select i.billing_country,g.name, sum(quantity) as total_purchase,
  row_number() over(partition by i.billing_country order by count(quantity) desc) as rn  
from invoice i   
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by billing_country, g.name
order by i.billing_country asc, total_purchase desc;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


with cte as(
select i.billing_country, c.first_name, c.last_name, sum(quantity*unit_price) as total_purchase,
row_number() over(partition by billing_country order by sum(quantity*unit_price) desc) as rn
from invoice i
join invoice_line il on il.invoice_id = i.invoice_id
join customer c on c.customer_id = i.customer_id
group by billing_country, first_name, last_name
order by billing_country asc, total_purchase desc)

select billing_country, first_name, last_name, round(total_purchase,2) as total_purchase
from cte 
where rn<=1;




