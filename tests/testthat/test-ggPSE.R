# tests/testthat/test-ggPSE.R

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

# --- ggPSE_bubble ---

test_that("ggPSE_bubble returns a ggplot", {
  df <- data.frame(symbol = c("Li", "Co", "Ni"), risk = c(0.6, 0.9, 0.7))
  expect_s3_class(ggPSE_bubble(df, size_col = "risk"), "ggplot")
})

test_that("ggPSE_bubble blank call works", {
  expect_no_error(ggPSE_bubble())
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
