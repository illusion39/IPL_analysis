SELECT * FROM matches;
-- Looking for number of winners after winning the toss
SELECT count(*) FROM matches WHERE toss_winner=winner;

-- total number of games played
SELECT count(*) FROM matches;

-- Percentage of win by each team after winning the toss
SELECT
    toss_winner,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN winner = toss_winner THEN 1 ELSE 0 END) AS toss_win_matches,
    ROUND(SUM(CASE WHEN winner = toss_winner THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS win_percentage
FROM
    matches
GROUP BY
    toss_winner
    ORDER BY win_percentage desc;
    
UPDATE matches
SET team1 = 'Rising Pune Supergiants'
WHERE team1 = 'Rising Pune Supergiant'; 
UPDATE matches
SET team2 = 'Rising Pune Supergiants'
WHERE team2 = 'Rising Pune Supergiant';

UPDATE matches
SET toss_winner = 'Rising Pune Supergiants'
WHERE toss_winner = 'Rising Pune Supergiant';


UPDATE matches
SET winner = 'Rising Pune Supergiants'
WHERE winner = 'Rising Pune Supergiant';



-- percentage of win after winning a toss and elected to field

SELECT
    toss_winner,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN winner = toss_winner AND toss_decision='field' THEN 1 ELSE 0 END) AS toss_win_matches_field,
    ROUND(SUM(CASE WHEN winner = toss_winner AND toss_decision='field'  THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS win_percentage
FROM
    matches
GROUP BY
    toss_winner
    ORDER BY win_percentage desc;
    
    
    
    
    
    -- percentage of win after winning a toss and elected to bat

 
SELECT
    toss_winner,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN winner = toss_winner AND toss_decision='bat' THEN 1 ELSE 0 END) AS toss_win_matches_bat,
    ROUND(SUM(CASE WHEN winner = toss_winner AND toss_decision='bat'  THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS win_percentage
FROM
    matches
GROUP BY
    toss_winner
    ORDER BY win_percentage desc; 


    
    
    

    
-- Total matches played by each team

SELECT team_name, SUM(total_games) AS total_games_played
FROM (
    SELECT team1 AS team_name, COUNT(*) AS total_games
    FROM matches
    GROUP BY team1

    UNION ALL

    SELECT team2 AS team_name, COUNT(*) AS total_games
    FROM matches
    GROUP BY team2
) AS combined_teams
GROUP BY team_name
ORDER BY total_games_played DESC; 





-- Total number of toss wins by each team

SELECT team_name, SUM(total_toss_wins) AS total_toss_wins
FROM (
    SELECT team1 AS team_name, COUNT(*) AS total_toss_wins
    FROM matches
    WHERE toss_winner = team1
    GROUP BY team1

    UNION ALL

    SELECT team2 AS team_name, COUNT(*) AS total_toss_wins
    FROM matches
    WHERE toss_winner = team2
    GROUP BY team2
) AS combined_teams
GROUP BY team_name
ORDER BY total_toss_wins DESC;



-- Now percentage of toss win by each team
SELECT
    combined_teams.team_name,
    total_games_played,
    total_toss_wins,
    ROUND(total_toss_wins / total_games_played * 100, 2) AS toss_win_percentage
FROM (
    SELECT team_name, SUM(total_games) AS total_games_played
    FROM (
        SELECT team1 AS team_name, COUNT(*) AS total_games
        FROM matches
        GROUP BY team1

        UNION ALL

        SELECT team2 AS team_name, COUNT(*) AS total_games
        FROM matches
        GROUP BY team2
    ) AS games
    GROUP BY team_name
) AS combined_teams
JOIN (
    SELECT team_name, SUM(total_toss_wins) AS total_toss_wins
    FROM (
        SELECT team1 AS team_name, COUNT(*) AS total_toss_wins
        FROM matches
        WHERE toss_winner = team1
        GROUP BY team1

        UNION ALL

        SELECT team2 AS team_name, COUNT(*) AS total_toss_wins
        FROM matches
        WHERE toss_winner = team2
        GROUP BY team2
    ) AS toss_wins
    GROUP BY team_name
) AS combined_toss_wins ON combined_teams.team_name = combined_toss_wins.team_name
ORDER BY toss_win_percentage DESC;




-- Which team won most on each venue


SELECT
    venue,
    winner AS team_name,
    COUNT(*) AS max_wins
FROM
    matches
GROUP BY
    venue,
    winner
HAVING
    COUNT(*) = (
        SELECT MAX(win_count)
        FROM (
            SELECT venue, winner, COUNT(*) AS win_count
            FROM matches
            GROUP BY venue, winner
        ) AS win_counts
        WHERE win_counts.venue = matches.venue
    )
    ORDER BY VENUE;
    
    UPDATE matches
SET VENUE = 'MA Chidambaram Stadium'
WHERE VENUE = 'M. A. Chidambaram Stadium';

   UPDATE matches
SET VENUE = 'MA Chidambaram Stadium'
WHERE VENUE = 'MA Chidambaram Stadium, Chepauk';

   UPDATE matches
SET VENUE = 'Punjab Cricket Association Stadium, Mohali'
WHERE VENUE = 'Punjab Cricket Association IS Bindra Stadium, Mohali';


-- List of all man of the match 

SELECT player_of_match, COUNT(*) AS num_times_awarded
FROM matches
WHERE player_of_match <> ''
GROUP BY player_of_match
ORDER BY num_times_awarded DESC;


-- Team winning maximum games in one season

SELECT season, winner AS winning_team, COUNT(*) AS num_wins
FROM matches
GROUP BY season, winner
HAVING COUNT(*) = (
    SELECT MAX(wins_count)
    FROM (
        SELECT season, winner, COUNT(*) AS wins_count
        FROM matches
        GROUP BY season, winner
    ) AS wins_per_team
    WHERE wins_per_team.season = matches.season)
    ORDER BY SEASON;
    
    
    
    
-- Now joining a table where we have a champions of each season and observing whether most winning team is champion or not


SELECT
    matches.season,
    matches.max_winner_of_season,
    seasonwinner.champions,
    CASE WHEN matches.max_winner_of_season = seasonwinner.champions THEN 'Same' ELSE 'Different' END AS same_or_different
FROM (
    SELECT
        m.season,
        m.winner AS max_winner_of_season
    FROM (
        SELECT
            season,
            winner,
            ROW_NUMBER() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS rank_val
        FROM matches
        GROUP BY season, winner
    ) AS m
    WHERE m.rank_val = 1
) AS matches
JOIN seasonwinner ON matches.season = seasonwinner.season;



-- Now showing only those season where maximum winners and champions are same

SELECT
    matches.season,
    matches.max_winner_of_season,
    seasonwinner.champions
FROM (
    SELECT
        m.season,
        m.winner AS max_winner_of_season
    FROM (
        SELECT
            season,
            winner,
            ROW_NUMBER() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS rank_val
        FROM matches
        GROUP BY season, winner
    ) AS m
    WHERE m.rank_val = 1
) AS matches
JOIN seasonwinner ON matches.season = seasonwinner.season AND matches.max_winner_of_season = seasonwinner.champions;




--  close games between each team
SELECT
    id,
    team1,
    team2,
    winner,
    win_by_runs,
    win_by_wickets
    
FROM matches
WHERE  ( win_by_runs < 5 AND win_by_wickets= 0)
   OR (win_by_wickets < 3 AND  win_by_runs = 0);


-- Close games by CSK
SELECT
    id,
    team1,
    team2,
    winner,
    win_by_runs,
    win_by_wickets
FROM matches
WHERE ((win_by_runs < 10 AND win_by_wickets = 0) OR (win_by_wickets < 3 AND win_by_runs = 0))
    AND winner = 'Chennai super kings';
    
-- Close games by Mumbai Indians
SELECT
    id,
    team1,
    team2,
    winner,
    win_by_runs,
    win_by_wickets
FROM matches
WHERE ((win_by_runs < 10 AND win_by_wickets = 0) OR (win_by_wickets < 3 AND win_by_runs = 0))
    AND winner = 'Mumbai Indians';    


   
-- Count of close wins by each team 
   
SELECT winner, COUNT(*) AS count_close_wins
FROM (
    SELECT winner
    FROM matches
    WHERE ((win_by_runs < 10 AND win_by_wickets = 0) OR (win_by_wickets < 3 AND win_by_runs = 0))
) AS close_matches
GROUP BY winner ORDER BY count_close_wins DESC;


-- Number of games Won by large margin

SELECT 
    id,
    date,
    team1,
    team2,
    winner,
    CASE WHEN win_by_runs > 40 THEN CONCAT('Win by ', win_by_runs, ' runs')
         WHEN win_by_wickets > 7 THEN CONCAT('Win by ', win_by_wickets, ' wickets')
         ELSE 'N/A'
    END AS result
FROM matches
WHERE win_by_runs > 40 OR win_by_wickets > 7;

-- Teams winning by large margin and their count

SELECT winner, COUNT(*) AS count_large_margin_wins
FROM matches
WHERE win_by_runs > 40 OR win_by_wickets > 7
GROUP BY winner
ORDER BY count_large_margin_wins DESC;


	

--  Superover matches list

SELECT 
	date,
    team1,
    team2,
    winner,
    result
    FROM matches WHERE result='tie';
    
    
    
    
-- which team was involved in most superovers


SELECT team, COUNT(*) AS count_tie_results
FROM (
    SELECT team1 AS team
    FROM matches
    WHERE result = 'Tie'
    
    UNION ALL
    
    SELECT team2 AS team
    FROM matches
    WHERE result = 'Tie'
) AS tie_teams
GROUP BY team
ORDER BY count_tie_results DESC;



-- Which team won most superovers

SELECT 
     winner,
     count(*) AS no_of_times_won
     FROM matches where result='tie'
GROUP BY 
winner;
    
    
   
   
















    
    


