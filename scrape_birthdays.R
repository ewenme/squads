# session -------------------------------------------

library(rvest)
library(dplyr)
library(stringr)
library(lubridate)

# functions -----------------------------------------

# scrape league clubs
scrape_clubs <- function(league_url) {
  
  # read league html page
  league_page <- read_html(league_url)
  
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
  
  # create data frame to return
  clubs <- data_frame(league_url=league_url, club_name=club_names, club_url=club_urls)
  
  return(clubs)
  
}

# scrape squad data
scrape_squad <- function(club_url) {
  
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
colnames(player_data) <- c("shirt_number", "position", "name", "birthday")

# set shirt no as numeric
player_data$shirt_number <- as.numeric(player_data$shirt_number )

# remove empty rows
player_data <- filter(player_data, !is.na(name))

# create age col
player_data['age'] <- gsub(".*\\((.*)\\).*", "\\1", player_data$birthday)

# normalise bday col
player_data['birthday'] <- gsub("\\s*\\([^\\)]+\\)","",as.character(player_data$birthday))
player_data$birthday <- mdy(player_data$birthday)

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


# do ---------------------------------------------------------

# scrape EPL league metadata
epl <- scrape_clubs("https://www.transfermarkt.co.uk/premier-league/startseite/wettbewerb/GB1")

# scrape EPl club squad data
epl_squads <- lapply(epl$club_url, scrape_squad)
epl_squads <- bind_rows(epl_squads)

# join EPL league data
epl_squads <- inner_join(epl_squads, epl, by="club_url")

# select cols to keep
epl_squads <- select(epl_squads, shirt_number:nationality, club_name)
