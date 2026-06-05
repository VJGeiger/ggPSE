# tests/testthat/test-ggPSE.R

# --- ggPSE core ---

test_that("ggPSE returns a ggplot object", {
  expect_s3_class(ggPSE(), "ggplot")
})

test_that("ggPSE accepts a data frame with value column", {
  df <- data.frame(symbol = c("Fe", "Cu", "Au"), value = c(0.1, 0.5, 0.9))
  expect_s3_class(ggPSE(df, value_col = "value"), "ggplot")
})

test_that("ggPSE errors on missing symbol column", {
  df <- data.frame(sym = "Fe", value = 0.5)
  expect_error(ggPSE(df, value_col = "value"), "symbol_col")
})

test_that("ggPSE errors on missing value column", {
  df <- data.frame(symbol = "Fe", val = 0.5)
  expect_error(ggPSE(df, value_col = "missing"), "missing")
})

test_that("ggPSE respects custom symbol_col name", {
  df <- data.frame(elem = c("Fe", "Au"), v = c(0.3, 0.8))
  expect_s3_class(ggPSE(df, value_col = "v", symbol_col = "elem"), "ggplot")
})

test_that("ggPSE legend title defaults to value_col", {
  df <- data.frame(symbol = "Fe", oxophilicity = 0.5)
  p  <- ggPSE(df, value_col = "oxophilicity")
  expect_true(any(grepl("oxophilicity", sapply(p$scales$scales, function(s) s$name))))
})

test_that("ggPSE with label_value = FALSE builds without error", {
  df <- data.frame(symbol = c("H", "O"), v = c(0.1, 0.9))
  expect_no_error(ggPSE(df, value_col = "v", label_value = FALSE))
})

test_that("ggPSE blank plot renders without data", {
  expect_no_error(ggPSE())
})

test_that("ggPSE highlight mode returns a ggplot", {
  expect_s3_class(
    ggPSE(highlight = list(
      list(symbols = c("Li", "Co"), color = "#2166ac", label = "Group A"),
      list(symbols = c("Nd", "Dy"), color = "#e63946", label = "Group B")
    )),
    "ggplot"
  )
})

test_that("ggPSE highlight mode works without labels", {
  expect_no_error(ggPSE(highlight = list(
    list(symbols = c("Fe", "Cu"), color = "#2166ac")
  )))
})

# --- groups / periods / lanthanides / actinides ---

test_that("ggPSE groups filter reduces tile count", {
  p_full    <- ggPSE()
  p_subset  <- ggPSE(groups = c(3, 12))
  full_n    <- nrow(p_full$data)
  subset_n  <- nrow(p_subset$data)
  expect_lt(subset_n, full_n)
})

test_that("ggPSE periods filter reduces tile count", {
  p_full   <- ggPSE()
  p_subset <- ggPSE(periods = c(4, 6))
  expect_lt(nrow(p_subset$data), nrow(p_full$data))
})

test_that("ggPSE lanthanides = FALSE removes lanthanide row", {
  p <- ggPSE(lanthanides = FALSE)
  expect_false(any(p$data$row == 9))
})

test_that("ggPSE actinides = FALSE removes actinide row", {
  p <- ggPSE(actinides = FALSE)
  expect_false(any(p$data$row == 10))
})

test_that("ggPSE lanthanides = TRUE keeps lanthanides when periods set", {
  p <- ggPSE(periods = c(4, 6), lanthanides = TRUE)
  expect_true(any(p$data$row == 9))
})

test_that("ggPSE actinides = TRUE keeps actinides when periods set", {
  p <- ggPSE(periods = c(4, 7), actinides = TRUE)
  expect_true(any(p$data$row == 10))
})

test_that("ggPSE groups errors on wrong input", {
  expect_error(ggPSE(groups = c(1, 2, 3)), "groups")
  expect_error(ggPSE(groups = c("a", "b")), "groups")
})

test_that("ggPSE periods errors on wrong input", {
  expect_error(ggPSE(periods = c(1, 2, 3)), "periods")
})

test_that("ggPSE transition metals subset returns ggplot", {
  expect_s3_class(
    ggPSE(groups = c(3, 12), periods = c(4, 6),
          lanthanides = FALSE, actinides = FALSE),
    "ggplot"
  )
})

# --- ggPSE_bubble ---

test_that("ggPSE_bubble returns a ggplot", {
  df <- data.frame(symbol = c("Li", "Co", "Ni"), risk = c(0.6, 0.9, 0.7))
  expect_s3_class(ggPSE_bubble(df, size_col = "risk"), "ggplot")
})

test_that("ggPSE_bubble blank call works", {
  expect_no_error(ggPSE_bubble())
})

# --- ggPSE_bar ---

test_that("ggPSE_bar returns a ggplot", {
  df <- data.frame(symbol = c("Li", "Co", "Ni"), risk = c(0.6, 0.9, 0.7))
  expect_s3_class(ggPSE_bar(df, value_col = "risk"), "ggplot")
})

test_that("ggPSE_bar works with all four sides", {
  df <- data.frame(symbol = c("Fe", "Cu"), v = c(0.3, 0.8))
  for (side in c("bottom", "top", "left", "right")) {
    expect_no_error(ggPSE_bar(df, value_col = "v", bar_side = side))
  }
})

# --- ggPSE_badge ---

test_that("ggPSE_badge returns a ggplot", {
  df <- data.frame(symbol = c("Li", "Co"), country = c("CL", "CD"))
  expect_s3_class(ggPSE() |> ggPSE_badge(df, country_col = "country"), "ggplot")
})

test_that("ggPSE_badge errors on missing country column", {
  df <- data.frame(symbol = "Li", loc = "CL")
  expect_error(
    ggPSE() |> ggPSE_badge(df, country_col = "country"),
    "country"
  )
})

# --- element grid integrity ---

test_that("element grid has 118 rows", {
  expect_equal(nrow(.ggpse_elements()), 118)
})

test_that("element grid has no duplicate symbols", {
  expect_equal(length(unique(.ggpse_elements()$symbol)), 118)
})

test_that("element grid col values are in range 1-18", {
  grid <- .ggpse_elements()
  expect_true(all(grid$col >= 1 & grid$col <= 18))
})

test_that("element grid row values are in range 1-10", {
  grid <- .ggpse_elements()
  expect_true(all(grid$row >= 1 & grid$row <= 10))
})
