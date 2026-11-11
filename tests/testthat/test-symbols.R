# tests/testthat/test-symbols.R

# ── helpers ───────────────────────────────────────────────────────────────────

sym_data <- function() data.frame(
  symbol   = c("Cr", "V", "Ca", "Hg", "Zn", "Ca"),
  category = c("alumino", "alumino", "alumino", "distill", "distill", "distill"),
  stringsAsFactors = FALSE
)

# layers that ggPSE_symbols() added to a plot
added_layers <- function(p, base) p$layers[seq_len(length(p$layers) - length(base$layers)) + length(base$layers)]
point_layers <- function(p, base) Filter(function(l) inherits(l$geom, "GeomPoint"), added_layers(p, base))
n_added <- function(p, base) length(p$layers) - length(base$layers)

# ── Basic behaviour ───────────────────────────────────────────────────────────

test_that("ggPSE_symbols returns a ggplot object", {
  expect_s3_class(ggPSE_symbols(ggPSE(), sym_data()), "ggplot")
})

test_that("ggPSE_symbols uses a blank table when plot is NULL", {
  expect_s3_class(ggPSE_symbols(NULL, sym_data()), "ggplot")
})

test_that("filled shapes 21-25 need no halo layer, other shapes get one", {
  base <- ggPSE()
  p_filled <- ggPSE_symbols(base, sym_data(), pch = c(24, 21))          # 2 marker layers + 1 legend layer
  expect_equal(n_added(p_filled, base), 3L)
  p_solid <- ggPSE_symbols(base, sym_data(), pch = c(16, 4))            # + 2 halo layers
  expect_equal(n_added(p_solid, base), 5L)
  p_nohalo <- ggPSE_symbols(base, sym_data(), pch = c(16, 4), halo = FALSE)
  expect_equal(n_added(p_nohalo, base), 3L)
  p_nolegend <- ggPSE_symbols(base, sym_data(), pch = c(16, 4), legend = FALSE)
  expect_equal(n_added(p_nolegend, base), 4L)
})

test_that("the legend is a shape scale and can be switched off", {
  base <- ggPSE()
  expect_true(ggPSE_symbols(base, sym_data())$scales$has_scale("shape"))
  expect_false(ggPSE_symbols(base, sym_data(), legend = FALSE)$scales$has_scale("shape"))
})

test_that("an element in two categories gets two markers side by side", {
  base <- ggPSE()
  p <- ggPSE_symbols(base, sym_data(), legend = FALSE)
  d <- do.call(rbind, lapply(point_layers(p, base), function(l) l$data))
  ca <- d[d$symbol == "Ca", ]
  expect_equal(nrow(ca), 2L)
  expect_gt(abs(ca$x[1] - ca$x[2]), 0.1)
  k <- ggPSE:::.shape_coef(ca$pch, TRUE)
  w <- k$aw * 1.6 + k$bw; down <- k$ad * 1.6 + k$bd
  expect_equal(ca$dy - down, rep(-0.46 + 0.02, 2), tolerance = 1e-12)       # the same bottom line
  expect_equal(min(ca$dx - w / 2), -max(ca$dx + w / 2), tolerance = 1e-12)  # centred as a group
  expect_equal(nrow(d[d$symbol == "Cr", ]), 1L)
})

test_that("repeated rows and missing categories are ignored", {
  base <- ggPSE()
  d <- rbind(sym_data(), sym_data(), data.frame(symbol = "Fe", category = NA))
  p <- ggPSE_symbols(base, d, legend = FALSE)
  all <- do.call(rbind, lapply(point_layers(p, base), function(l) l$data))
  expect_equal(nrow(all), nrow(unique(sym_data())))
  expect_false("Fe" %in% all$symbol)
})

test_that("the markers sit below the tile centre and position_nudge shifts them", {
  base <- ggPSE()
  y_of <- function(...) {
    p <- ggPSE_symbols(base, data.frame(symbol = "Fe", category = "a"), legend = FALSE, ...)
    l <- point_layers(p, base)[[1]]$data
    l$y - (-l$row)
  }
  expect_lt(y_of(), -0.25)
  expect_equal(y_of(position_nudge = 0.1) - y_of(), 0.1)
})

