/* The Music Store company is embarking on a strategic initiative to host a series of musical festivals in collaboration with their roster of artists. 
In order to ensure the utmost success of these festivals, the company recognizes the necessity of leveraging their database to extract actionable insights. 
Through rigorous analysis of their data, the company aims to inform and support key business decisions pertaining to lineup curation, promotional strategies, and overall event planning. 
This data-driven approach will enable the company to optimize resource allocation, enhance audience engagement, and ultimately maximize the impact of their musical festivals. */
/* 1. To select the locations for festival we want to know which countries have the most Invoices. */

  SELECT COUNT(*) AS total_invoice, billing_country 
  FROM invoice
  GROUP BY billing_country
  ORDER BY total_invoice DESC

/* 2. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. */

  SELECT billing_city,SUM(total) AS InvoiceTotal
  FROM invoice
  GROUP BY billing_city
  ORDER BY InvoiceTotal DESC
  LIMIT 1;

/* 3. Who is the best customer? The customer who has spent the most money will be declared the best customer. And will be given access to backstage and meet their favourite artists. */

  SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
  FROM customer
  JOIN invoice ON customer.customer_id = invoice.customer_id
  GROUP BY customer.customer_id
  ORDER BY total_spending DESC
  LIMIT 1;

/* 4. Let's invite the top 10 artists who have written the most rock music in our dataset. */

  SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
  FROM track
  JOIN album ON album.album_id = track.album_id
  JOIN artist ON artist.artist_id = album.artist_id
  JOIN genre ON genre.genre_id = track.genre_id
  WHERE genre.name LIKE 'Rock'
  GROUP BY artist.artist_id
  ORDER BY number_of_songs DESC
  LIMIT 10;

/* 5. Return all the track names that have a song length longer than the average song length. To helpout with the sequence of songs to be performed. */

  SELECT name,milliseconds
  FROM track
  WHERE milliseconds > (
  	SELECT AVG(milliseconds) AS avg_track_length
  	FROM track )
  ORDER BY milliseconds DESC;

/* 6. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. */

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

/* 7. Determines the customer that has spent the most on music for each country. */

 WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
