CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_load_analysis` AS
WITH base AS (
SELECT
    season, Date, Opp, Result, MP, game_number, total_minutes,
    PTS, FG, FGA, FT, FTA, `2P`, `2PA`, `3P`, `3PA`,
    AST, STL, BLK, TOV, Plus_minus, injury_flag,
    ROUND(AVG(total_minutes) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 1) AS rolling_5_avg_minutes,
    ROUND(AVG(total_minutes) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
    ), 1) AS rolling_10_avg_minutes,
    ROUND(SUM(total_minutes) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 1) AS cumulative_minutes,
    ROUND(
        AVG(total_minutes) OVER (
            PARTITION BY season ORDER BY Date
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) /
        NULLIF(AVG(total_minutes) OVER (
            PARTITION BY season ORDER BY Date
            ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
        ), 0)
    , 2) AS acwr,
    ROUND(
        CAST(PTS AS FLOAT64) /
        NULLIF(2 * (CAST(FGA AS FLOAT64) + 0.44 * CAST(FTA AS FLOAT64)), 0)
    , 3) AS true_shooting_pct,
    ROUND(
        SAFE_DIVIDE(CAST(`3P` AS FLOAT64), CAST(`3PA` AS FLOAT64))
    , 3) AS three_point_pct,
    CAST(Plus_minus AS FLOAT64) AS plus_minus_num,
    ROUND(AVG(
        CAST(PTS AS FLOAT64) /
        NULLIF(2 * (CAST(FGA AS FLOAT64) + 0.44 * CAST(FTA AS FLOAT64)), 0)
    ) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 3) AS rolling_5_ts_pct,
    ROUND(AVG(
        SAFE_DIVIDE(CAST(`3P` AS FLOAT64), CAST(`3PA` AS FLOAT64))
    ) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 3) AS rolling_5_3p_pct,
    ROUND(AVG(
        CAST(Plus_minus AS FLOAT64)
    ) OVER (
        PARTITION BY season ORDER BY Date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 1) AS rolling_5_plus_minus,
    ROUND(AVG(
        CAST(PTS AS FLOAT64) /
        NULLIF(2 * (CAST(FGA AS FLOAT64) + 0.44 * CAST(FTA AS FLOAT64)), 0)
    ) OVER (
        PARTITION BY season
    ), 3) AS season_avg_ts_pct,
    ROW_NUMBER() OVER (
        PARTITION BY season ORDER BY Date
    ) AS healthy_game_number
FROM `nba_data.curry_with_flags`
WHERE injury_flag = 'Healthy'
),

season_avgs AS (
    SELECT season, ROUND(AVG(three_point_pct), 3) AS season_avg_3p_pct
    FROM base
    GROUP BY season
)

SELECT
    b.*, s.season_avg_3p_pct,
    CASE
        WHEN b.cumulative_minutes < 1000 THEN '1: 0-999 min'
        WHEN b.cumulative_minutes < 1500 THEN '2: 1000-1499 min'
        WHEN b.cumulative_minutes < 2000 THEN '3: 1500-1999 min'
        ELSE '4: 2000+ min'
    END AS load_bucket,
    CASE
        WHEN b.healthy_game_number <= 20 THEN 'First third'
        WHEN b.healthy_game_number <= 40 THEN 'Second third'
        ELSE 'Final third'
    END AS season_third,
    CASE
        WHEN b.cumulative_minutes >= 1000
         AND b.rolling_5_ts_pct < b.season_avg_ts_pct
            THEN 'Fatigue_signal'
        ELSE 'Normal'
    END AS fatigue_flag
FROM base b
JOIN season_avgs s ON b.season = s.season
ORDER BY b.season, b.Date;
