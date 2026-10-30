# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("dplyr", "janitor", "ggplot2", "tidyr", "here") )

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Replace the target list below with your own:
list(
  # import data file
  tar_target(
    name = veg_file,
    command = here("data/species_data_v1.csv"),
    format = "file"
  ),
  
  # read data
  tar_target(
    name = veg_raw,
    command = read(veg_file)
  ),

  # clean data
  tar_target(
    name = veg_clean,
    command = clean(veg_raw)
  ),
  
  # calculate richness
  tar_target(
    name = veg_richness,
    command = calc_rich(veg_clean)
  ),
  
  # add management
  tar_target(
    name = veg_managed,
    command = management(veg_richness, grazed = c("HB", "KB", "TF", "ZB"))
  ),
  
  # plot richness
  tar_target(
    name = veg_fig,
    command = plot_rich(veg_managed)
  ),
  
  # plot management effect
  tar_target(
    name = veg_management_effect_plot,
    command = plot_management_richness(veg_managed)
  ),
  
  # render ms
  tar_quarto(
    name = manuscript, 
    path = "astonishing_vegetation.qmd")
)

