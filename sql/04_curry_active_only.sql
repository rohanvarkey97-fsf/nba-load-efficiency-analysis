CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_active_only` AS
SELECT
    season, Date, Opp, Result, MP, game_number, total_minutes,
    PTS, FG, FGA, FT, FTA, `2P`, `2PA`, `3P`, `3PA`,
    AST, STL, BLK, TOV, Plus_minus
FROM `nba_data.curry_with_minutes`
WHERE total_minutes IS NOT NULL
ORDER BY season, Date;
