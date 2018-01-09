# session -------------------------------------------

library(rvest)
library(dplyr)
library(stringr)
library(lubridate)

# scrape birthdays for epl ------------------------

# read league html page
league_page <- read_html("https://www.transfermarkt.co.uk/premier-league/startseite/wettbewerb/GB1")

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

# read club html page
club_page <- read_html(paste0("https://www.transfermarkt.co.uk", club_urls[[1]]))

# extract player data
player_data <- html_nodes(club_page, "#yw1.grid-view") %>%
  html_node("table") %>%
  html_table(fill = TRUE, header=TRUE) %>%
  bind_rows()

# select cols to keep
player_data <- player_data[, c(1, 5, 6, 7)]

# set colnames
colnames(player_data) <- c("shirt_number","position","name","birthday")

# remove empty rows
player_data <- filter(player_data, !is.na(name))

# create age col
player_data['age'] <- gsub(".*\\((.*)\\).*", "\\1", player_data$birthday)

# normalise bday col
player_data['birthday'] <- gsub("\\s*\\([^\\)]+\\)","",as.character(player_data$birthday))
player_data$birthday <- mdy(player_data$birthday)
