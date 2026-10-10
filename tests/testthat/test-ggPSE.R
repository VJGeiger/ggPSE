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


# ── label_na / text_color ─────────────────────────────────────────────────────

n_text_rows <- function(p) vapply(text_layers(p), nrow, integer(1))

test_that("label_na = FALSE hides text on tiles without data", {
  d <- data.frame(symbol = c("Fe", "Au", "Cu"), v = c(1, 2, NA))
  expect_equal(unname(n_text_rows(ggPSE(d, "v"))), c(118L, 118L))             # default
  expect_equal(unname(n_text_rows(ggPSE(d, "v", label_na = FALSE))), c(2L, 2L))
  expect_equal(unname(n_text_rows(ggPSE(d, "v", label_na = FALSE,
                                        show_atomic_number = TRUE))), c(2L, 2L, 2L))
})

test_that("label_na = FALSE follows highlight groups and ignores blank plots", {
  h <- list(list(symbols = c("Fe", "Co"), color = "#ff0000", label = "x"))
  expect_equal(unname(n_text_rows(ggPSE(highlight = h, label_na = FALSE))), 2L)
  expect_equal(unname(n_text_rows(ggPSE(label_na = FALSE))), 118L)
})

test_that("text_color overrides the contrast colour and is validated", {
  d <- data.frame(symbol = c("Fe", "Au"), v = c(1, 2))
  b <- ggplot2::ggplot_build(ggPSE(d, "v", text_color = "grey15"))
  cols <- unique(unlist(lapply(b$data[-1], function(x) x$colour)))
  expect_equal(cols, "grey15")
  expect_error(ggPSE(text_color = "notacolour"), "text_color")
  expect_error(ggPSE(text_color = c("red", "blue")), "text_color")
})

# ── ggPSE_text ────────────────────────────────────────────────────────────────

last_text <- function(p) { b <- text_layers(p); b[[length(b)]] }

test_that("ggPSE_text anchors text at top / center / bottom of the tile", {
  d    <- data.frame(symbol = "Fe", lab = "a")
  base <- ggPSE(d, label_value = FALSE)
  fe   <- .ggpse_elements()[.ggpse_elements()$symbol == "Fe", ]
  y    <- function(pos, ...) {
    l <- last_text(ggPSE_text(base, d, "lab", position = pos, ...))
    l$y[l$label == "a"] + fe$row
  }
  expect_equal(c(y("top"), y("center"), y("bottom")), c(0.40, 0, -0.40))
  expect_equal(y("center", position_nudge = 0.1), 0.1)
  expect_equal(y("top", position_nudge = -0.05), 0.35)
  vj <- function(pos) unique(last_text(ggPSE_text(base, d, "lab", position = pos))$vjust)
  expect_equal(c(vj("top"), vj("center"), vj("bottom")), c(1, 0.5, 0))
})

test_that("ggPSE_text skips NA / empty text and unmatched elements", {
  d <- data.frame(symbol = c("Fe", "Au", "Cu", "Xx"), lab = c("a", NA, "", "z"))
  p <- ggPSE_text(ggPSE(label_value = FALSE), d, "lab")
  expect_equal(nrow(last_text(p)), 1L)
})

test_that("ggPSE_text only draws on tiles that are in the plot", {
  d <- data.frame(symbol = c("Fe", "Au"), lab = c("a", "b"))
  z <- ggPSE(periods = c(6, 6), lanthanides = FALSE, actinides = FALSE)
  expect_equal(last_text(ggPSE_text(z, d, "lab"))$label, "b")
})

test_that("ggPSE_text supports a colour column and multi-line text", {
  d <- data.frame(symbol = c("Fe", "Au"), lab = c("a\nb", "c"),
                  clr = c("#ff0000", "#0000ff"), stringsAsFactors = FALSE)
  l <- last_text(ggPSE_text(ggPSE(), d, "lab", color = "clr"))
  expect_setequal(l$colour, c("#ff0000", "#0000ff"))
  expect_true("a\nb" %in% l$label)
})

test_that("ggPSE_text validates input and survives ggPSE_donut ordering", {
  d <- data.frame(symbol = "Fe", lab = "a")
  base <- ggPSE()
  expect_error(ggPSE_text(base, d, "missing"), "not found")
  expect_error(ggPSE_text(base, d, "lab", position = "left"))
  expect_error(ggPSE_text(ggplot2::ggplot(), d, "lab"), "ggPSE")
  expect_error(ggPSE_text(base, d, "lab", size = -1), "size")
  expect_warning(ggPSE_text(base, data.frame(symbol = "Xx", lab = "a"), "lab"),
                 "nothing added")
  skip_if_not_installed("ggforce")
  dd <- data.frame(symbol = rep("Fe", 2), category = c("a", "b"), share = c(0.5, 0.5))
  p <- suppressWarnings(ggPSE_donut(ggPSE(), dd))
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(ggPSE_text(p, d, "lab"))))
})


# ── symbol_nudge / number_nudge / position_nudge validation ──────────────────

