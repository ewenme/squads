
# setup -------------------------------------------------------------------

# load functions / install packages
source("./src/10-global.R")

# load packages
library(rvest)
library(dplyr)
library(lubridate)
library(readr)
library(purrr)

# set league urls to scrape
league_urls <- c("https://www.transfermarkt.co.uk/premier-league/startseite/wettbewerb/GB1",
                 "https://www.transfermarkt.co.uk/championship/startseite/wettbewerb/GB2",
                 "https://www.transfermarkt.co.uk/league-one/startseite/wettbewerb/GB3",
                 "https://www.transfermarkt.co.uk/league-two/startseite/wettbewerb/GB4",
                 "https://www.transfermarkt.com/1-bundesliga/startseite/wettbewerb/L1",
                 "https://www.transfermarkt.com/primera-division/startseite/wettbewerb/ES1",
                 "https://www.transfermarkt.com/serie-a/startseite/wettbewerb/IT1",
                 "https://www.transfermarkt.com/ligue-1/startseite/wettbewerb/FR1")

# set season
season <- 2018

# scrape ------------------------------------------------------------------

# scrape squads for current season
squads <- map_dfr(league_urls, scrape_league_squads, season)

# get season name
season <- gsub(pattern = "/", replacement = "", unique(squads$season))

# export data
write_csv(squads, file.path(paste0("data/", season, "_", "squads.csv")))