test_that("named colours and shapes are matched by category, unnamed by position", {
  base <- ggPSE()
  p <- ggPSE_symbols(base, sym_data(), legend = FALSE,
                     pch = c(distill = 22, alumino = 24),
                     colors = c(distill = "#112233", alumino = "#AABBCC"))
  lays <- point_layers(p, base)                                          # alumino first (sorted), no halo layers
  expect_equal(lays[[1]]$aes_params$shape, 24L)
  expect_equal(lays[[1]]$aes_params$fill, "#AABBCC")
  expect_equal(lays[[2]]$aes_params$shape, 22L)
  p2 <- ggPSE_symbols(base, sym_data(), legend = FALSE, colors = c("#112233", "#AABBCC"))
  expect_equal(point_layers(p2, base)[[1]]$aes_params$fill, "#112233")
})

test_that("factor levels fix the order of the categories", {
  base <- ggPSE()
  d <- sym_data(); d$category <- factor(d$category, levels = c("distill", "alumino"))
  p <- ggPSE_symbols(base, d, legend = FALSE, colors = c("#112233", "#AABBCC"))
  expect_equal(point_layers(p, base)[[1]]$aes_params$fill, "#112233")
  expect_setequal(point_layers(p, base)[[1]]$data$symbol, c("Hg", "Zn", "Ca"))      # distill comes first
})

# ── Layout ────────────────────────────────────────────────────────────────────

test_that("the markers are placed by their measured shape sizes", {
  tab <- ggPSE:::.symbol_shapes
  expect_equal(tab$pch, 0:25)
  expect_true(all(tab$aw_h > 0 & tab$aw_p > 0))                              # every shape grows with size
  expect_true(all(tab$bw_h > 0 & tab$bw_p > 0))
  for (halo in c(TRUE, FALSE)) for (pch in list(c(21L, 24L, 22L, 23L), c(22L, 8L), 21L, c(25L, 24L, 4L))) {
    lay <- ggPSE:::.symbol_layout(pch, 1.6, halo)
    k   <- ggPSE:::.shape_coef(pch, halo)
    w   <- k$aw * 1.6 + k$bw;  down <- k$ad * 1.6 + k$bd
    n   <- length(pch)
    expect_equal(lay$dy - down, rep(-0.46 + 0.02, n), tolerance = 1e-12)       # the same bottom line, at the very bottom
    expect_equal(min(lay$dx - w / 2), -max(lay$dx + w / 2), tolerance = 1e-12) # centred by the outer edges
    if (n > 1) expect_equal((lay$dx[-1] - w[-1] / 2) - (lay$dx[-n] + w[-n] / 2),
                            rep(0.02, n - 1), tolerance = 1e-12)               # equal gaps
  }
})

test_that("the default size fits four of the default shapes into one row", {
  expect_lte(ggPSE:::.symbol_fit_size(list(c(21L, 24L, 22L, 23L)), TRUE), 1e3)
  expect_gte(ggPSE:::.symbol_fit_size(list(c(21L, 24L, 22L, 23L)), TRUE), 1.6)
  expect_gte(ggPSE:::.symbol_fit_size(list(c(21L, 24L, 22L, 23L)), FALSE), 1.6)
  expect_gt(ggPSE:::.symbol_fit_size(list(c(21L, 21L)), TRUE), ggPSE:::.symbol_fit_size(list(rep(21L, 4)), TRUE))
})

test_that("an element can have at most four markers", {
  base <- ggPSE()
  four <- data.frame(symbol = "Fe", category = LETTERS[1:4])
  expect_s3_class(ggPSE_symbols(base, four), "ggplot")
  five <- data.frame(symbol = "Fe", category = LETTERS[1:5])
  expect_error(ggPSE_symbols(base, five), "at most 4 markers per element")
  expect_error(ggPSE_symbols(base, five), "Fe \\(5\\)")
  six <- rbind(five, data.frame(symbol = "Cu", category = LETTERS[1:6]))
  expect_error(ggPSE_symbols(base, six), "Cu.*Fe")                         # both elements are named
})

test_that("size is reduced with a message when the markers would not fit in a row", {
  base <- ggPSE()
  four <- data.frame(symbol = "Fe", category = LETTERS[1:4])                 # default shapes 21, 24, 22, 23
  expect_no_message(ggPSE_symbols(base, four))                              # the default size fits
  expect_message(p <- ggPSE_symbols(base, four, size = 2.4, legend = FALSE), "reduced from 2.4 to")
  fit <- floor(ggPSE:::.symbol_fit_size(list(c(21L, 24L, 22L, 23L)), TRUE) * 100) / 100
  expect_equal(point_layers(p, base)[[1]]$aes_params$size, fit)
  two <- data.frame(symbol = "Fe", category = LETTERS[1:2])
  expect_no_message(p2 <- ggPSE_symbols(base, two, size = 3, legend = FALSE))   # two markers allow a larger size
  expect_equal(point_layers(p2, base)[[1]]$aes_params$size, 3)
})

