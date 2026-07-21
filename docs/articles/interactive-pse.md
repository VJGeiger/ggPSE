# Interactive periodic table in Quarto

## Overview

[`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
wraps the standard
[`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) output
with [ggiraph](https://davidgohel.github.io/ggiraph/) interactivity.
Every tile becomes hoverable, showing a configurable tooltip with
element details. This vignette shows how to use it in a Quarto HTML
document.

## Installation

``` r

# Install ggPSE
remotes::install_github("VJGeiger/ggPSE")

# Install ggiraph (required for interactivity)
install.packages("ggiraph")
```

## Basic usage

The simplest call mirrors
[`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) — pass
a data frame and a value column. Hovering over any tile shows the
element symbol, atomic number, and value.

``` r

library(ggPSE)

battery <- data.frame(
  symbol     = c("Li", "Co", "Ni", "Mn", "Fe", "P", "C"),
  importance = c(0.95, 0.88, 0.75, 0.60, 0.45, 0.40, 0.35)
)

ggPSE_interactive(battery,
                  value_col    = "importance",
                  legend_title = "Battery relevance")
```

## Custom tooltip columns

Use `tooltip_cols` to control what appears in the hover tooltip. Any
column present in your data frame can be included.

``` r

data(ggpse_elements)

ggPSE_interactive(
  ggpse_elements,
  value_col    = "electronegativity",
  tooltip_cols = c("name", "atomic_weight", "block",
                   "electronegativity", "ionization_energy_eV"),
  legend_title = "Electronegativity (Pauling)"
)
```

## Highlight mode

[`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
supports the same `highlight` parameter as
[`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md). Hover
still works on all tiles including highlighted ones.

``` r

ggPSE_interactive(
  highlight = list(
    list(symbols = c("Li", "Co", "Ni", "Mn", "Fe", "P"),
         color   = "#2166ac",
         label   = "Battery metals"),
    list(symbols = c("Nd", "Dy", "Tb", "Pr", "La", "Ce"),
         color   = "#e63946",
         label   = "Rare earth magnets")
  )
)
```

## Subsetting the table

The `groups`, `periods`, `lanthanides`, and `actinides` parameters work
exactly as in
[`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md). Here,
only the transition metals are shown.

``` r

ggPSE_interactive(
  ggpse_elements,
  value_col   = "melting_point_K",
  groups      = c(3, 12),
  periods     = c(4, 6),
  lanthanides = FALSE,
  actinides   = FALSE,
  legend_title = "Melting point (K)"
)
```

## Customising hover appearance

Control the hover fill color and tooltip styling via `hover_fill` and
`hover_stroke`.

``` r

ggPSE_interactive(
  battery,
  value_col    = "importance",
  hover_fill   = "#2166ac",
  hover_stroke = "#ffffff",
  legend_title = "Battery relevance"
)
```

## Output size

Adjust `width_svg` and `height_svg` (in inches) to fit your document
layout.

``` r

ggPSE_interactive(
  battery,
  value_col  = "importance",
  width_svg  = 10,
  height_svg = 4
)
```

## Limitations

- Works with `format: html` only. For PDF or Word output, use
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md)
  instead and wrap the chunk with `#| eval: !knitr::is_latex_output()`.
- In **Shiny**, use
  [`ggiraph::girafeOutput()`](https://davidgohel.github.io/ggiraph/reference/girafeOutput.html)
  and
  [`ggiraph::renderGirafe()`](https://davidgohel.github.io/ggiraph/reference/renderGirafe.html)
  instead of calling
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
  directly in a render function.
- The interactive output cannot be embedded in a GitHub README directly.
  Use a GIF for the README and link to a hosted HTML version via GitHub
  Pages.

## Shiny example

``` r

library(shiny)
library(ggPSE)
library(ggiraph)

ui <- fluidPage(
  titlePanel("Interactive Periodic Table"),
  sidebarLayout(
    sidebarPanel(
      selectInput("prop", "Property",
                  choices = c("electronegativity", "melting_point_K",
                              "density_g_cm3", "ionization_energy_eV"))
    ),
    mainPanel(
      girafeOutput("pse", width = "100%", height = "500px")
    )
  )
)

server <- function(input, output) {
  output$pse <- renderGirafe({
    data(ggpse_elements)
    ggPSE_interactive(
      ggpse_elements,
      value_col    = input$prop,
      tooltip_cols = c("name", "atomic_weight", input$prop),
      legend_title = input$prop
    )
  })
}

shinyApp(ui, server)
```
