library(httr)
library(jsonlite)
library(dplyr)
library(stringr)
library(spotifyr)

id <- "c244xxxxxxxxxxxxxxxx"
secret <- "816xxxxxxxxxxxxxxxxx"

Sys.setenv(SPOTIFY_CLIENT_ID = id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = secret)
access_token <- get_spotify_access_token()

categories <- list(
  "News%20%26%20Current%20Events",
  "Education%20%26%20Knowledge",
  "Technology%20%26%20Innovation",
  "Health%20%26%20Wellness",
  "Entertainment",
  "Business%20%26%20Finance",
  "Sports%20%26%20Recreation",
  "Lifestyle%20%26%20Culture"
)

search_shows <- function (q, offset = 0, type = "show", market = "US", limit = 50,
                          authorization = get_spotify_access_token()) 
{
  base_url <- "https://api.spotify.com/v1/search"
  params <- list(q = q, type = type, market = market, limit = limit,
                 offset = offset, access_token = authorization)
  res <- RETRY("GET", base_url, query = params, encode = "json")
  stop_for_status(res)
  res <- fromJSON(content(res, as = "text", encoding = "UTF-8"), 
                  flatten = TRUE)
  res
}

category_show_ids <- list()
for (category in categories) {
  show <- search_shows(q = category)
  ids <- show$shows$items$id
  names <- show$shows$items$name
  category_show_ids[[category]] <- data.frame(
    ShowID = ids,
    ShowName = names,
    stringsAsFactors = FALSE
  )
  show <- search_shows(q = category, offset = 50)
  ids <- show$shows$items$id
  names <- show$shows$items$name
  category_show_ids[[category]] <- data.frame(
    ShowID = ids,
    ShowName = names,
    stringsAsFactors = FALSE
  )
  Sys.sleep(1)
}

category_shows <- do.call(rbind, lapply(names(category_show_ids), function(category) {
  data.frame(
    Category = category,
    ShowID = category_show_ids[[category]]$ShowID,
    ShowName = category_show_ids[[category]]$ShowName,
    stringsAsFactors = FALSE
  )
}))

write.csv(category_shows, "category_shows.csv", row.names = FALSE)


final_df <- data.frame(
  Category = character(),
  ShowID = character(),
  ShowName = character(),
  EpisodeID = character(),
  EpisodeName = character(),
  URL = character(),
  Description = character(),
  stringsAsFactors = FALSE
)

for (category in names(category_show_ids)) {
  show_data <- category_show_ids[[category]]
  show_ids <- show_data$ShowID
  show_names <- show_data$ShowName
  
  for (i in seq_along(show_ids)) {
    show_id <- show_ids[i]
    show_name <- show_names[i]
    show_eps <- get_show_episodes(show_id, limit = 30)
    episode_ids <- show_eps$id
    episode_names <- show_eps$name
    urls <- show_eps$external_urls.spotify
    descriptions <- show_eps$description
    
    temp_df <- data.frame(
      Category = category,
      ShowID = show_id,
      ShowName = show_name,
      EpisodeID = episode_ids,
      EpisodeName = episode_names,
      URL = urls,
      Description = descriptions,
      stringsAsFactors = FALSE
    )
    final_df <- rbind(final_df, temp_df)
    Sys.sleep(1)
  }
}

final_df$Category <- str_replace_all(final_df$Category, "%20", " ")
final_df$Category <- str_replace_all(final_df$Category, "%26", "&")
write.csv(final_df, "all_episodes.csv", row.names = FALSE)

