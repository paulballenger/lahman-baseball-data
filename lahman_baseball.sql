WITH rank_wins AS (SELECT yearid, teamid, w, RANK() OVER(PARTITION BY yearid ORDER BY w DESC) AS tm_rank,
				   wswin
				   , sum(case when wswin='Y'then 1 else 0 end)/COUNT(*) as fair
				   
		FROM teams
		WHERE yearid >= 1970
		AND yearid <= 2016
		AND yearid <> 1981
		GROUP BY teams.yearid, teamid, w, teams.wswin)
SELECT *
FROM rank_wins
WHERE  tm_rank = 1
	AND wswin IS NOT NULL
	;	
	
--1.What range of years for baseball games played does the provided database cover?
-- A: 1871-2016
SELECT *
FROM teams

SELECT MIN(yearid) as min_year, MAX(yearid) as max_year
FROM teams

--2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--Edward Carl Gaedel, "43
SELECT *
FROM people

SELECT namelast, namegiven, height
FROM people 
WHERE height IN (select MIN(height)
	
-- 3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?
--A: David Taylor

SELECT *
FROM people
LIMIT 1;

SELECT *
FROM schools
LIMIT 1;

SELECT *
FROM collegeplaying
LIMIT 1;

SELECT *
FROM salaries
LIMIT 1;

WITH top_sal AS (SELECT DISTINCT(sal.yearid), p.namegiven AS first, p.namelast AS last, s.schoolname AS college, sal.salary
	FROM people AS p
	INNER JOIN salaries AS sal
	USING (playerid)
	INNER JOIN collegeplaying AS c
	USING(playerid)
	INNER JOIN schools AS s
	USING (schoolid)
	WHERE schoolname iLIKE '%vanderbilt%'
	ORDER BY salary DESC)
SELECT first, last, college, SUM(salary) total_sal
FROM top_sal
GROUP BY first,last,college
ORDER BY total_sal DESC;


SELECT p.namegiven AS first, p.namelast AS last, s.schoolname AS college, sal.salary
FROM people AS p
	INNER JOIN salaries AS sal
	USING (playerid)
	INNER JOIN collegeplaying AS c
	USING(playerid)
	INNER JOIN schools AS s
	USING (schoolid)
WHERE schoolname iLIKE '%vanderbilt%'
AND first = 'David Taylor'
GROUP BY first, last, s.schoolname, sal.salary
ORDER BY sal.salary DESC
LIMIT 12;

--4.Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.

WITH pc AS (SELECT playerid, pos, po, yearid,
		CASE WHEN pos ILIKE '%of%' THEN 'Outfield'
		WHEN pos IN ('SS', '1B','2B','3B') THEN 'Infield'
		WHEN pos IN ('P','C') THEN 'Battery' END AS pos_cat
		FROM fielding)
SELECT pos_cat, SUM(po)
FROM pc
WHERE yearid = 2016
GROUP BY pos_cat

--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends?

SELECT AVG(so), FLOOR(yearid/10)*10 AS decade
FROM batting
WHERE yearid >= 1920
GROUP BY yearid
ORDER BY yearid;

WITH avg_so_dec AS (SELECT AVG(so) AS avg_year,yearid, FLOOR(yearid/10)*10 AS decade
					FROM batting
					WHERE yearid >= 1920
					GROUP BY yearid
					ORDER BY yearid)
SELECT AVG(avg_year), decade
FROM avg_so_dec
GROUP BY decade;	

--6
WITH batting AS (SELECT playerid,
				 SUM(sb) AS stolen_bases,
				 SUM(cs) AS caught_stealing,
				 SUM(sb) + SUM(cs) AS total_attempts,
				 yearid AS year
				 FROM batting
				 GROUP BY playerid, yearid)
SELECT DISTINCT(CONCAT(namelast, ',', ' ', namefirst)) AS player_name,
	   SUM(total_attempts) AS total_attempts,
	   SUM(stolen_bases) AS stolen_success,
	   ROUND(SUM(stolen_bases::DECIMAL/total_attempts::DECIMAL)*100, 2) AS success_rate
FROM batting
JOIN people ON batting.playerid = people.playerid
WHERE total_attempts >= 20
	AND total_attempts IS NOT NULL
	AND stolen_bases IS NOT NULL
	AND year = '2016'
GROUP BY people.playerid
ORDER BY success_rate DESC; --QUESTION 6
				 
--7
-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
--What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?	

--largest # wins that did not win WS (SEA- 1998)
SELECT yearid, teamid, w AS max_wins, wswin, w+l AS total
FROM teams
WHERE yearid >= 1970
	AND yearid <= 2016
	AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;

--smallest # wins that did win WS (LAN-1981)
SELECT yearid, teamid, w AS min_wins, wswin, w+l AS total
FROM teams
WHERE yearid >= 1970
	AND yearid <= 2016
	AND wswin = 'Y'
ORDER BY w
LIMIT 1;

--determine why this is the case. 
WITH total_wins AS (SELECT yearid, w, l, w+l AS total
		FROM teams
		WHERE yearid > 1970
		AND yearid < 2016)
SELECT ROUND(AVG(total))
FROM total_wins

----How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?

--WINDOW

WITH pct_ws_win AS (WITH rank_wins AS (SELECT yearid, teamid, w, RANK() OVER(PARTITION BY yearid ORDER BY w DESC) AS tm_rank, wswin
		FROM teams 
		WHERE yearid >= 1970
		AND yearid <= 2016
		AND yearid <> 1981)
SELECT * 
FROM rank_wins
WHERE  tm_rank = 1
	AND wswin IS NOT NULL)
SELECT COUNT(*)
FROM rank_wins
WHERE wswin = 'Y'

--exploring
(SELECT yearid, MAX(w) AS max_wins
					FROM teams
 					WHERE yearid >= 1970
 					AND yearid <= 2016
					 AND yearid <> 1981
					GROUP BY yearid
					ORDER BY yearid)
------ 
(SELECT yearid, teamid, w, wswin
			FROM teams
			WHERE yearid >= 1970
 			AND yearid <= 2016
			AND yearid <> 1981
			ORDER BY yearid, w desc)
	
-- 8 SELECT park, team, attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016
AND games >=10
ORDER BY avg_attendance DESC
LIMIT 5;
SELECT park, team, attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016
AND games >=10
ORDER BY avg_attendance
LIMIT 5;

--9
WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
	
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year;