/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:
*
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
FROM  `Facilities`
WHERE membercost > 0.0
LIMIT 0 , 30


name
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( 1 )
FROM  `Facilities`
WHERE membercost = 0.0

answer: 4

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance
FROM  `Facilities`
WHERE membercost <
(0.2* monthlymaintenance) AND membercost > 0.0


facid	name	membercost	monthlymaintenance
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
FROM Facilities
WHERE facid
IN ('1', '5')

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance <100
THEN  'cheap'
ELSE  'Expensive'
END AS costlabel
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (
SELECT MAX( joindate )
FROM Members )

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT name, CONCAT(firstname, ' ',surname) as fullname
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
JOIN Members ON Bookings.memid = Members.memid
WHERE name LIKE 'Tennis Court%' ORDER BY fullname


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name, CONCAT( firstname,  ' ', surname ) AS fullname,
CASE WHEN country_club.Bookings.memid =0
THEN guestcost * slots
ELSE membercost * slots
END AS cost
FROM country_club.Bookings
JOIN country_club.Facilities ON country_club.Bookings.facid = country_club.Facilities.facid
JOIN country_club.Members ON country_club.Members.memid = country_club.Bookings.memid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
HAVING cost >30
ORDER BY cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT A.name AS Facility, M.firstname AS Name, A.cost AS Cost
FROM country_club.Members M
JOIN (
SELECT B.memid,F.name, F.guestcost * B.slots AS Cost
FROM country_club.Bookings B
JOIN country_club.Facilities F ON B.facid = F.facid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND B.memid =0 )A ON M.memid = A.memid
WHERE Cost >30


UNION


SELECT A2.name AS Facility, CONCAT( M.firstname,  ' ', M.surname ) AS Name, A2.cost AS Cost
FROM country_club.Members M
JOIN (
SELECT B.memid, F.name, ( F.membercost * B.slots ) AS Cost
FROM country_club.Bookings B
JOIN country_club.Facilities F ON B.facid = F.facid
JOIN country_club.Members M ON M.memid = B.memid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND M.memid !=0
)A2 ON M.memid = A2.memid
WHERE Cost >30


ORDER BY Cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT A.name AS Facility, SUM( A.cost ) AS Revenue
FROM (

SELECT B.memid, F.name, F.guestcost * B.slots AS cost
FROM country_club.Bookings B
JOIN country_club.Facilities F ON B.facid = F.facid
WHERE B.memid =0
)A
GROUP BY Facility
HAVING Revenue <1000
UNION
SELECT A2.name AS Facility, SUM( A2.cost ) AS Revenue
FROM (

SELECT B.memid, F.name, (
F.membercost * B.slots
) AS cost
FROM country_club.Bookings B
JOIN country_club.Facilities F ON B.facid = F.facid
WHERE B.memid !=0
)A2
GROUP BY Facility
HAVING Revenue <1000
ORDER BY Revenue DESC
