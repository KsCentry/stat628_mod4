library(shiny)
library(ggplot2)
library(dplyr)

df <- readRDS("episodes.rds")

ui <- fluidPage(
  titlePanel("Episode Similarity Finder"),
  sidebarLayout(
    sidebarPanel(
      selectInput("search_show", "Filter by Show (optional):",
                  choices = c("All Shows", unique(df$ShowName)), selected = "All Shows"),
      textInput("search_episode", "Search an Episode:", value = ""),
      HTML("<p><strong>Note:</strong> Click the button each time you select
           a new episode to refresh the chart.</p>"),
      actionButton("find_similar", "Find Similar Episodes"),
      uiOutput("matched_episodes"),
      h4("Contact Information:"),
      p("For any inquiries, please contact app maintainer:"),
      p("Hengyu Yang: hyang644@wisc.edu")
    ),
    mainPanel(
      plotOutput("similarity_plot", click = "plot_click"),
      verbatimTextOutput("episode_info")
    )
  )
)

server <- function(input, output, session) {
  filtered_df <- reactive({
    if (input$search_show == "All Shows") {
      df
    } else {
      df %>% filter(ShowName == input$search_show)
    }
  })
  
  matched_episodes <- reactive({
    req(input$search_episode)
    filtered_df() %>%
      filter(grepl(input$search_episode, EpisodeName, ignore.case = TRUE)) %>%
      slice_head(n = 10)
  })
  
  output$matched_episodes <- renderUI({
    req(matched_episodes())
    selectInput("selected_episode", "Select an Episode:",
                choices = matched_episodes()$EpisodeName, selected = matched_episodes()$EpisodeName[1])
  })
  
  selected_episode <- reactive({
    req(input$selected_episode)
    df %>% filter(EpisodeName == input$selected_episode)
  })
  
  similar_episodes <- eventReactive(input$find_similar, {
    req(selected_episode())
    target <- selected_episode()
    df %>%
      mutate(distance = sqrt((subjectivity_score - target$subjectivity_score)^2 +
                               (sentiment_score - target$sentiment_score)^2)) %>%
      arrange(distance) %>%
      slice(2:31)
  })
  
  output$similarity_plot <- renderPlot({
    req(similar_episodes(), selected_episode())
    target <- selected_episode()
    
    ggplot() +
      geom_point(data = similar_episodes(), 
                 aes(x = subjectivity_score, y = sentiment_score), 
                 color = "blue", size = 3, alpha = 0.8) +
      geom_point(data = target, 
                 aes(x = subjectivity_score, y = sentiment_score), 
                 color = "red", size = 5, alpha = 1) +
      theme_minimal(base_size = 16) +
      labs(
        title = "Top 30 Similar Episodes",
        x = "Subjectivity Score",
        y = "Sentiment Score"
      ) +
      theme(
        legend.position = "none",
        plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 14)
      )
  })
  
  output$episode_info <- renderText({
    req(input$plot_click)
    clicked_point <- nearPoints(similar_episodes(), input$plot_click, maxpoints = 1)
    if (nrow(clicked_point) > 0) {
      paste(
        "Show Name:", clicked_point$ShowName,
        "\nEpisode Name:", clicked_point$EpisodeName,
        "\nURL:", clicked_point$URL,
        "\nSubjectivity Score:", round(clicked_point$subjectivity_score, 3),
        "\nSentiment Score:", round(clicked_point$sentiment_score, 3)
      )
    } else {
      "Click on a point to see Episode details."
    }
  })
}

shinyApp(ui, server)
