# data-raw/prepare_element_data.R
#
# Run once to bake the element grid into the package as a proper
# exported dataset via usethis::use_data().
#
# Usage: source("data-raw/prepare_element_data.R")

devtools::load_all()

ggpse_elements <- .ggpse_elements()

# Optionally enrich with periodicdata if installed
if (requireNamespace("periodicdata", quietly = TRUE)) {
  message("periodicdata found — merging additional properties")
  pd            <- periodicdata::elements[, c("symbol", "name", "mass")]
  ggpse_elements <- merge(ggpse_elements, pd, by = "symbol", all.x = TRUE)
}

usethis::use_data(ggpse_elements, overwrite = TRUE)
message("ggpse_elements saved to data/")
