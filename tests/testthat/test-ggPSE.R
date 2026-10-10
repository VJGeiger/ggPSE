# tests/testthat/test-ggPSE.R

# ── ggPSE core ────────────────────────────────────────────────────────────────

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

test_that("ggPSE show_atomic_number works", {
  expect_no_error(ggPSE(show_atomic_number = TRUE))
})

# ── groups / periods / lanthanides / actinides ────────────────────────────────

test_that("ggPSE groups filter reduces tile count", {
  p_full   <- ggPSE()
  p_subset <- ggPSE(groups = c(3, 12))
  expect_lt(nrow(p_subset$data), nrow(p_full$data))
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

# ── ggPSE_bubble ─────────────────────────────────────────────────────────────

test_that("ggPSE_bubble returns a ggplot", {
  df <- data.frame(symbol = c("Li", "Co", "Ni"), risk = c(0.6, 0.9, 0.7))
  expect_s3_class(ggPSE_bubble(df, size_col = "risk"), "ggplot")
})

test_that("ggPSE_bubble blank call works", {
  expect_no_error(ggPSE_bubble())
})

# ── ggPSE_bar ─────────────────────────────────────────────────────────────────

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

# ── ggPSE_badge ───────────────────────────────────────────────────────────────

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

test_that("ggPSE_badge hierarchy parameter works", {
  df <- data.frame(
    symbol  = c("Li","Li","Co","Co"),
    country = c("CL","AU","CD","AU")
  )
  expect_no_error(
    ggPSE() |> ggPSE_badge(df, country_col = "country", hierarchy = TRUE)
  )
})

# ── ggPSE_donut ───────────────────────────────────────────────────────────────

test_that("ggPSE_donut returns a ggplot when ggforce available", {
  skip_if_not_installed("ggforce")
  supply <- data.frame(
    symbol   = c("Li","Li","Co","Co"),
    category = c("CL","AU","CD","AU"),
    share    = c(0.6, 0.4, 0.7, 0.3)
  )
  expect_s3_class(
    ggPSE() |> ggPSE_donut(supply, category_col = "category",
                            share_col = "share"),
    "ggplot"
  )
})

test_that("ggPSE_donut errors on missing column", {
  skip_if_not_installed("ggforce")
  supply <- data.frame(symbol = "Li", cat = "CL", share = 1)
  expect_error(
    ggPSE() |> ggPSE_donut(supply, category_col = "category",
                            share_col = "share"),
    "category"
  )
})

test_that("ggPSE_donut respects plot subset", {
  skip_if_not_installed("ggforce")
  supply <- data.frame(
    symbol   = c("Li","Co"),
    category = c("CL","CD"),
    share    = c(1, 1)
  )
  expect_no_error(
    ggPSE(groups = c(1, 2)) |>
      ggPSE_donut(supply, category_col = "category", share_col = "share")
  )
})

# ── ggPSE_profile ─────────────────────────────────────────────────────────────

test_that("ggPSE_profile works for a period", {
  skip_if_not_installed("patchwork")
  data(ggpse_elements)
  expect_no_error(
    ggPSE_profile(ggpse_elements, value_col = "electronegativity", period = 2)
  )
})

test_that("ggPSE_profile works for a group", {
  skip_if_not_installed("patchwork")
  data(ggpse_elements)
  expect_no_error(
    ggPSE_profile(ggpse_elements, value_col = "electronegativity", group = 1)
  )
})

test_that("ggPSE_profile works for lanthanides", {
  skip_if_not_installed("patchwork")
  data(ggpse_elements)
  expect_no_error(
    ggPSE_profile(ggpse_elements, value_col = "electronegativity",
                  lanthanides = TRUE)
  )
})

test_that("ggPSE_profile errors when both period and group supplied", {
  skip_if_not_installed("patchwork")
  data(ggpse_elements)
  expect_error(
    ggPSE_profile(ggpse_elements, value_col = "electronegativity",
                  period = 2, group = 1)
  )
})

test_that("ggPSE_profile errors when nothing supplied", {
  skip_if_not_installed("patchwork")
  data(ggpse_elements)
  expect_error(
    ggPSE_profile(ggpse_elements, value_col = "electronegativity")
  )
})

# ── ggPSE_theme ───────────────────────────────────────────────────────────────

test_that("ggPSE_theme minimal returns ggplot", {
  expect_s3_class(ggPSE() |> ggPSE_theme("minimal"), "ggplot")
})

test_that("ggPSE_theme publication returns ggplot", {
  expect_s3_class(ggPSE() |> ggPSE_theme("publication"), "ggplot")
})

test_that("ggPSE_theme dark returns ggplot", {
  expect_s3_class(ggPSE() |> ggPSE_theme("dark"), "ggplot")
})

test_that("ggPSE_theme crazy returns ggplot", {
  expect_s3_class(ggPSE() |> ggPSE_theme("crazy"), "ggplot")
})

test_that("ggPSE_theme crazy is reproducible with seed", {
  p1 <- ggPSE() |> ggPSE_theme("crazy", seed = 42)
  p2 <- ggPSE() |> ggPSE_theme("crazy", seed = 42)
  expect_equal(
    p1$layers[[1]]$data$crazy_fill,
    p2$layers[[1]]$data$crazy_fill
  )
})

# ── ggPSE_save ────────────────────────────────────────────────────────────────

test_that("ggPSE_save writes a file and returns path invisibly", {
  p    <- ggPSE()
  tmp  <- tempfile(fileext = ".png")
  path <- ggPSE_save(p, tmp)
  expect_true(file.exists(tmp))
  expect_equal(path, tmp)
  unlink(tmp)
})

# ── element grid integrity ────────────────────────────────────────────────────

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

test_that("ggpse_elements dataset loads and has expected columns", {
  data(ggpse_elements)
  expect_true("electronegativity" %in% names(ggpse_elements))
  expect_true("melting_point_K"   %in% names(ggpse_elements))
  expect_equal(nrow(ggpse_elements), 118)
})


# ── symbol_position / number_position ─────────────────────────────────────────

# helper: built data of text layers (symbol = first GeomText layer)
text_layers <- function(p) {
  b   <- ggplot2::ggplot_build(p)
  idx <- which(vapply(p$layers, function(l) inherits(l$geom, "GeomText"), logical(1)))
  b$data[idx]
}

test_that("symbol_position = 'center' keeps the default layout", {
  d  <- data.frame(symbol = "Fe", v = 1)
  sy <- text_layers(ggPSE(d, "v"))[[1]]
  fe <- .ggpse_elements()[.ggpse_elements()$symbol == "Fe", ]
  expect_equal(sy$x[sy$label == "Fe"], fe$col)
  expect_equal(sy$y[sy$label == "Fe"], -fe$row - 0.08)
  expect_equal(unique(sy$vjust), 0.15)
})

test_that("symbol_position accepts all positions and rejects others", {
  d <- data.frame(symbol = c("Fe", "Au"), v = c(1, 2))
  for (pos in c("center", "top", "bottom", "left", "right"))
    expect_no_error(ggplot2::ggplot_build(ggPSE(d, "v", symbol_position = pos)))
  expect_error(ggPSE(d, "v", symbol_position = "middle"))
})

test_that("symbol and value are placed on opposite sides for top / bottom", {
  d <- data.frame(symbol = "Fe", v = 1)
  for (pos in c("top", "bottom")) {
    ly  <- text_layers(ggPSE(d, "v", symbol_position = pos))
    sym <- ly[[1]]$y[ly[[1]]$label == "Fe"]
    val <- ly[[2]]$y[ly[[2]]$label != ""]
    expect_true(if (pos == "top") sym > val else sym < val)
  }
})

test_that("left / right align the symbol to the tile edge", {
  d  <- data.frame(symbol = "Fe", v = 1)
  l  <- text_layers(ggPSE(d, "v", symbol_position = "left"))[[1]]
  r  <- text_layers(ggPSE(d, "v", symbol_position = "right"))[[1]]
  fe <- .ggpse_elements()[.ggpse_elements()$symbol == "Fe", ]
  expect_true(l$x[l$label == "Fe"] < fe$col && unique(l$hjust) == 0)
  expect_true(r$x[r$label == "Fe"] > fe$col && unique(r$hjust) == 1)
})

test_that("number_position anchors the atomic number at the tile border", {
  fe <- .ggpse_elements()[.ggpse_elements()$symbol == "Fe", ]
  num <- function(pos) {
    ly <- text_layers(ggPSE(symbol_position = "center", show_atomic_number = TRUE,
                            number_position = pos))
    ly[[2]][ly[[2]]$label == fe$atomic_number, ]
  }
  tl <- num("top-left");     br <- num("bottom-right"); tm <- num("top")
  expect_equal(c(tl$x - fe$col, tl$y + fe$row), c(-0.42, 0.38))
  expect_equal(c(tl$hjust, tl$vjust), c(0, 1))
  expect_equal(c(br$x - fe$col, br$y + fe$row), c(0.42, -0.38))
  expect_equal(c(br$hjust, br$vjust), c(1, 0))
  expect_equal(c(tm$x - fe$col, tm$hjust), c(0, 0.5))
  expect_error(ggPSE(show_atomic_number = TRUE, number_position = "middle"))
})

test_that("overlapping number_position warns, defaults do not", {
  d <- data.frame(symbol = "Fe", v = 1)
  expect_no_warning(ggPSE(d, "v", show_atomic_number = TRUE))
  expect_warning(ggPSE(d, "v", symbol_position = "top", show_atomic_number = TRUE,
                       number_position = "top-left"), "overlaps")
  expect_no_warning(ggPSE(d, "v", symbol_position = "top", show_atomic_number = TRUE,
                          number_position = "left"))
  # without atomic numbers there is nothing to collide with
  expect_no_warning(ggPSE(d, "v", symbol_position = "top"))
})


# ── symbol_size ───────────────────────────────────────────────────────────────

test_that("symbol_size defaults to base_size * 0.4 and can be overridden", {
  d <- data.frame(symbol = "Fe", v = 1)
  expect_equal(unique(text_layers(ggPSE(d, "v", base_size = 14))[[1]]$size), 14 * 0.4)
  expect_equal(unique(text_layers(ggPSE(d, "v", base_size = 14, symbol_size = 3.8))[[1]]$size), 3.8)
})

test_that("symbol_size only changes the symbol layer", {
  d  <- data.frame(symbol = "Fe", v = 1)
  a  <- text_layers(ggPSE(d, "v", show_atomic_number = TRUE))
  b  <- text_layers(ggPSE(d, "v", show_atomic_number = TRUE, symbol_size = 2))
  expect_equal(unique(a[[2]]$size), unique(b[[2]]$size))   # atomic number
  expect_equal(unique(a[[3]]$size), unique(b[[3]]$size))   # value
})

test_that("symbol_size is validated", {
  expect_error(ggPSE(symbol_size = -1), "symbol_size")
  expect_error(ggPSE(symbol_size = "big"), "symbol_size")
  expect_error(ggPSE(symbol_size = c(2, 3)), "symbol_size")
  expect_error(ggPSE(symbol_size = NA_real_), "symbol_size")
  expect_no_error(ggPSE(symbol_size = NULL))
})
