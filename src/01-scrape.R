
# setup -------------------------------------------------------------------

# load functions / packages
source("src/00-setup.R")

# set league urls to scrape
league_meta <- tibble(
  league_id = c(
    "GB1", "GB3", "GB4", "ES1", "L1", "IT1", "FR1", "GB2", "PO1", "NL1", "RU1"
    ),
  league_name = c(
    "premier-league", "league-one", "league-two", "primera-division", 
    "1-bundesliga", "serie-a", "ligue-1", "championship", "liga-nos", 
    "eredivisie", "premier-liga"
    )
)

# seasons to scrape
seasons <- 2019:2020

# create directory tree
fs::dir_create(path = file.path("data", seasons))

# scrape ------------------------------------------------------------------

squads <- map2(league_meta$league_id, league_meta$league_name, function(x, y){

  # edit league name for file name
  league_name_edit <- gsub("-", "_", y)
  
  # scrape data
  lapply(seasons, function(z) {
    
    data <- scrape_league_squads(league_id = x, league_name = y, season_id = z)
    
    # write to disk
    invisible(
      write_csv(data, path = glue("data/{z}/{league_name_edit}.csv"))
    )
    
    data
  })
})

