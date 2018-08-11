European league football squads' data
================

Overview
--------

Football club squads' data.

Leagues:

-   Premier League (England)
-   Championship (England)
-   League One (England)
-   League Two (England)
-   1.Bundesliga (Germany)
-   LaLiga (Spain)
-   Serie A (Italy)
-   Ligue 1 (France)

Seasons:

-   2017/18
-   2018/19

Data
----

Player-level data in .csv format (filenames follow a `<season_start_year>_squads` naming convention).

-   `shirt_number` (shirt number)
-   `position` (preferred position)
-   `name` (full name)
-   `date_of_birth` (date of birth)
-   `age` (age at time of scrape)
-   `nationality` (primary nationality)
-   `club_name` (club)
-   `league_name` (league)
-   `season` (league season)

Usage
-----

Relative age effect visualisation:

<img src="./figures/english_age_effect.png" width="582" />

Code
----

-   `scrape_squads.R` code used to scrape squad data
-   `age_effect_viz.R` code used to visualise relative age effect

Sources
-------

All squad data was scraped from [Transfermarkt](https://www.transfermarkt.co.uk/), in accordance with their [terms of use](https://www.transfermarkt.co.uk/intern/anb).
