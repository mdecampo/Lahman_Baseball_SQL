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
Select sum(HR) AS homeruns,
yearid,
sum(G) as GAMES,
round(avg(HR/G),2) AS avg_HR_per_game, 
avg(HR/G) OVER (partition by decade) AS avg_by_decade,
(CASE WHEN yearid BETWEEN 1870 AND 1879
	THEN '1870s'
WHEN yearid BETWEEN 1880 AND 1889
	THEN '1880s'
WHEN yearid BETWEEN 1890 and 1899
	THEN '1890s'
WHEN yearid BETWEEN 1900 AND 1909
	THEN '1900s'
WHEN yearid BETWEEN 1910 and 1919 
	THEN '1910s' 
ELSE '1920s'
END AS decade)
from pitching
WHERE yearid<=1920
group by decade*/

/*A: 1870s: 1.04 Avg SO, 2.36, 1.47,2.01,1.51,1.01
1870s: 0.03, 0.07, 0.06, 0.02,0.01,0.02 HR AVG
1880s and 1890s higher than avg.
--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
SELECT b.playerid,
sb,
cs,
(cs+sb) AS attempts,
namegiven,
((sb/(cs+sb))*100) AS pct
from batting AS b
JOIN people as p
ON b.playerid=p.playerid
where yearid=2016 AND (cs+sb)>20



 

