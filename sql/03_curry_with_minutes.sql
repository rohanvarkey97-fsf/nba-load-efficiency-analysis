CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_with_minutes` AS
SELECT
    Result, season, Date, Opp, MP, game_number, PTS, FG, FGA, FT, FTA,
    `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus,
    CASE 
        WHEN MP IN ('Inactive', 'Did Not Play', 'Did Not Dress', 'Not With Team')
        THEN NULL
        ELSE ROUND(
            CAST(SPLIT(MP, ':')[OFFSET(0)] AS FLOAT64) +
            CAST(SPLIT(MP, ':')[OFFSET(1)] AS FLOAT64) / 60
        , 1)
    END AS total_minutes
FROM `nba_data.curry_with_game_numbers`
ORDER BY season, Date;
