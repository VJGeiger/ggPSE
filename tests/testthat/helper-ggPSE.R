# tests/testthat/helper-ggPSE.R
#
# Sourced automatically by testthat before any test file runs.
# Loads all package functions without requiring a full install.

pkg_root <- system.file(package = "ggPSE")

if (nzchar(pkg_root)) {
  # Package is properly installed - nothing to do, functions already available
} else {
  # Running tests via source() or during development without install
  # Walk up from tests/testthat/ to find the package root
  r_dir <- tryCatch(
    normalizePath(file.path(dirname(dirname(getwd())), "R")),
    error = function(e) NULL
  )

  # Fallback: try relative path from typical RStudio working directory
  if (is.null(r_dir) || !dir.exists(r_dir)) {
    r_dir <- "R"
  }

  if (dir.exists(r_dir)) {
    # Source zzz.R first (defines %||%), then elements, then the rest
    priority <- c("zzz.R", "ggpse_elements.R") # first helpers, then the built for internal data
    all_files <- list.files(r_dir, pattern = "\\.R$", full.names = TRUE)
    ordered   <- c(
      file.path(r_dir, priority[file.exists(file.path(r_dir, priority))]),
      all_files[!basename(all_files) %in% priority]
    )
    invisible(lapply(ordered, source))
  } else {
    warning("Could not locate R/ directory. Run tests from the package root.")
  }
}
