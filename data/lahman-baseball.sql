WITH manager_both AS 
	(SELECT *
	FROM awardsmanagers
	WHERE awardid LIKE 'TSN%'
	AND lgid LIKE 'NL'
	INTERSECT
	SELECT *
	FROM awardsmanagers
	WHERE awardid LIKE 'TSN%'
	AND lgid LIKE 'AL')

SELECT DISTINCT(playerid), namefirst, namelast, mb.yearid, salaries.teamid
FROM awardsmanagers AS am INNER JOIN people USING(playerid)
INNER JOIN manager_both AS mb USING(playerid)
INNER JOIN salaries USING(playerid);

--cte works
	
WITH manager_both AS (SELECT playerid, a1.lgid, a2.lgid, a1.yearid, a2.yearid
	FROM awardsmanagers AS a1 INNER JOIN awardsmanagers AS a2
	USING(playerid)
	WHERE a1.awardid LIKE 'TSN%'
	AND a2.awardid LIKE 'TSN%'
	AND a1.lgid LIKE 'AL'
	AND a2.lgid LIKE 'NL')
	
SELECT people.playerid, namefirst, namelast, appearances.teamid
FROM manager_both LEFT JOIN people USING(playerid)
LEFT JOIN appearances USING(playerid);

SELECT *
FROM appearances
WHERE playerid LIKE 'johnsda02'
LIMIT 10;