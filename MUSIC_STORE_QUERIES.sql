/* Q1: Who is the senior most employee based on job title? */

select *from employee
order by levels desc
limit 1





/* Q2: Which countries have the most Invoices? */

select count(*) as c, billing_country from invoice
group by billing_country
order by c desc;





/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc
limit 3;





/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as invoice_totals, billing_city from invoice
group by billing_city
order by invoice_totals desc
limit 3;





/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total)
from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(invoice.total) desc
limit 3;





/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct first_name, last_name, email
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in (
	select track_id from track
	join genre on genre.genre_id = track.genre_id
	where genre.name = 'Rock')
order by email;

						"OR"

select distinct first_name, last_name, email
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
order by email;





/* Q7: Let's invite the artists who have written the most rock songs in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
	where genre.name = 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;





/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track
where milliseconds>
	(select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;





/* Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

with best_selling_artist as
(
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as total_spent
from invoice as i
join customer as c on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id = il.track_id
join album as alb on alb.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;





/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as
(
	select count(quantity) as purchases, c.country, g.name, g.genre_id,
	row_number() over(partition by c.country order by count(il.quantity)desc) as row_no
	from invoice_line as il
	join track as t on t.track_id = il.track_id
	join genre as g on g.genre_id = t.genre_id
	join invoice as i on i.invoice_id = il.invoice_id
	join customer as c on c.customer_id = i.customer_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where row_no<=1


						"OR"


with recursive
	sales_per_country as
		(select count(*) as purchase_per_genre, customer.country, genre.name, genre.genre_id
		 from invoice_line
		 join invoice on invoice.invoice_id = invoice_line.invoice_id
		 join customer on customer.customer_id = invoice.customer_id
		 join track on track.track_id = invoice_line.track_id
		 join genre on genre.genre_id = track.genre_id
		 group by 2,3,4
		 order by 2
		),
	max_genre_per_country as
		(select max(purchase_per_genre) as max_genre_number, country
		 from sales_per_country
		 group by 2
		 order by 2
		)
select sales_per_country.* from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchase_per_genre = max_genre_per_country.max_genre_number;


 


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as
(
	select sum(total) as total_spending, customer.customer_id,first_name,last_name,billing_country,
	row_number() over(partition by billing_country order by sum(total) desc) as row_no
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 2,3,4,5
	order by 5
)
select * from customer_with_country where row_no <=1


						"OR"


with recursive
	customer_with_country as
		(select sum(total) as total_spending, customer.customer_id,first_name,last_name,billing_country
		 from invoice
		 join customer on customer.customer_id = invoice.customer_id
		 group by 2,3,4,5
		 order by 5
		),
	country_max_spending as
		(select max(total_spending) as max_spending, billing_country
		 from customer_with_country
		 group by 2
		 order by 2
		)
select customer_with_country.* from customer_with_country
join country_max_spending on customer_with_country.billing_country = country_max_spending.billing_country
where customer_with_country.total_spending = country_max_spending.max_spending




