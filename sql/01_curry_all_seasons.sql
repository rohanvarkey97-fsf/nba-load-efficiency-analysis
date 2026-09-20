CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_all_seasons` AS
SELECT '2022-23' AS season,
       Result, Rk, Date, Opp, MP, PTS, FG, FGA, FT, FTA,
       `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus
FROM `nba_data.curry_gamelog_2023`
WHERE Rk IS NOT NULL

UNION ALL

SELECT '2023-24' AS season,
       Result, Rk, Date, Opp, MP, PTS, FG, FGA, FT, FTA,
       `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus
FROM `nba_data.curry_gamelog_2024`
WHERE Rk IS NOT NULL

UNION ALL

SELECT '2024-25' AS season,
       Result, Rk, Date, Opp, MP, PTS, FG, FGA, FT, FTA,
       `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus
FROM `nba_data.curry_gamelog_2025`
WHERE Rk IS NOT NULL

UNION ALL

SELECT '2025-26' AS season,
       Result, Rk, Date, Opp, MP, PTS, FG, FGA, FT, FTA,
       `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus
FROM `nba_data.curry_gamelog_2026`
WHERE Rk IS NOT NULL;
