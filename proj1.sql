-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people AS P
  WHERE P.weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE "% %"
  ORDER BY namefirst ASC, namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(playerid)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(playerid)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT P.namefirst, P.namelast, P.playerid, H.yearid
  FROM people AS P INNER JOIN halloffame as H
  ON P.playerid = H.playerid
  WHERE H.inducted = 'Y'
  ORDER BY H.yearid DESC, P.playerid ASC
;


-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  WITH collegeRecord(playerid, schoolid) AS 
  (SELECT C.playerid, C.schoolid
  FROM collegeplaying as C INNER JOIN schools as S
  ON C.schoolid = S.schoolid
  WHERE S.schoolState = 'CA')

  SELECT q2i.namefirst, q2i.namelast, q2i.playerid, CR.schoolid, q2i.yearid
  FROM collegeRecord AS CR INNER JOIN q2i
  ON CR.playerid = q2i.playerid
  ORDER BY q2i.yearid DESC, CR.schoolid ASC, q2i.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  WITH collegeRecord(playerid, schoolid) AS 
  (SELECT C.playerid, C.schoolid
  FROM collegeplaying as C INNER JOIN schools as S
  ON C.schoolid = S.schoolid)

  SELECT q2i.playerid, q2i.namefirst, q2i.namelast, CR.schoolid
  FROM q2i LEFT OUTER JOIN collegeRecord AS CR
  ON q2i.playerid = CR.playerid
  ORDER BY q2i.playerid DESC, CR.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  WITH slg(playerid, yearid, AB, slgVal) AS
  (
    SELECT playerid, yearid, AB, (H+H2B+2*H3B+3*HR+0.0)/(AB+0.0)
    FROM batting
    WHERE AB > 50
  )
  
  SELECT P.playerid, P.namefirst, P.namelast, slg.yearid, slg.slgVal
  FROM people AS P INNER JOIN slg
  ON P.playerid = slg.playerid
  ORDER BY slgVal DESC, yearid ASC, P.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH data_for_lslg(playerid, AB, H, H2B, H3B, HR) AS
  (
    SELECT playerid, SUM(AB), SUM(H), SUM(H2B), SUM(H3B), SUM(HR)
    FROM batting
    GROUP BY playerid
  ),
  lslg(playerid, lslgVal) AS
  (
    SELECT playerid, (H+H2B+2*H3B+3*HR+0.0)/(AB+0.0)
    FROM data_for_lslg
    WHERE AB > 50
  )

  SELECT P.playerid, P.namefirst, P.namelast, lslg.lslgVal
  FROM people AS P INNER JOIN lslg
  ON P.playerid = lslg.playerid
  ORDER BY lslg.lslgVal DESC, P.playerid ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH data_for_lslg(playerid, AB, H, H2B, H3B, HR) AS
  (
    SELECT playerid, SUM(AB), SUM(H), SUM(H2B), SUM(H3B), SUM(HR)
    FROM batting
    GROUP BY playerid
  ),
  lslg(playerid, lslgVal) AS
  (
    SELECT playerid, (H+H2B+2*H3B+3*HR+0.0)/(AB+0.0)
    FROM data_for_lslg
    WHERE AB > 50
  ),
  targeted_lslg(playerid, lslgVal) AS
  (
    SELECT lslg.playerid, lslg.lslgVal
    FROM lslg
    WHERE lslg.lslgVal > (
      SELECT lslgVal
      FROM lslg
      WHERE playerid = "mayswi01"
      )
  )

  SELECT P.namefirst, P.namelast, TL.lslgVal
  FROM people AS P INNER JOIN targeted_lslg AS TL
  ON P.playerid = TL.playerid
  ORDER BY TL.lslgVal DESC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH bins_statistics(binstart, binend, width)
  AS 
  (SELECT MIN(salary), MAX(salary), CAST (((MAX(salary) - MIN(salary))/10) AS INT)
  FROM salaries),
  bins(binid, binstart, width)
  AS 
  (SELECT CAST ((salary/width) AS INT), binstart, width
  FROM salaries, bins_statistics
  WHERE yearid = 2016)

  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, s1.min - s2.min, s1.max - s2.max, s1.avg - s2.avg
  FROM q4i AS s1, q4i AS s2
  WHERE s1.yearid - s2.yearid = 1
  ORDER BY s1.yearid ASC
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH idTable(playerid, salary, yearid) AS
  (
    SELECT playerid, salary, yearid
    FROM salaries
    WHERE 
    (
      yearid = 2000 AND salary =
      (
        SELECT MAX(salary) FROM salaries AS s1 WHERE s1.yearid = 2000
      )
    )
    OR
    (
      yearid = 2001 AND salary =
      (
        SELECT MAX(salary) FROM salaries AS s2 WHERE s2.yearid = 2001
      )
    )
  )

  SELECT P.playerid, P.namefirst, P.namelast, idTable.salary, idTable.yearid
  FROM people AS P INNER JOIN idTable
  ON P.playerid = idTable.playerid

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT A.teamid, MAX(S.salary) - MIN(S.salary)
  FROM allstarfull as A INNER JOIN salaries as S
  ON A.playerid = S.playerid AND A.yearid = S.yearid
  WHERE A.yearid = 2016
  GROUP BY A.teamid
;

