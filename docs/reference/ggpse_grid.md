# Minimal element grid for plotting

A data frame with the IUPAC 18-column periodic table layout for all 118
elements. This is the dataset used internally by all ggPSE plotting
functions. It contains only what is needed to position tiles correctly.

## Usage

``` r
data(ggpse_grid)
```

## Format

A data frame with 118 rows and 4 columns:

- symbol:

  Element symbol, e.g. "Fe"

- atomic_number:

  Atomic number (integer)

- col:

  Column in the IUPAC 18-column layout (1-18)

- row:

  Display row; lanthanides = 9, actinides = 10

## Source

IUPAC 18-column periodic table layout.
<https://iupac.org/what-we-do/periodic-table-of-elements/>

## Details

For a richer table including physical and chemical properties, see
\[ggpse_elements\].

## Examples

``` r
data(ggpse_grid)
head(ggpse_grid)
#>   symbol atomic_number col row
#> 1      H             1   1   1
#> 2     He             2  18   1
#> 3     Li             3   1   2
#> 4     Be             4   2   2
#> 5      B             5  13   2
#> 6      C             6  14   2

# Join your own data against the grid
my_data <- data.frame(symbol = c("Fe", "Au"), value = c(0.4, 0.9))
merged  <- merge(ggpse_grid, my_data, by = "symbol", all.x = TRUE)
```
