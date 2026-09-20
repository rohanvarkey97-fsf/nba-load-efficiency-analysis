CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_with_flags` AS
WITH base AS (
  SELECT *,
    CASE 
      WHEN MP IN ('Inactive', 'Did Not Play', 'Did Not Dress', 'Not With Team') THEN 1 
      ELSE 0 
    END AS is_inactive
  FROM `nba_data.curry_with_minutes`
),

lagged AS (
  SELECT *,
    LAG(is_inactive, 1, -1) 
      OVER (PARTITION BY season ORDER BY game_number) AS prev_is_inactive
  FROM base
),
consecutive_groups AS (
  SELECT *,
    SUM(CASE 
          WHEN is_inactive != prev_is_inactive
          THEN 1 ELSE 0 
        END) 
    OVER (PARTITION BY season ORDER BY game_number
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS group_id
  FROM lagged
),
group_lengths AS (
  SELECT *,
    COUNT(*) OVER (
      PARTITION BY season, group_id
    ) AS group_length
  FROM consecutive_groups
),
absence_lagged AS (
  SELECT *,
    LAG(is_inactive) OVER (PARTITION BY season ORDER BY game_number) AS prev_is_inactive_2,
    LAG(group_length) OVER (PARTITION BY season ORDER BY game_number) AS prev_group_length
  FROM group_lengths
),
absence_flags AS (
  SELECT *,
    CASE
      WHEN is_inactive = 1 AND group_length >= 5
        THEN 'Injury_absence'
      WHEN is_inactive = 0
       AND prev_is_inactive_2 = 1
       AND prev_group_length >= 5
        THEN 'First_game_back'
      ELSE 'Other'
    END AS initial_flag
  FROM absence_lagged
),

return_periods AS (
  SELECT *,
    SUM(CASE WHEN initial_flag = 'First_game_back' THEN 1 ELSE 0 END)
      OVER (PARTITION BY season ORDER BY game_number
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS return_period
  FROM absence_flags
),

numbered AS (
  SELECT *,
    CASE 
      WHEN is_inactive = 0
        THEN ROW_NUMBER() OVER (
               PARTITION BY season, return_period
               ORDER BY game_number
             )
      ELSE NULL
    END AS games_since_return
  FROM return_periods
)

SELECT
    season, Date, Opp, Result, MP, game_number, total_minutes,
    PTS, FG, FGA, FT, FTA, `2P`, `2PA`, `3P`, `3PA`,
    AST, STL, BLK, TOV, Plus_minus,
    CASE
      WHEN initial_flag = 'Injury_absence' 
        THEN 'Injury_absence'
      WHEN is_inactive = 0 
       AND return_period > 0 
       AND games_since_return <= 5
        THEN 'Post_injury_return'
      WHEN is_inactive = 1 
        THEN 'Load_management'
      ELSE 'Healthy'
    END AS injury_flag
FROM numbered
ORDER BY season, Date;
