
/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

Select * From employee
ORDER BY levels desc
Limit 1

/* Q2: Which countries have the most Invoices? */

Select billing_country, count(invoice_id) from invoice
Group by billing_country
ORDER by count(invoice_id) DESC
Limit 1

/* Q3: What are top 3 values of total invoice? */

Select total From invoice
Order by total desc
Limit 3 

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select * from invoice
Select billing_city, Sum(total) as total_sum
From invoice
Group by billing_city 
ORDER by total_sum Desc
Limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

Select * From customer

Select customer.customer_id,first_name,last_name, sum(total) as s
From customer customer
join invoice invoice
on customer.customer_id= invoice.customer_id
Group by customer.customer_id
Order by s desc
Limit 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

Select Distinct first_name, last_name, email
FROM customer 
Join invoice ON customer.customer_id = invoice.customer_id
Join invoice_line ON  invoice.invoice_id= invoice_line.invoice_id
Where track_id IN
( Select track_id 
From track
 Join genre
 on track.genre_id = genre.genre_id
 Where genre.Name Like 'Rock'
 )
order by email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

Select artist.name , count (track.track_id) as total_count
from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
Where genre.name Like 'Rock'
Group by artist.artist_id , artist.name
Order by total_count desc
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select * from invoice_line
Select  name, milliseconds
From track
Where milliseconds > (
Select avg(milliseconds)
From track)
Order by milliseconds Desc

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on top selling artist? Write a query to return customer name, artist name and total spent */


SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    a.name AS artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice_line il
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album alb ON alb.album_id = t.album_id
JOIN 
    artist a ON a.artist_id = alb.artist_id
JOIN 
    invoice i ON i.invoice_id = il.invoice_id
JOIN 
    customer c ON c.customer_id = i.customer_id
WHERE 
    a.artist_id = (
        
        SELECT 
            alb.artist_id
        FROM 
            invoice_line il
        JOIN 
            track t ON t.track_id = il.track_id
        JOIN 
            album alb ON alb.album_id = t.album_id
        GROUP BY 
            alb.artist_id
        ORDER BY 
            SUM(il.unit_price * il.quantity) DESC
        LIMIT 1
    )
GROUP BY 
    c.customer_id, c.first_name, c.last_name, a.name
ORDER BY 
    amount_spent DESC;




/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

 

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



With PopularGenre As(
Select count(invoice_line.quantity) AS Purchase, customer.country,genre.name AS GenreName,
Dense_rank() Over (Partition By customer.country Order by count(invoice_line.quantity) DESC) AS ranki
FROM invoice_line
Join invoice ON invoice_line.invoice_id = invoice.invoice_id
	Join customer On invoice.customer_id = customer.customer_id
	Join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
Group by 2,3
)

Select country,GenreName,Purchase
FROM PopularGenre
Where ranki=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

With Mostspent AS(
Select Sum(invoice_line.quantity * invoice_line.unit_price) AS total , customer.country, customer.first_name,
	customer.last_name, Dense_rank() Over 
(partition By customer.country Order by Sum(invoice_line.quantity * invoice_line.unit_price) Desc) AS ranki
	FROM invoice_line 
	join invoice on invoice_line.invoice_id = invoice.invoice_id 
	join customer on invoice.customer_id = customer.customer_id 
	Group by 2,3,4
)

Select country, first_name, last_name,total
From Mostspent
where ranki =1
