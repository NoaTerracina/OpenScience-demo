# read the data
read <- function(veg_file){
  read.csv(veg_file, na.strings = c("", "NA", "."))
}

# clean the data
clean <- function(df){
    df |>
    select(-Layer) |> # not relevant information
    mutate(
      Species = make_clean_names(Species),
      across(-Species, as.numeric)
  )
}

# calculate the richness
calc_rich <- function(df){
  df |> 
  summarise(across(-Species, ~ sum(.x > 0, na.rm = TRUE))) |> 
  pivot_longer(everything(),
                 names_to = "plot", values_to = "richness")
}

# add the grazing factor
management <- function(df, grazed){
    df |> 
    mutate(group = if_else(substr(plot, 1, 2) %in% grazed, "Grazed", "Not grazed"))
}

# plot the data
plot_rich <- function(rich_df){
    rich_df |> 
    ggplot(aes(x = plot, y = richness, fill = group)) +
    geom_col(colour = "white") +
    scale_fill_manual(values = c("Grazed" = "darkorange", "Not grazed" = "darkgreen")) +
    labs(x = "Plot", y = "Species richness",  fill = "Management") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}


plot_management_richness <- function(data) {
  
  data <- data |>
    mutate(group = factor(group,
                          levels = c("Not grazed", "Grazed")))
  
  # Fit Poisson GLM
  model <- glm(
    richness ~ group,
    data = data,
    family = poisson(link = "log")
  )
  
  # Extract model results
  results <- summary(model)$coefficients
  
  estimate <- results["groupGrazed", "Estimate"]
  p_value  <- results["groupGrazed", "Pr(>|z|)"]
  
  # Annotation
  annotation <- paste0(
    "GLM estimate = ", round(estimate, 3),
    "\np = ", format.pval(p_value, digits = 3)
  )
  
  # Plot
  ggplot(data, aes(x = group, y = richness, fill = group)) +
    geom_boxplot(alpha = 0.6) +
    geom_jitter(width = 0.1, alpha = 0.6) +
    annotate(
      "text",
      x = 1.5,
      y = Inf,
      label = annotation,
      vjust = 1.5,
      size = 4
    ) +
    labs(
      x = "Management",
      y = "Species richness"
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0.05, 0.2))
    ) +
    theme_bw() +
    theme(legend.position = "none")
}