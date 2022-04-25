/*1. What range of years for baseball games played does the provided database cover?*/
SELECT MIN(year), 
MAX(year) 
FROM homegames
--A: 1871-2016

/*2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?*/
SELECT 
p.playerid,
p.namegiven,
p.height,
a.g_all AS game_count, 
t.name AS team_name
FROM people as p
JOIN appearances as a
ON p.playerid=a.playerid
JOIN teams as T
ON a.teamid=t.teamid
ORDER BY height
LIMIT 1
--A: Edward Carl, height: 43in games: 1 team: St.Louis Browns

/*3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?*/

SELECT namefirst, 
namelast, 
sum(salary) AS total_salary
FROM people AS p
LEFT JOIN salaries AS s
ON p.playerid=s.playerid
WHERE p.playerid 
IN
(SELECT distinct(playerid) FROM collegeplaying AS c
WHERE schoolid ILIKE 'vandy')
GROUP BY namefirst, namelast
 HAVING sum(salary) IS NOT NULL
ORDER BY total_salary DESC
--A: David Price $81,851,296

/*4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/
SELECT
sum(f.po),
CASE WHEN f.pos='OF'
	THEN 'Outfield'
WHEN f.pos IN ('SS','1B','2B','3B')
	THEN 'Infield'
WHEN f.pos IN ('P','C')
	THEN 'Battery'
END AS position
FROM fielding AS f
WHERE f.yearid=2016
GROUP BY position
--A: 41,424 Battery, 58,934 Infield, 29,560 Outfield

/*5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/
SELECT sum(HR) AS HOMERUNS,
sum(G)/2 as GAMES,
round(avg(HR/(G/2)),2) AS AVG_HR_PER_GAME, 
CASE WHEN yearid BETWEEN 1920 AND 1929
	THEN '1920s'
WHEN yearid BETWEEN 1930 AND 1939
	THEN '1930s'
WHEN yearid BETWEEN 1940 AND 1949
	THEN '1940s'
WHEN yearid BETWEEN 1950 AND 1959
	THEN '1950s'
WHEN yearid BETWEEN 1960 AND 1969 
	THEN '1960s' 
WHEN yearid BETWEEN 1970 AND 1979
	THEN '1970s'
WHEN yearid BETWEEN 1980 AND 1989
	THEN '1980s'
WHEN yearid BETWEEN 1990 AND 1999
	THEN '1990s'
WHEN yearid BETWEEN 2000 AND 2009
	THEN '2000s' 
ELSE '2010s'
END AS decade
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER BY decade

--A: 1920 SO 5.14,6,19,6,63,8.31,10.95,9.82,10.24,11.83,12.65,14.56
--A: 1920 HR 0.29,0.54,0.54,1.23,1.16,1.03,1.10,1.14,1.64,1.46*/

/*6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
SELECT DISTINCT b.playerid,
CAST(sb as numeric) as stolen,
CAST(cs as numeric) as caught,
CAST(sb as numeric)+CAST(cs as numeric) AS attempts,
ROUND((CAST(sb AS numeric)/(CAST(cs AS numeric)+CAST(sb AS numeric))),2)*100 AS success,
namegiven
FROM batting AS b
JOIN people as p
ON b.playerid=p.playerid
WHERE yearid=2016 
AND (cs+sb)>20
ORDER BY success DESC
--A: Christopher Scott 91%

/*7. a.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? b.What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

--a.
SELECT 
teamid, 
yearid, 
max(w) AS high_wins
FROM teams
WHERE WSwin='N' AND yearid BETWEEN 1970 AND 2016
GROUP BY teamid, yearid
ORDER BY high_wins desc
--A: SEA 116 (largest in a year)
 
--b.
SELECT yearid, teamid, min(w) AS low_wins
FROM teams
WHERE  
WSwin='Y' AND yearid between '1970' AND '2016'
GROUP BY teamid, yearid
ORDER BY low_wins
--A: LAN 1981 63 wins 1981 (smallest in a year). Player strike with fewer games.

--c. 
SELECT yearid, teamid, min(w) AS low_wins
FROM teams
WHERE  
WSwin='Y' AND yearid between '1970' AND '2016' 
AND yearid <>'1981'
GROUP BY teamid, yearid
ORDER BY low_wins
--a. SLN in 2006 w/ 83 wins 

/*Select teamid, yearid, sum(w) AS wins
from teams
where teamid IN
(select teamid
from teams
where WSwin='Y' AND yearid between 1970 AND 2016)
group by teamid,yearid
order by teamid*/

/*8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

SELECT team,
park,
attendance, 
games,
attendance/games as avg_attendance,
RANK() OVER(ORDER BY (attendance/games) DESC) AS rank
FROM homegames
WHERE year=2016 AND games>=10
ORDER BY rank
LIMIT 5
--A: Lan LOS03 45719, SLN STL10 42524,TOR TOR02 41877, SFN SF003 41546, CHN CHI11 39906

SELECT team,
park,
attendance, 
games,
attendance/games as avg_attendance,
RANK() OVER(ORDER BY (attendance/games)) AS rank
FROM homegames
WHERE year=2016 AND games>=10
ORDER BY rank
LIMIT 5
--A: TBA STP01 15878, OAK OAK01 18784, CLE CLE08 19650, MIA MIA02 21405, CHA CHI12 21559

/*9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.*/

SELECT namefirst,
namelast,
 m.teamid,
 results.yearid,
 results.lgid, 
 results.playerid 
 FROM people AS p
JOIN
(SELECT playerid, yearid,lgid,awardid FROM awardsmanagers WHERE playerid IN
	(SELECT playerid
FROM awardsmanagers AS a
WHERE playerid IN
(SELECT playerid WHERE awardid LIKE 'TSN%' AND lgid IN ('AL'))
INTERSECT
SELECT playerid
FROM awardsmanagers
WHERE playerid IN
(SELECT playerid WHERE awardid LIKE 'TSN%' AND lgid IN ('NL')))
AND awardid LIKE 'TSN%') AS results
ON p.playerid=results.playerid
JOIN managers AS m
ON results.playerid=m.playerid AND results.yearid=m.yearid
ORDER BY results.playerid

--Davey Johnson 1997 BAL and 2012 WAS, Jim Leyland 1988 PIT, 1990 PIT , 1992 PIT, 2006 DET


/*10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.*/


WITH cte2 AS 
(WITH cte1 AS 
(SELECT playerid,
yearid,
COUNT(yearid) OVER(partition by playerid) AS years_played, 
SUM(hr) AS year_hr,
MAX(MAX(hr)) OVER(partition by playerid) AS max_hr
FROM
batting as b
GROUP BY playerid, yearid)
SELECT playerid, yearid, year_hr,max_hr
FROM CTE1
WHERE years_played>=10)
SELECT playerid, year_hr, namefirst, namelast
FROM people
JOIN CTE2 using (playerid)
WHERE year_hr=max_hr
AND yearid=2016 AND year_hr>=1

--A: 9 players, Robinson Cano (39), Bartolo Colon (1), Rajai Davis (12), Edwin Encarnaction (42,) Francisco Liriano (1), Mike Napoli (34), Angel Pagan (12), Justin Upton (31), Adam Wainwright (2)







