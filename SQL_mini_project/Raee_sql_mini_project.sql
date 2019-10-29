/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
  FROM Facilities
 WHERE membercost>0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(facid) AS membercost_free_faci
  FROM Facilities
 WHERE membercost=0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,
       name,
       membercost,
       monthlymaintenance
  FROM Facilities
 WHERE membercost > 0
HAVING membercost < (0.2*monthlymaintenance)


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
  FROM Facilities
 WHERE facid IN (1, 5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'Expensive' ELSE 'Cheap' END AS cheap_or_not
  FROM Facilities
ORDER BY 2


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
       surname
  FROM Members
 WHERE joindate = (SELECT MAX(joindate) FROM Members)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT fac.name,
       CONCAT(mem.firstname, ' ', mem.surname) AS member_name
       FROM Members mem
       JOIN Bookings book
   ON mem.memid = book.memid AND book.memid > 0
       JOIN Facilities fac
   ON book.facid = fac.facid
WHERE fac.name LIKE 'Tennis%'
ORDER BY 2


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT fac.name,
       CONCAT(mem.firstname, ' ', mem.surname) AS member_name,
       CASE WHEN mem.memid > 0 THEN (book.slots*fac.membercost) ELSE (book.slots*fac.guestcost) END AS cost
       FROM Members mem
       JOIN Bookings book
   ON mem.memid = book.memid
       JOIN Facilities fac
   ON book.facid = fac.facid AND book.starttime LIKE '2012-09-14%'
WHERE (CASE WHEN mem.memid > 0 THEN (book.slots*fac.membercost) ELSE (book.slots*fac.guestcost) END) > 30
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.name,
       CONCAT(mem.firstname, ' ', mem.surname) AS member_name,
       sub.cost
  FROM Members mem
  JOIN (SELECT fac.name,
               book.memid,
               CASE WHEN book.memid > 0 THEN (book.slots*fac.membercost) ELSE (book.slots*fac.guestcost) END AS cost
        FROM Facilities fac
        JOIN Bookings book
        ON book.facid = fac.facid and book.starttime LIKE '2012-09-14%'
        ) sub
   ON mem.memid = sub.memid
 WHERE cost >30
ORDER BY 3 DESC



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT fac.name AS 'Facility name',
       sub_1.total_revenue
   FROM Facilities as fac
   JOIN (
         SELECT fac.facid,
              SUM(CASE WHEN sub_2.client_type = 'Member' THEN (sub_2.total_slots*fac.membercost) ELSE (sub_2.total_slots*fac.guestcost) END) AS total_revenue
         FROM Facilities fac
         JOIN (
               SELECT fac.facid,
                      CASE WHEN book.memid > 0 THEN 'Member' ELSE 'Guest' END AS Client_type,
                      SUM(book.slots) AS total_slots
                 FROM Bookings book
                 JOIN Facilities fac
                 ON book.facid = fac.facid
                GROUP BY 1, 2
                ) sub_2
          ON fac.facid = sub_2.facid
       GROUP BY 1
        ) sub_1
    ON fac.facid = sub_1.facid
 WHERE sub_1.total_revenue < 1000
ORDER BY 2
