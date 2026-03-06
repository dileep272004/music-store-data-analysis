-- =====================================
-- MUSIC STORE DATA ANALYSIS PROJECT
-- Name: Dileep Somnapalli
-- Batch: Isp2501
-- =====================================

-- creating a database
Create database music_store;

-- using that database
use music_store;

-- drop database music_store; 
-- tables creation
-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY Auto_increment,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY auto_increment,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY auto_increment,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY auto_increment,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
     ON DELETE CASCADE ON UPDATE CASCADE
);


-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY auto_increment,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);


-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY auto_increment,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY auto_increment,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(255)
);


-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) 
    ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);


select * from genre;

select * from mediatype;

select * from employee;

select * from Customer;

select * from artist;

select * from album;

select * from Track;

select * from Invoice;

select * from InvoiceLine;

select * from playlist;

select * from PlaylistTrack;


-- 1. Who is the senior most employee based on job title?
select employee_id, last_name, first_name, title
from employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices
select billing_country, count(*) as "Most_Invoices"
from invoice
group by billing_country
order by Most_Invoices desc;

-- 3. What are the top 3 values of total invoice?
select *
from invoice
order by total desc
limit 3;

-- 4.Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, sum(total) as "Revenue"
from invoice
group by billing_city
order by Revenue desc
limit 1;

-- 5.Who is the best customer? - The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select c.customer_id,c.first_name,c.last_name,sum(i.total) as "Spent_amount"
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by Spent_Amount desc
limit 1;


-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select c.email,c.first_name,c.last_name,g.name
from genre as g
join track as t
on g.genre_id = t.genre_id
join invoiceline as il
on t.track_id = il.track_id
join invoice as i
on il.invoice_id = i.invoice_id
join customer as c
on i.customer_id = c.customer_id
where (g.name = "Rock") and (c.email like "A%")
order by c.email;


-- 7.Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 
select ar.name,count(t.track_id) as "Total_Track"
from genre as g
join track as t
on g.genre_id = t.genre_id
join album as a
on t.album_id = a.album_id
join artist as ar
on a.artist_id = ar.artist_id
where g.name = "Rock"
group by ar.name
order by Total_Track desc
limit 10;


-- 8.Return all the track names that have a song length longer than the average song length.- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
select c.first_name,c.last_name,ar.name,sum(il.unit_price*il.quantity) as Total_spent
from artist as ar
join album as a
on ar.artist_id = a.artist_id
join track as t
on a.album_id = t.album_id
join invoiceline as il
on t.track_id = il.track_id
join invoice as i
on il.invoice_id = i.invoice_id
join customer as c
on i.customer_id = c.customer_id
group by c.first_name,c.last_name,ar.name
order by Total_spent desc;


select unit_price*quantity
from invoiceline;


-- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
select country,name
from (
		select c.country,g.name,sum(il.quantity) as "Purchases",
        Dense_Rank() over(
        partition by c.country
        order by sum(il.quantity) desc
        ) as rnk
from customer as c
join invoice as i
on c.customer_id = i.customer_id
join invoiceline as il
on i.invoice_id = il.invoice_id
join track as t
on il.track_id = t.track_id
join genre as g
on t.genre_id = g.genre_id
group by c.country,g.name
) as ranked_data
where rnk = 1;


-- 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

SELECT country,
       customer_name,
       total_spent
FROM (
        SELECT c.country,
               CONCAT(c.first_name,' ',c.last_name) AS customer_name,
               SUM(i.total) AS total_spent,
               DENSE_RANK() OVER(
                    PARTITION BY c.country
                    ORDER BY SUM(i.total) DESC
               ) AS rnk
        FROM customer c
        JOIN invoice i
             ON c.customer_id = i.customer_id
        GROUP BY c.country,
                 c.customer_id,
                 c.first_name,
                 c.last_name
     ) AS ranked_customers
WHERE rnk = 1;



SELECT city, COUNT(*) 
FROM customer
GROUP BY city
HAVING COUNT(*) > 1;