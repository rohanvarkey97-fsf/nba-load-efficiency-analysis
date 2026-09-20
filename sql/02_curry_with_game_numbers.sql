CREATE OR REPLACE VIEW `third-oarlock-408819.nba_data.curry_with_game_numbers` AS
SELECT 
    Result, season, Date, Opp, MP, PTS, FG, FGA, FT, FTA,
    `2P`, `2PA`, `3P`, `3PA`, AST, STL, BLK, TOV, Plus_minus,
    ROW_NUMBER() OVER (PARTITION BY season ORDER BY Date) AS game_number
FROM `nba_data.curry_all_seasons`
ORDER BY season, Date;
