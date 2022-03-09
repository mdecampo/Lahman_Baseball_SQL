/*1. What range of years for baseball games played does the provided database cover?
SELECT MIN(year), 
MAX(year) 
FROM homegames
A: 1871-2016*/
/*2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
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
A: Edward Carl, height: 43in games: 1 team: St.Louis Browns*/
/*3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT namefirst, namelast, sum(salary) AS total_salary
from people AS p
LEFT JOIN salaries AS s
ON p.playerid=s.playerid
WHERE p.playerid 
IN
(SELECT distinct(playerid) from collegeplaying AS c
WHERE schoolid ILIKE 'vandy')
GROUP BY namefirst, namelast
 HAVING sum(salary) IS NOT NULL
ORDER BY total_salary DESC
A: David Price $81,851,296*/
/*4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT
sum(f.po),
CASE WHEN f.pos='OF'
	THEN 'Outfield'
WHEN f.pos IN ('SS','1B','2B','3B')
	THEN 'Infield'
WHEN f.pos IN ('P','C')
	THEN 'Battery'
END AS position
from fielding as f
WHERE f.yearid=2016
GROUP BY position
A: 41424 Battery, 58934 Infield, 29560 Outfield*/
/*5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
Select sum(HR) AS HOMERUNS,
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
from teams
WHERE yearid>=1920
group by decade
order by decade

A: 1920 SO 5.14,6,19,6,63,8.31,10.95,9.82,10.24,11.83,12.65,14.56
A: 1920 HR 0.29,0.54,0.54,1.23,1.16,1.03,1.10,1.14,1.64,1.46*/

/*6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT distinct b.playerid,
cast(sb as numeric) as stolen,
cast(cs as numeric) as caught,
cast(sb as numeric)+cast(cs as numeric) AS attempts,
round((cast(sb as numeric)/(cast(cs as numeric)+cast(sb as numeric))),2)*100 as success,
namegiven
from batting AS b
JOIN people as p
ON b.playerid=p.playerid
where yearid=2016 AND (cs+sb)>20
ORDER BY success DESC
A: Christopher Scott 91%*/

/*7. a.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? b.What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

/*a.
Select teamid, sum(w) AS high_wins
from teams
where teamid IN
(select teamid
from teams
where WSwin='N' AND yearid between 1970 AND 2016)
group by teamid
order by high_wins desc
A: NYA (across all years) OR SEA 116 (largest in a year)*/
 
/*b.
Select teamid, min(w) AS low_wins
from teams
where teamid IN
(select teamid
from teams
where WSwin='Y' AND yearid between 1970 AND 2016)
group by teamid
order by low_wins
A: ANA 664 wins (across all years) OR PHI 17 wins (smallest in a year)*/

/*Select teamid, yearid, sum(w) AS wins
from teams
where teamid IN
(select teamid
from teams
where WSwin='Y' AND yearid between 1970 AND 2016)
group by teamid,yearid
order by teamid*/

/*8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

/*select team,
park,
attendance, 
games,
attendance/games as avg_attendance,
rank() over(order by (attendance/games) DESC) AS rank
from homegames
where year=2016 AND games>=10
order by rank
LIMIT 5
A: Lan LOS03 45719, SLN STL10 42524,TOR TOR02 41877, SFN SF003 41546, CHN CHI11 39906*/

/*select team,
park,
attendance, 
games,
attendance/games as avg_attendance,
rank() over(order by (attendance/games)) AS rank
from homegames
where year=2016 AND games>=10
order by rank
LIMIT 5
A: TBA STP01 15878, OAK OAK01 18784, CLE CLE08 19650, MIA MIA02 21405, CHA CHI12 21559*/

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

Select playerid, yearid 
where playerid IN
(Select playerid, lgid, yearid
from awardsmanagers
where playerid IN
(select playerid where awardid LIKE 'TSN%' AND lgid IN ('AL'))
group by playerid, lgid, yearid) AND playerid IN
(Select playerid, lgid, yearid
from awardsmanagers
where playerid IN
(select playerid where awardid LIKE 'TSN%' AND lgid IN ('NL'))
group by playerid, lgid, yearid)

10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.