# Enable shapefile caching
options(tigris_use_cache = TRUE)

# Load packages
pacman::p_load(tidyverse, tidycensus, ggiraph, scales, glue, patchwork)

# Convert numeric input to comma if less than 10,000 and
# unit (k, m, etc.) if greater than/equal to 10,000
fmt_scale <- function(n) {
  cut_scale <- append(cut_short_scale(), 1, 1)
  
  case_when(
    n < 1e4 ~ label_comma(accuracy = 1)(n),
    n >= 1e4 ~ label_number(accuracy = 0.1, scale_cut = cut_scale)(n)
  )
}

# Clean ACS 5-Year variable labels
fmt_label <- function(label_str) {
  substrings <- c(
    "Estimate!!Total:" = "Total",
    "Total!!" = "",
    ":!!" = "; ",
    "Estimate!!" = "",
    " --!!Total" = "",
    " --!!" = "; ",
    "--!!" = "; ",
    "--" = "; ",
    ":" = ""
  )
  
  str_replace_all(label_str, substrings)
}

# Pull available ACS 5-Year variables, clean labels
get_v22 <- function() {
  load_variables(2022, "acs5", cache = TRUE) %>%
    select(variable = name, concept, label) %>%
    mutate(label = fmt_label(label))
}

# Generate title, slice top 10 estimates, build interactive Cleveland dot plot
plot_acs <- function(acs) {
  plot_title <- "{unique(acs$concept)} by county in {unique(acs$state)}"
  
  acs %>%
    slice_max(estimate, n = 10) %>%
    ggplot(aes(estimate, county, fill = estimate)) +
    geom_point_interactive(
      aes(data_id = GEOID, tooltip = tooltip),
      color = "#00336699", size = 3
    ) +
    scale_fill_distiller(
      direction = 1, labels = fmt_scale, guide = "none"
    ) +
    scale_x_continuous(labels = fmt_scale) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(vjust = 5, margin = margin(t = 5)),
      axis.title.x = element_text(vjust = -5),
      axis.text.y = element_text(hjust = 0)
    ) +
    labs(
      title = str_wrap(glue(plot_title), width = 50),
      x = str_wrap(unique(acs$label), width = 50), y = NULL
    )
}

# Build interactive map
map_acs <- function(acs) {
  acs %>%
    ggplot(aes(fill = estimate, tooltip = tooltip)) +
    geom_sf_interactive(aes(data_id = GEOID)) +
    scale_fill_distiller(
      direction = 1, labels = fmt_scale,
      guide = guide_legend(title = "Estimate", reverse = TRUE)
    ) +
    theme_void() +
    labs(caption = "Data source: 2022 5-Year ACS, U.S. Census")
}

# Pull ACS data, join cleaned variable info, apply interactive features
plot_map_acs <- function(acs_state, acs_var) {
  acs <-
    get_acs(
      geography = "county",
      state = acs_state,
      variables = acs_var,
      year = 2022,
      geometry = TRUE
    ) %>%
    inner_join(., get_v22(), by = "variable") %>%
    mutate(
      county = reorder(gsub(" County, .*$", "", NAME), estimate),
      state = gsub("^.* County, ", "", NAME),
      concept = gsub("--", "; ", concept),
      estimate_fmt = fmt_scale(estimate),
      tooltip = glue("{county} County: {estimate_fmt}")
    )
  
  girafe(
    ggobj = plot_acs(acs) + map_acs(acs),
    width_svg = 10, height_svg = 5,
    options = list(
      opts_hover(css = "fill:#efbf04;"),
      opts_sizing(rescale = FALSE)
    )
  )
}
