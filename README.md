# Podcast Data Analysis and Shiny App Development

## Repository Overview

This repository contains all the necessary scripts, data, 
and resources for analyzing podcast data, performing description analysis, 
and hosting an interactive Shiny app for data visualization and insights. 
The project includes data collection, description analysis scripts, and Shiny app implementation.

### Directory Structure

- **data/**: This folder stores raw and processed datasets used in the analysis.
Raw data is directly fetched and stored, while processed data is structured for further analysis.
- **code/**: Contains the R and Python scripts for:
  - Fetching podcast data from APIs.
  - Conducting text-based description analysis.
  - Hosting the Shiny app for visualization and interaction.

### How to Use the Code

1. **Fetching Podcast Data**:
   - Use `get_podcast_data.R` to fetch podcast data from the API. 
   Configure API keys and parameters as needed in the script.
   - Output data will be saved in the `data/` directory.

2. **Description Analysis**:
   - Open `description_analysis.ipynb` to perform text-based analyses on podcast descriptions. 
   This notebook demonstrates techniques like word frequency analysis and sentiment analysis.

3. **Running the Shiny App**:
   - Navigate to the `app/` directory.
   - Launch the Shiny app by running `app.R` in RStudio or via the R command line.
   The app provides an interactive interface for visualizing podcast trends and insights.
   - Our app is hosted here, just try it!
   <https://hyang644.shinyapps.io/spotify_app/>

4. **Modifications**:
   - Scripts in `code/` are modular and can be customized for additional analyses or API integrations.

### Additional Notes

- **System Requirements**:
  - R (version 4.0 or above) with the following libraries: `shiny`, `ggplot2`,`dplyr` and `spotifyr`.
  - Python (version 3.8 or above) with packages: `numpy`, `pandas`, `matplotlib`, `nltk`, and `sklearn`.

- **Data Sources**:
  - Podcast data is retrieved from the specified API endpoints within the `get_podcast_data.R` script.

- **Customization**:
  - The scripts and notebooks are modular and can be adapted for specific podcast platforms or additional features
  like keyword search and user-defined filtering.

### Contributor

Hengyu Yang