test_that("four markers with a value label give no warning and share one bottom line", {
  valued <- ggPSE(data.frame(symbol = "Fe", value = 1), value_col = "value", periods = c(4, 4),
                  lanthanides = FALSE, actinides = FALSE)
  four <- data.frame(symbol = "Fe", category = LETTERS[1:4])
  expect_no_warning(p <- ggPSE_symbols(valued, four, legend = FALSE))
  d <- do.call(rbind, lapply(Filter(function(l) inherits(l$geom, "GeomPoint"), p$layers[-seq_along(valued$layers)]),
                             function(l) l$data))
  expect_equal(nrow(d), 4L)
  k <- ggPSE:::.shape_coef(d$pch, TRUE)
  expect_equal(d$dy - (k$ad * 1.6 + k$bd), rep(-0.44, 4), tolerance = 1e-12)
})

# ── Interplay with other layers ───────────────────────────────────────────────

test_that("markers on a gradient plot keep the fill scale intact", {
  d <- data.frame(symbol = c("Fe", "Cu", "Cr", "Ca"), value = c(1, 2, 3, 4))
  base <- ggPSE(d, value_col = "value")
  p <- ggPSE_symbols(base, sym_data())
  expect_no_error(suppressMessages(ggplot2::ggplot_build(p)))
  expect_equal(class(p$scales$get_scales("fill"))[1], class(base$scales$get_scales("fill"))[1])
})

test_that("elements outside a periods subset are ignored", {
  base <- ggPSE(periods = c(1, 2), lanthanides = FALSE, actinides = FALSE)
  expect_warning(ggPSE_symbols(base, data.frame(symbol = "Fe", category = "a")), "nothing added")
  expect_equal(length(suppressWarnings(ggPSE_symbols(base, data.frame(symbol = "Fe", category = "a")))$layers),
               length(base$layers))
})

# ── Input validation ──────────────────────────────────────────────────────────

test_that("ggPSE_symbols validates its input", {
  expect_error(ggPSE_symbols(ggPSE(), "x"), "data frame")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), category_col = "nope"), "not found")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), symbol_col = "nope"), "not found")
  expect_error(ggPSE_symbols("no plot", sym_data()), "ggplot object")
  expect_error(ggPSE_symbols(ggPSE(), data.frame(symbol = "Xx", category = "a")), "Not recognised")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), size = -1), "'size'")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), halo = "white"), "'halo' must be TRUE or FALSE")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), halo = NA), "'halo' must be TRUE or FALSE")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), legend = NA), "'legend'")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), legend_title = 1), "'legend_title'")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), move_text = NA), "move_text")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), position_nudge = "a"), "position_nudge")
})

test_that("there is no limit to the number of categories, the defaults continue", {
  els <- c("H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg")
  base <- ggPSE()
  d <- data.frame(symbol = els[1:8], category = letters[1:8])               # one category per element
  p <- ggPSE_symbols(base, d)
  expect_s3_class(p, "ggplot")
  expect_length(levels(p$layers[[length(p$layers)]]$data$category), 8L)      # all eight are in the legend
  expect_no_error(suppressMessages(ggplot2::ggplot_build(p)))
  cats <- letters[1:12]
  shapes <- unlist(ggPSE:::.resolve_symbol_pch(NULL, cats))
  expect_equal(unname(shapes[1:8]), c(21L, 24L, 22L, 23L, 25L, 8L, 21L, 24L)) # shapes repeat after six ...
  cols <- unlist(ggPSE:::.resolve_symbol_colors(NULL, cats))
  expect_equal(length(unique(cols)), 12L)                                   # ... but every category has its own colour
  p2 <- ggPSE_symbols(base, data.frame(symbol = els, category = cats), pch = rep(21, 12),
                      colors = grDevices::hcl.colors(12, "Dark 3"))         # own shapes and colours for all
  expect_s3_class(p2, "ggplot")
})

test_that("pch and colors are checked", {
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), pch = c(30, 1)), "between 0 and 25")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), pch = c(1.5, 2)), "whole numbers")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), pch = 21), "1 shapes but there are 2")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), pch = c(alumino = 21)), "no shape for: distill")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), colors = "red"), "1 colours but there are 2")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), colors = c("red", "notacolour")), "Invalid colour")
  expect_error(ggPSE_symbols(ggPSE(), sym_data(), colors = c(alumino = "red")), "no colour for: distill")
})
