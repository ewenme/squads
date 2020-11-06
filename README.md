squads
================

Data on European football clubs' playing squads, seasons 2004/05 through 2020/21 (as found on
[Transfermarkt](https://www.transfermarkt.co.uk/)).

Data
----

Squads can be found in the `data` directory, in .csv format. There's a sub-directory for each year/season (e.g. 2018/19 season is in `data/2018`) containing data for each of these leagues:

- English Premier League
- English Championship
- French Ligue 1
- German 1.Bundesliga
- Italian Serie A
- Spanish La Liga 
- Portugese Liga NOS
- Dutch Eredivisie
- Russian Premier Liga

Common variables:

  - `player_name` (player name)
  - `position` (preferred position)
  - `date_of_birth` (date of birth)
  - `age` (age, at time of scrape)
  - `nationality` (primary nationality)
  - `club_name` (club of player)
  - `league_name` (league of player)
  - `season` (season, interpolated from `year`)
  - `year` (year)

Code
----

All source code for producing this dataset can be found in the `src` directory.

Usage
-----

- [Relative age effect viz](https://www.reddit.com/r/dataisbeautiful/comments/83ejdw/relative_age_effect_in_english_footballers_your/) by [@ewen_](twitter.com/ewen_)

Sources
-------

All data was scraped from
[Transfermarkt](https://www.transfermarkt.co.uk/), in accordance with
their [terms of use](https://www.transfermarkt.co.uk/intern/anb).
