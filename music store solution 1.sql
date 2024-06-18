
-- Who is the senior most employee based on job title?

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- Which countries have the most Invoices?

SELECT 
    billing_country, COUNT(billing_country) AS No_invoices
FROM
    invoice
GROUP BY billing_country;

-- What are top 3 values of total invoice?

SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

SELECT 
    billing_city, SUM(total) AS Total_invoice
FROM
    invoice
GROUP BY billing_city
ORDER BY Total_invoice DESC;

-- Who is the best customer? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money

SELECT 
    c.customer_id, c.first_name, c.last_name, SUM(total)
FROM
    invoice i
        JOIN
    customer c ON i.customer_id = c.customer_id
GROUP BY c.customer_id , c.first_name , c.last_name
ORDER BY SUM(total) DESC
LIMIT 1;

-- Moderate
-- (M) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

SELECT DISTINCT
    email, first_name, last_name, genre.name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
        JOIN
    track ON invoice_line.track_id = track.track_id
        JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name = 'Rock'
ORDER BY email;

-- alternative solution 

SELECT DISTINCT
    email, first_name, last_name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            track
                JOIN
            genre ON track.genre_id = genre.genre_id
        WHERE
            genre.name LIKE 'Rock')
ORDER BY email;

-- Let's invite the artists who have written the most rock music in our dataset.
--  Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT 
    artist.name AS artist, COUNT(*) AS Number_Tracks
FROM
    track
        JOIN
    album ON track.album_id = album.album_id
        JOIN
    artist ON album.artist_id = artist.artist_id
        JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY Number_Tracks DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;

-- (ADVANCE) 
-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT 
    c.first_name,
    c.last_name,
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    album al ON t.album_id = al.album_id
        JOIN
    artist a ON al.artist_id = a.artist_id
GROUP BY c.customer_id , c.first_name , c.last_name , a.artist_id , a.name
ORDER BY total_spent DESC;

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

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
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount

with Customer_with_country AS (
	select customer.customer_id,first_name, last_name,billing_country, sum(total) as total_spend,
    row_number() over(partition by billing_country order by sum(total) desc) as RowNo
    from invoice
    join customer ON customer.customer_id = invoice.customer_id
    group by 1,2,3,4
    order by 4 ASC,5 desc)
    select * from Customer_with_country where RowNo <= 1;







