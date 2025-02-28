library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(plotly)
library(packcircles)
library(bslib)
library(viridis)

# Load the Star Wars dataset
data("starwars")

# Define movies in chronological (story) order
movie_order <- c("The Phantom Menace", "Attack of the Clones", "Revenge of the Sith",
                 "A New Hope", "The Empire Strikes Back", "Return of the Jedi",
                 "The Force Awakens")

ui <- fluidPage(
  theme = bs_theme(
    version = 4,
    bootswatch = "slate",
    base_font = font_google("Open Sans")
  ),
  
  tags$style(HTML("
    /* --- Selectize Input Styles --- */
    .selectize-control.single .selectize-input {
      background-color: #222222 !important;
      color: #ffffff !important;
      border: 1px solid #555555 !important;
      border-radius: 4px !important;
    }
    .selectize-control.single .selectize-input .item {
      background-color: #333333 !important;
      color: #ffffff !important;
      border-radius: 4px !important;
    }
    .selectize-dropdown {
      background-color: #222222 !important;
      border: 1px solid #555555 !important;
    }
    .selectize-dropdown-content .option:hover {
      background-color: #444444 !important;
      color: #ffffff !important;
    }
    
    /* --- Slider Styles --- */
    /* The main slider track line */
    .irs-line {
      background-color: #444444 !important;
      border: 1px solid #555555 !important;
    }
    /* The selected (filled) portion of the slider track */
    .irs-bar {
      background-color: #666666 !important;
      border: 1px solid #555555 !important;
    }
    /* The slider handle (the circle you drag) */
    .irs-handle {
      background-color: #888888 !important;
      border: 1px solid #aaaaaa !important;
    }
    /* Optional: Lighten the min/max labels too */
    .irs-min, .irs-max, .irs-from, .irs-to {
      color: #ffffff !important;
    }
  ")),
  
  titlePanel(
    div("Star Wars Planets: Where characters come from?",
        style = "font-size: 24px; color: #ffffff;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      radioButtons("selectionType", "Choose Selection Mode:",
                   choices = c("Pick One Movie" = "single",
                               "Cumulative Selection" = "cumulative"),
                   selected = "cumulative"),
      conditionalPanel(
        condition = "input.selectionType == 'single'",
        selectInput("movie", "Select a Movie:", choices = movie_order)
      ),
      conditionalPanel(
        condition = "input.selectionType == 'cumulative'",
        sliderInput("movieCount", "Select Number of Movies:",
                    min = 1, max = length(movie_order), value = 1, step = 1)
      )
    ),
    mainPanel(
      h5("Hover over a planet to see details",
         style = "margin-bottom: 10px; color: #dddddd;"),
      
      plotlyOutput("planetPlot", width = "100%", height = "400px"),
      width = 9
    )
  )
)



# Define Server
server <- function(input, output) {
  
  # Filter data
  filtered_data <- reactive({
    req(input$selectionType)
    selected_movies <- ifelse(input$selectionType == "single", input$movie, movie_order[1:input$movieCount])
    starwars %>%
      filter(!is.na(homeworld), !is.na(films)) %>%
      unnest_longer(films) %>%
      filter(films %in% selected_movies)
  })
  
  output$planetPlot <- renderPlotly({
    data <- filtered_data()
    if (nrow(data) == 0) return(NULL)
    
    # Count characters per homeworld & keep top 15
    planet_counts <- data %>%
      count(homeworld, name = "num_characters") %>%
      arrange(desc(num_characters)) %>%
      slice_head(n = 15)
    
    # Circle packing
    packing_init <- circleProgressiveLayout(
      planet_counts$num_characters,
      sizetype = "area"
    )
    packing_repel <- circleRepelLayout(packing_init, maxiter = 2000)
    planet_counts <- cbind(planet_counts, packing_repel$layout)
    
    # Polygon coordinates
    circle_data <- circlePlotData(packing_repel$layout, npoints = 100)
    circle_data$homeworld <- planet_counts$homeworld[circle_data$id]
    circle_data$num_characters <- planet_counts$num_characters[circle_data$id]
    
    # Build ggplot
    p <- ggplot(circle_data, aes(
      x = x, y = y,
      text = paste0("<b>Planet:</b> ", homeworld, "<br><b>Characters:</b> ", num_characters)
    )) +
      
      # Main fill layer (crisper outline)
      geom_polygon(
        aes(group = id, fill = homeworld),
        color = "gray80",
        size = 0.8,
        alpha = 1
      ) +
      coord_fixed() +
      scale_fill_viridis_d(option = "plasma") +
      theme_void(base_family = "Open Sans") +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        legend.position = "none",
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5, color = "#ffffff"),
        plot.margin = margin(30, 30, 30, 30)
      ) +
      labs(title = NULL)
    
    # Convert to Plotly
    ggplotly(p, tooltip = "text") %>%
      config(displayModeBar = FALSE) %>%
      layout(
        # Hide axes entirely
        xaxis = list(
          showline = FALSE,
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE,
          scaleanchor = "y", 
          scaleratio = 1
        ),
        yaxis = list(
          showline = FALSE,
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE,
          scaleanchor = "x"
        ),
        autosize = TRUE,
        margin = list(l = 30, r = 30, t = 30, b = 30),
        font = list(size = 12),
        hoverlabel = list(
          font = list(size = 16),
          bordercolor = "#dddddd",
          bgcolor = "#333333"
        )
      )
  })
}

shinyApp(ui, server)
