
# packages ----------------------------------------------------------------

# install any missing packages
list.of.packages <- c("rvest", "tidyverse", "lubridate", "forcats", "hrbrthemes",
                      "ggalt")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

rm(list.of.packages, new.packages)


# functions ---------------------------------------------------------------

# scrape league clubs
scrape_club_meta <- function(league_url, season_start_year) {
  
  # read league html page
  league_page <- read_html(paste0(league_url, "/plus/?saison_id=", season_start_year))
  
  # extract league club urls
  club_urls <- html_nodes(league_page, "#yw1 .no-border-links") %>%
    html_node("a") %>%
    html_attr(name = "href") %>%
    unique()
  
  # extract league club names
  club_names <- html_nodes(league_page, "#yw1.grid-view") %>%
    html_node("table") %>%
    html_table(fill = TRUE, header=TRUE)
  
  club_names <- club_names[[1]][["name"]]
  club_names <- club_names[club_names != ""]
  
  # extract league name
  league_name <- html_nodes(league_page, ".spielername-profil") %>%
    html_text()
  
  # extract season
  season <- season_start_year %% 100 
  season <- paste0(season, "/", season+1)
  
  # create data frame to return
  clubs <- data_frame(league_url=league_url, league_name=league_name, 
                      club_name=club_names, club_url=club_urls, season=season)
  
  return(clubs)
  
}

# scrape squad data
scrape_club_squad <- function(club_url) {
  
  # read club html page
  club_page <- read_html(paste0("https://www.transfermarkt.co.uk", club_url))
  
  # extract player data
  player_data <- html_nodes(club_page, "#yw1.grid-view") %>%
    html_node("table") %>%
    html_table(fill = TRUE, header=TRUE) %>%
    bind_rows()
  
  # select cols to keep
  player_data <- player_data[, c(1, 5, 6, 7)]
  
  # set colnames
  colnames(player_data) <- c("shirt_number", "position", "name", "date_of_birth")
  
  # set shirt no as numeric
  player_data$shirt_number <- suppressWarnings(as.numeric(player_data$shirt_number ))
  
  # remove empty rows
  player_data <- filter(player_data, !is.na(name))
  
  # create age col
  player_data['age'] <- gsub(".*\\((.*)\\).*", "\\1", player_data$date_of_birth)
  
  # normalise age cols
  player_data['date_of_birth'] <- gsub("\\s*\\([^\\)]+\\)","",as.character(player_data$date_of_birth))
  player_data$date_of_birth <- suppressWarnings(mdy(player_data$date_of_birth))
  player_data$age <- suppressWarnings(as.numeric(player_data$age))
  
  # extract player nationalities
  player_list <- html_nodes(club_page, "#yw1.grid-view")
  
  player_nats <- list()
  for (i in 1:nrow(player_data)) {
    
    player_nat <- player_list %>%
      html_nodes(paste0("tr:nth-child(", i, ") img.flaggenrahmen")) %>%
      html_attr("title")
    
    player_nats[[i]] <- player_nat[[1]]
    
  }
  
  # add nationality and club url cols
  player_data$nationality <- unlist(player_nats)
  player_data$club_url <- club_url
  
  return(player_data)
  
}

# scrape league (wrapper)
scrape_league_squads <- function(league_url, season_start_year) {
  
  # scrape league clubs metadata
  club_meta <- scrape_club_meta(league_url, season_start_year)
  
  # scrape league club squads data
  squads <- lapply(club_meta$club_url, scrape_club_squad) %>% bind_rows()
  
  # join league metadata
  squads <- inner_join(squads, club_meta, by="club_url")
  
  # select cols to keep
  squads <- select(squads, shirt_number:nationality, club_name, league_name, season)
  
  return(squads)
  
}
