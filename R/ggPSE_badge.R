#' Overlay country-of-origin badges on a periodic table
#'
#' Adds country flags (via \pkg{ggflags}) or ISO 3166-1 alpha-2 country code
#' text labels to element tiles. When \code{show_legend = TRUE}, a separate
#' legend strip showing each country's flag and full name is appended using
#' \pkg{patchwork}.
#'
#' @param plot A ggplot object. If NULL a blank table is created.
#' @param data A data frame with element symbols and country codes.
#' @param symbol_col Character. Column containing element symbols. Default "symbol".
#' @param country_col Character. Column containing ISO 3166-1 alpha-2 codes.
#'   Default "country".
#' @param badge_size Numeric. Flag or text badge size. Default 3.5 for flags.
#' @param hierarchy Logical. Scale flags by order - first country largest.
#'   Default \code{FALSE}.
#' @param hierarchy_scale Numeric vector of length 3. Scale factors for 1st,
#'   2nd, 3rd flag. Default \code{c(1.0, 0.70, 0.50)}.
#' @param show_legend Logical. Append a country legend. Requires
#'   \pkg{patchwork}. Default \code{FALSE}.
#' @param legend_position Character. \code{"right"} (default), \code{"left"},
#'   \code{"bottom"}, or \code{"top"}.
#' @param legend_size Numeric. Relative size of legend vs main plot.
#'   Default \code{0.15}.
#' @param legend_flag_size Numeric. Flag size in the legend. Default \code{5}.
#' @param legend_text_size Numeric. Text size in the legend. Default \code{9}.
#' @param base_size Numeric. Base font size. Default NULL.
#' @param x_anchor Numeric. Horizontal position of rightmost flag. Default 0.38.
#' @param y_anchor Numeric. Vertical position of flags. Default 0.35.
#' @param flag_spacing Numeric. Spacing between flags. Default 0.38.
#' @param badge_color Character. Text color for fallback badges. Default "#333333".
#'
#' @return A ggplot or patchwork object.
#' @export
#'
#' @examples
#' supply <- data.frame(
#'   symbol  = c("Li", "Co", "Nd", "Pt"),
#'   country = c("CL", "CD", "CN", "ZA"),
#'   value   = c(0.70, 0.91, 0.85, 0.60)
#' )
#' ggPSE(supply, value_col = "value") |>
#'   ggPSE_badge(supply, country_col = "country")
#'
#' \dontrun{
#' ggPSE(supply, value_col = "value") |>
#'   ggPSE_badge(supply, country_col = "country", show_legend = TRUE)
#' }
ggPSE_badge <- function(
    plot             = NULL,
    data,
    symbol_col       = "symbol",
    country_col      = "country",
    badge_size       = NULL,
    hierarchy        = FALSE,
    hierarchy_scale  = c(1.0, 0.70, 0.50),
    show_legend      = FALSE,
    legend_position  = c("right", "left", "bottom", "top"),
    legend_size      = 0.15,
    legend_flag_size = 5,
    legend_text_size = 9,
    base_size        = NULL,
    x_anchor         = 0.38,
    y_anchor         = 0.35,
    flag_spacing     = 0.38,
    badge_color      = "#333333"
) {
  legend_position <- match.arg(legend_position)
  
  # error handling, patchwork can lead to problems
  if (show_legend && !requireNamespace("patchwork", quietly = TRUE))
    stop("Package 'patchwork' is required when show_legend = TRUE. ",
         "Install it with: install.packages(\"patchwork\")", call. = FALSE)

  if (is.null(plot)) plot <- ggPSE()

  if (!country_col %in% names(data))
    stop(sprintf("Column '%s' not found in data.", country_col))
  if (!symbol_col %in% names(data))
    stop(sprintf("Column '%s' not found in data.", symbol_col))
  .check_symbols(data[[symbol_col]], symbol_col)   # several rows per element are fine here
  if (hierarchy && length(hierarchy_scale) != 3)
    stop("'hierarchy_scale' must be a numeric vector of length 3.")

  grid <- .ggpse_elements()
  names(data)[names(data) == symbol_col] <- "symbol"

  na_country <- is.na(data[[country_col]])
  if (any(na_country)) {
    warning(sprintf(paste0(
      "%d row(s) without a country code were ignored. Note that read.csv() reads ",
      "Namibia's code \"NA\" as missing; use na.strings = \"\" when reading."),
      sum(na_country)), call. = FALSE)
    data <- data[!na_country, , drop = FALSE]
  }

  badge_data <- merge(
    grid,
    data[, c("symbol", country_col), drop = FALSE],
    by = "symbol"
  )

  badge_data[[country_col]] <- tolower(badge_data[[country_col]])
  badge_data <- badge_data[order(badge_data$symbol), ]
  badge_data$flag_idx <- as.integer(stats::ave(
    seq_len(nrow(badge_data)), badge_data$symbol, FUN = seq_along
  ))
  too_many <- unique(badge_data$symbol[badge_data$flag_idx > 3L])
  if (length(too_many))
    warning(sprintf(paste0(
      "ggPSE_badge() draws at most 3 flags per element; only the first 3 countries ",
      "(in the order of your data) are shown for: %s."),
      paste(too_many, collapse = ", ")), call. = FALSE)
  badge_data <- badge_data[badge_data$flag_idx <= 3L, , drop = FALSE]

  badge_data$flag_x <- badge_data$col + x_anchor -
    (badge_data$flag_idx - 1) * flag_spacing
  badge_data$flag_y <- -badge_data$row + y_anchor
  
  # ggflags is not on CRAN, but simplest solution to the flags
  base_flag_size <- if (requireNamespace("ggflags", quietly = TRUE))
    badge_size %||% 3.5
  else
    badge_size %||% ((base_size %||% 10) * 0.22)

  badge_data$flag_size <- if (hierarchy)
    hierarchy_scale[badge_data$flag_idx] * base_flag_size
  else
    base_flag_size

  # ── Main plot ─────────────────────────────────────────────────────────────────
  if (requireNamespace("ggflags", quietly = TRUE)) {
    p <- plot +
      ggflags::geom_flag(
        data        = badge_data,
        ggplot2::aes(x = .data[["flag_x"]], y = .data[["flag_y"]],
                     country = .data[[country_col]],
                     size    = .data[["flag_size"]]),
        inherit.aes = FALSE
      ) +
      ggplot2::scale_size_identity()
  } else {
    message("Install ggflags: remotes::install_github('rensa/ggflags')")
    p <- plot +
      ggplot2::geom_text(
        data        = badge_data,
        ggplot2::aes(x = .data[["flag_x"]], y = .data[["flag_y"]],
                     label = toupper(.data[[country_col]]),
                     size  = .data[["flag_size"]]),
        color = badge_color, fontface = "bold", inherit.aes = FALSE
      ) +
      ggplot2::scale_size_identity()
  }

  if (!show_legend) return(p)

  # ── ISO 3166-1 alpha-2 lookup table ──────────────────────────────────────────
  # for enabling a legend hard coded ISO table - special characters were substituted.
  iso_names <- c(
    ae="UAE",           af="Afghanistan",    ag="Antigua & Barbuda",
    al="Albania",       am="Armenia",        ao="Angola",
    ar="Argentina",     at="Austria",        au="Australia",
    az="Azerbaijan",    ba="Bosnia",         bd="Bangladesh",
    be="Belgium",       bf="Burkina Faso",   bg="Bulgaria",
    bi="Burundi",       bj="Benin",          bo="Bolivia",
    br="Brazil",        bw="Botswana",       by="Belarus",
    ca="Canada",        cd="DR Congo",       cf="C. African Rep.",
    cg="Congo",         ch="Switzerland",    ci="Cote d'Ivoire",
    cl="Chile",         cm="Cameroon",       cn="China",
    co="Colombia",      cu="Cuba",           cz="Czech Rep.",
    de="Germany",       dj="Djibouti",       dk="Denmark",
    dz="Algeria",       ec="Ecuador",        eg="Egypt",
    er="Eritrea",       es="Spain",          et="Ethiopia",
    fi="Finland",       fr="France",         ga="Gabon",
    gb="United Kingdom",ge="Georgia",        gh="Ghana",
    gn="Guinea",        gr="Greece",         gt="Guatemala",
    gy="Guyana",        hn="Honduras",       hr="Croatia",
    hu="Hungary",       id="Indonesia",      ie="Ireland",
    il="Israel",        `in`="India",        iq="Iraq",
    ir="Iran",          is="Iceland",        it="Italy",
    jo="Jordan",        jp="Japan",          ke="Kenya",
    kg="Kyrgyzstan",    kh="Cambodia",       kp="North Korea",
    kr="South Korea",   kw="Kuwait",         kz="Kazakhstan",
    la="Laos",          lb="Lebanon",        lr="Liberia",
    ls="Lesotho",       lt="Lithuania",      lu="Luxembourg",
    lv="Latvia",        ly="Libya",          ma="Morocco",
    md="Moldova",       mg="Madagascar",     ml="Mali",
    mm="Myanmar",       mn="Mongolia",       mr="Mauritania",
    mw="Malawi",        mx="Mexico",         my="Malaysia",
    mz="Mozambique",    na="Namibia",        ne="Niger",
    ng="Nigeria",       nl="Netherlands",    no="Norway",
    np="Nepal",         nz="New Zealand",    om="Oman",
    pa="Panama",        pe="Peru",           pg="Papua New Guinea",
    ph="Philippines",   pk="Pakistan",       pl="Poland",
    pt="Portugal",      py="Paraguay",       qa="Qatar",
    ro="Romania",       rs="Serbia",         ru="Russia",
    rw="Rwanda",        sa="Saudi Arabia",   sd="Sudan",
    se="Sweden",        sg="Singapore",      si="Slovenia",
    sk="Slovakia",      sl="Sierra Leone",   sn="Senegal",
    so="Somalia",       sr="Suriname",       ss="South Sudan",
    sy="Syria",         sz="Eswatini",       td="Chad",
    tg="Togo",          th="Thailand",       tj="Tajikistan",
    tm="Turkmenistan",  tn="Tunisia",        tr="Turkey",
    tz="Tanzania",      ua="Ukraine",        ug="Uganda",
    us="United States", uy="Uruguay",        uz="Uzbekistan",
    ve="Venezuela",     vn="Vietnam",        ye="Yemen",
    za="South Africa",  zm="Zambia",         zw="Zimbabwe"
  )

  # Unique countries in data
  unique_countries <- sort(unique(tolower(data[[country_col]])))
  legend_df <- data.frame(
    code = unique_countries,
    name = vapply(unique_countries, function(x) {
      nm <- unname(iso_names[x])
      if (is.na(nm)) toupper(x) else nm        # unknown code: show it as given
    }, character(1)),
    x    = 1,
    y    = rev(seq_along(unique_countries)),
    stringsAsFactors = FALSE
  )

  # ── Legend plot ───────────────────────────────────────────────────────────────
  if (requireNamespace("ggflags", quietly = TRUE)) {
    leg <- ggplot2::ggplot(legend_df,
                           ggplot2::aes(x = .data[["x"]],
                                        y = .data[["y"]])) +
      ggflags::geom_flag(
        ggplot2::aes(country = .data[["code"]]),
        size = legend_flag_size, inherit.aes = TRUE
      ) +
      ggplot2::geom_text(
        ggplot2::aes(x = 1.6, label = .data[["name"]]),
        hjust = 0, size = legend_text_size / ggplot2::.pt,
        color = "grey20"
      )
  } else {
    leg <- ggplot2::ggplot(legend_df,
                           ggplot2::aes(x = .data[["x"]],
                                        y = .data[["y"]])) +
      ggplot2::geom_text(
        ggplot2::aes(label = toupper(.data[["code"]])),
        size = legend_text_size / ggplot2::.pt,
        color = badge_color, fontface = "bold"
      ) +
      ggplot2::geom_text(
        ggplot2::aes(x = 1.6, label = .data[["name"]]),
        hjust = 0, size = legend_text_size / ggplot2::.pt,
        color = "grey20"
      )
  }

  leg <- leg +
    ggplot2::scale_x_continuous(limits = c(0.5, 5)) +
    ggplot2::scale_y_continuous(
      limits = c(0.5, nrow(legend_df) + 0.5),
      expand = c(0, 0)
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(4, 8, 4, 8))

  # ── Compose ───────────────────────────────────────────────────────────────────
  if (legend_position == "right") {
    patchwork::wrap_plots(p, leg, ncol = 2, widths  = c(1, legend_size))
  } else if (legend_position == "left") {
    patchwork::wrap_plots(leg, p, ncol = 2, widths  = c(legend_size, 1))
  } else if (legend_position == "bottom") {
    patchwork::wrap_plots(p, leg, nrow = 2, heights = c(1, legend_size))
  } else {
    patchwork::wrap_plots(leg, p, nrow = 2, heights = c(legend_size, 1))
  }
}
