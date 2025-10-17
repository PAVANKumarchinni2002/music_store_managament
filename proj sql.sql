create database music_store1;
use  music_store1;

CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
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

CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
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
);

CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);



-- 1. Who is the senior most employee based on job title?
select employee_id,first_name,last_name,title,levels
from employee
order by levels desc
limit 1;


-- 2. Which countries have the most Invoices?
select billing_country as country,count(*) as invoice_count
from invoice
group by billing_country
order by invoice_count desc;

-- 3. What are the top 3 values of total invoice?
select distinct total
from invoice
order by total desc 
limit 3;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city,sum(total) as total_revenue
from invoice
group by billing_city
order by total_revenue desc;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select c.customer_id, c.first_name,c.last_name,sum(i.total) as total_spent
from customer c 
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spent desc
limit 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct c.email, c.first_name, c.last_name, g.name as genre from
customer c
join invoice i on i.customer_id = c.customer_id
join invoiceline il on il. invoice_id= i.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
WHERE g.name = 'rock'
order by c.email asc;

-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select
    a.artist_id,
    a.name as artist_name,
    count(*) as rock_track_count
from artist a
join album al 
    on al.artist_id = a.artist_id
join track t 
    on t.album_id = al.album_id
join genre g 
    on g.genre_id = t.genre_id
where g.name = 'Rock'
group by a.artist_id, a.name
order by rock_track_count desc, a.name
limit 10;


-- 8. Return all the track names that have a song length longer than the average song length.Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
select t.name,t.milliseconds
from track t
where t.milliseconds>(select avg (milliseconds)from track)
order by t.milliseconds desc;

-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent
select c.customer_id,
concat(c.first_name,'',c.last_name) as customer_name,
a.name as artist_name,
round(sum(il.unit_price * il.quantity),2) as total_spent
from customer c
join invoice i on i.customer_id = c.customer_id
join invoiceline il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join artist a on a.artist_id = al.artist_id
group by c.customer_id,a.artist_id,a.name
order by total_spent desc;

-- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
with genre_counts as (
select c.country,
g.name as genre_name,
count(*) as purchases
from customer c 
join invoice i on i.customer_id = c.customer_id
join invoiceline il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id =t.genre_id
group by c.country,g.name
),
ranked as (
select country,genre_name,purchases,
dense_rank() over (partition by country order by purchases desc) as rnk from 
genre_counts
)
select country,genre_name as top_genre,purchases
from ranked
where rnk = 1
order by country asc,top_genre asc;

-- 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
with spends as (
select c.country,
concat(c.first_name,'',c.last_name) as customer_name,
round(sum(i.total),2)as total_spent
from customer c
join invoice i on i.customer_id = c.customer_id
group by c.country,c.customer_id,customer_name
),
ranked as (
select country,customer_name,total_spent,
dense_rank() over (partition by country order by total_spent desc) as rnk
from spends
)
select country,customer_name,total_spent
from ranked
where rnk = 1
order by country asc,customer_name asc;