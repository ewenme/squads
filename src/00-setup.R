
# dependencies ------------------------------------------------------------

# install pacman if missing
if (!require("pacman")) install.packages("pacman")

# install any missing packages
pacman::p_load("rvest", "glue", "janitor", "dplyr", "lubridate", "purrr",
               "fs", "readr")

# functions ---------------------------------------------------------------

# scrape league clubs
scrape_club_meta <- function(league_id, league_name, season_id) {
  
  # read league html page
  league_page <- read_html(glue("https://www.transfermarkt.com/{league_name}/startseite/wettbewerb/{league_id}/plus/?saison_id={season_id}"))
  
  # extract league club urls
  club_urls <- html_nodes(league_page, "#yw1 .no-border-links") %>%
    html_node("a") %>%
    html_attr(name = "href") %>%
    unique()
  
  # extract league club names
  club_names <- html_nodes(league_page, "#yw1.grid-view") %>%
    html_node("table") %>%
    html_table(fill = TRUE, header = TRUE) %>% 
    .[[1]] %>% 
    clean_names(case = "snake") %>% 
    pull(club_2)
  
  club_names <- club_names[club_names != ""]
  
  # extract league name
  league_name <- html_nodes(league_page, ".spielername-profil") %>%
    html_text()
  
  # extract season
  season <- paste0(season_id, "/", season_id + 1)
  
  # create data frame to return
  clubs <- tibble(club_name = club_names, club_url = club_urls, 
                  season = season, league_name = league_name)
  
  return(clubs)
  
}

# scrape squad data
scrape_club_squad <- function(club_url) {
  
  # read club html page
  club_page <- read_html(glue("https://www.transfermarkt.co.uk{club_url}"))
  
  # extract player data
  player_data <- html_nodes(club_page, "#yw1.grid-view") %>%
    html_node("table") %>%
    html_table(fill = TRUE, header = TRUE) %>%
    bind_rows() %>% 
    clean_names()
  
  # get player names
  player_names <- html_nodes(club_page, "#yw1 td") %>% 
    html_nodes(".hauptlink span a") %>% 
    html_attr("title") %>% 
    .[c(TRUE, FALSE)]
  
  # select cols to keep, check if current season
  if (!"current_club" %in% colnames(player_data)) {
    
    player_data <- player_data[, c("market_value", "nat", "x7")]
    
  } else {
    
    player_data <- player_data[, c("current_club", "market_value")]
    
  }
  
  # set colnames
  colnames(player_data) <- c("player_name", "position",  "date_of_birth")
  
  # remove empty rows
  player_data <- filter(player_data, !is.na(player_name))
  
  # replace names
  player_data$player_name <- player_names
  
  # create age col
  player_data$age <- gsub(".*\\((.*)\\).*", "\\1", player_data$date_of_birth)
  
  # normalise age cols
  player_data$date_of_birth <- gsub("\\s*\\([^\\)]+\\)", "", as.character(player_data$date_of_birth))
  player_data$date_of_birth <- suppressWarnings(mdy(player_data$date_of_birth))
  player_data$age <- suppressWarnings(as.numeric(player_data$age))
  
  # extract player nationalities
  player_list <- html_nodes(club_page, "#yw1.grid-view")
  player_data$nationality <- map_chr(seq_len(nrow(player_data)), function(x) {
    
    nat <- player_list %>%
      html_nodes(paste0("tr:nth-child(", x, ") img.flaggenrahmen")) %>%
      html_attr("title") %>% 
      head(1)
    
    ifelse(identical(nat, character(0)), "Unknown", nat)
  })
  
  # add club url cols
  player_data$club_url <- club_url
  
  return(player_data)
  
}

# scrape league (wrapper)
scrape_league_squads <- function(league_id, league_name, season_id) {
  
  # scrape league clubs metadata
  club_meta <- scrape_club_meta(league_id, league_name, season_id)
  
  # scrape league club squads data
  squads <- map_dfr(club_meta$club_url, scrape_club_squad)
  
  # join league metadata
  squads <- inner_join(squads, club_meta, by = "club_url")
  
  # select cols to keep
  squads <- select(squads, player_name:nationality, club_name, league_name, season)
  
  # add year
  squads$year <- season_id
  
  return(squads)
  
}
