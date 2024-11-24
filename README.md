# Interactive ACS Data Visualization Tool

This R script provides a function for creating interactive visualizations of American Community Survey (ACS) 5-Year Estimates data. It combines county-level choropleth maps with Cleveland dot plots for intuitive data exploration.

## Features

- Interactive county-level choropleth maps
- Synchronized Cleveland dot plots showing top 10 counties
- Tooltips with detailed county information
- Automatic formatting of large numbers (e.g., converting 10,000 to 10K)
- Clean ACS variable labels for better readability
- Cached shapefile support for faster rendering

## Prerequisites

This package requires the following R packages:
```R
tidyverse
tidycensus
ggiraph
scales
glue
patchwork
```

You can install all dependencies using:
```R
pacman::p_load(tidyverse, tidycensus, ggiraph, scales, glue, patchwork)
```

## Usage

### Basic Example

```R
# Enable shapefile caching for better performance
options(tigris_use_cache = TRUE)

# Create visualization for total population in Washington state
plot_map_acs("WA", "B01003_001")
```

### Functions

- `fmt_scale()`: Formats numbers using comma notation for values <10,000 and unit scaling (K, M) for larger values
- `fmt_label()`: Cleans ACS variable labels for better readability
- `get_v22()`: Retrieves and formats 2022 ACS 5-Year variables
- `plot_acs()`: Generates an interactive Cleveland dot plot of top 10 counties
- `map_acs()`: Creates an interactive choropleth map
- `plot_map_acs()`: Combines plot and map into a single interactive visualization

### Customization

The visualizations use a blue color scheme by default and include hover effects. The output is a `girafe` object that can be further customized using ggiraph options.

## Output

The tool generates:

1. A Cleveland dot plot highlighting the top 10 counties by value
2. A choropleth map showing the selected ACS variable across all counties in the chosen state
3. Interactive features including tooltips and synchronized highlighting

## Data Source

All data is sourced from the U.S. Census Bureau's 2022 5-Year American Community Survey.

## Author

David Thomassie
