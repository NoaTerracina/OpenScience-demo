library(targets)
tar_make()

tar_load(veg_management_effect)
summary(veg_management_effect)
tar_load(veg_management_effect_plot)
plot(veg_management_effect_plot)