test_that("symbol_nudge and number_nudge shift only their own layer", {
  d   <- data.frame(symbol = "Fe", v = 1)
  fe  <- .ggpse_elements()[.ggpse_elements()$symbol == "Fe", ]
  get <- function(...) text_layers(ggPSE(d, "v", show_atomic_number = TRUE, ...))
  a <- get(); b <- get(symbol_nudge = 0.1, number_nudge = -0.05)
  sy <- function(ly) { l <- ly[[1]]; l$y[l$label == "Fe"] }
  nu <- function(ly) { l <- ly[[2]]; l$y[l$label == fe$atomic_number] }
  va <- function(ly) { l <- ly[[3]]; l$y[l$label != ""][1] }
  expect_equal(sy(b) - sy(a), 0.1)
  expect_equal(nu(b) - nu(a), -0.05)
  expect_equal(va(b), va(a))                     # value label is not nudged
})

test_that("nudge arguments are validated", {
  expect_error(ggPSE(symbol_nudge = "a"), "symbol_nudge")
  expect_error(ggPSE(number_nudge = c(0, 1)), "number_nudge")
  expect_error(ggPSE(symbol_nudge = NA_real_), "symbol_nudge")
  expect_error(ggPSE_text(ggPSE(), data.frame(symbol = "Fe", l = "a"), "l",
                          position_nudge = "x"), "position_nudge")
})


# ── categorical highlight (named list + highlight_colors) ─────────────────────

hl_fills <- function(p) {
  setNames(ggplot2::ggplot_build(p)$data[[1]]$fill, p$data$symbol)
}
grp <- list(Alkali = c("Li", "Na", "K"), Halogens = c("F", "Cl", "Br"), Noble = c("He", "Ne"))

test_that("named list highlight colours tiles by group, in list order", {
  p <- ggPSE(highlight = grp, highlight_colors = c(Noble = "gold", Alkali = "red", Halogens = "navy"))
  f <- hl_fills(p)
  expect_equal(unname(f[c("Li", "F", "He")]), c("red", "navy", "gold"))
  expect_equal(p$scales$get_scales("fill")$breaks, names(grp))
})

test_that("unnamed highlight_colors are matched by position, default palette works", {
  f <- hl_fills(ggPSE(highlight = grp, highlight_colors = c("#111111", "#222222", "#333333")))
  expect_equal(unname(f[c("Li", "F", "He")]), c("#111111", "#222222", "#333333"))
  f2 <- hl_fills(ggPSE(highlight = grp))
  expect_equal(length(unique(f2[c("Li", "F", "He")])), 3L)
  many <- setNames(as.list(c("H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne")), paste0("g", 1:10))
  expect_equal(length(unique(hl_fills(ggPSE(highlight = many))[unlist(many)])), 10L)
})

test_that("split() on a factor sets the legend order", {
  d <- data.frame(symbol = c("Li", "F", "He", "Na"),
                  cat = factor(c("A", "B", "C", "A"), levels = c("C", "A", "B")))
  p <- ggPSE(highlight = split(d$symbol, d$cat))
  expect_equal(p$scales$get_scales("fill")$breaks, c("C", "A", "B"))
})

test_that("highlight accepts any R colour name and the legacy list form unchanged", {
  expect_equal(unname(hl_fills(ggPSE(highlight = list(list(symbols = "Fe", color = "red", label = "x"))))["Fe"]), "red")
  p <- ggPSE(highlight = grp, highlight_colors = c(Alkali = "navy", Halogens = "gold", Noble = "red"))
  tc <- p$data$text_color[match(c("Li", "F"), p$data$symbol)]
  expect_equal(tc, c("white", "grey20"))
})

test_that("legend_title is used for highlight groups", {
  expect_equal(ggPSE(highlight = grp, legend_title = "Group")$scales$get_scales("fill")$name, "Group")
})

test_that("highlight input is validated", {
  expect_error(ggPSE(highlight = list(c("Li", "Na"), "F")), "named")
  expect_error(ggPSE(highlight = setNames(list("Li", "Na"), c("a", "a"))), "unique")
  expect_error(ggPSE(highlight = grp, highlight_colors = c(Alkali = "red")), "Halogens")
  expect_error(ggPSE(highlight = grp, highlight_colors = c("red", "blue")), "3 groups")
  expect_error(ggPSE(highlight = grp, highlight_colors = c(Alkali = "red", Halogens = "nope", Noble = "blue")), "nope")
  expect_error(ggPSE(highlight = list()), "non-empty")
  expect_error(ggPSE(highlight = list(list(symbols = "Li", color = "red"), "Na")), "named list")
})

test_that("typos, overlapping groups and ignored colours warn", {
  expect_warning(ggPSE(highlight = list(A = c("Li", "Xx"))), "Xx")
  expect_warning(ggPSE(highlight = list(A = c("He", "Li"), B = c("He", "Na"))), "more than one")
  expect_warning(ggPSE(highlight = list(list(symbols = "Li", color = "red")), highlight_colors = "blue"),
                 "ignored")
  expect_no_warning(ggPSE(highlight = grp))
})

test_that(".contrast_color is unchanged for hex colours", {
  old <- function(hex) {
    hex <- gsub("#", "", hex)
    r <- strtoi(substr(hex, 1, 2), 16L) / 255; g <- strtoi(substr(hex, 3, 4), 16L) / 255
    b <- strtoi(substr(hex, 5, 6), 16L) / 255
    if (0.2126 * r + 0.7152 * g + 0.0722 * b > 0.4) "grey20" else "white"
  }
  set.seed(1)
  hx <- sprintf("#%02X%02X%02X", sample(0:255, 300, TRUE), sample(0:255, 300, TRUE), sample(0:255, 300, TRUE))
  expect_equal(vapply(hx, .contrast_color, ""), vapply(hx, old, ""))
})
