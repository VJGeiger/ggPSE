# R/ggPSE_elements.R

#' Minimal element grid for plotting
#'
#' A data frame with the IUPAC 18-column periodic table layout for all 118
#' elements. This is the dataset used internally by all ggPSE plotting
#' functions. It contains only what is needed to position tiles correctly.
#'
#' For a richer table including physical and chemical properties, see
#' [ggpse_elements].
#'
#' @format A data frame with 118 rows and 4 columns:
#' \describe{
#'   \item{symbol}{Element symbol, e.g. "Fe"}
#'   \item{atomic_number}{Atomic number (integer)}
#'   \item{col}{Column in the IUPAC 18-column layout (1-18)}
#'   \item{row}{Display row; lanthanides = 9, actinides = 10}
#' }
#'
#' @source IUPAC 18-column periodic table layout.
#' \url{https://iupac.org/what-we-do/periodic-table-of-elements/}
#'
#' @examples
#' data(ggpse_grid)
#' head(ggpse_grid)
#'
#' # Join your own data against the grid
#' my_data <- data.frame(symbol = c("Fe", "Au"), value = c(0.4, 0.9))
#' merged  <- merge(ggpse_grid, my_data, by = "symbol", all.x = TRUE)
"ggpse_grid"


#' Full element properties table
#'
#' A data frame with physical and chemical properties for all 118 elements,
#' together with their IUPAC 18-column grid positions. Use this dataset
#' directly with [ggPSE()] to plot built-in properties without supplying
#' external data.
#'
#' For just the grid positions used internally by plotting functions, see
#' [ggpse_grid].
#'
#' @format A data frame with 118 rows and 17 columns:
#' \describe{
#'   \item{symbol}{Element symbol, e.g. "Fe"}
#'   \item{name}{Full element name, e.g. "Iron"}
#'   \item{atomic_number}{Atomic number (integer)}
#'   \item{col}{Column in the IUPAC 18-column layout (1-18)}
#'   \item{row}{Display row; lanthanides = 9, actinides = 10}
#'   \item{period}{IUPAC period (1-7)}
#'   \item{group}{IUPAC group (1-18); NA for lanthanides and actinides}
#'   \item{block}{Orbital block: "s", "p", "d", or "f"}
#'   \item{category}{Element category, e.g. "transition metal", "halogen"}
#'   \item{atomic_weight}{Standard atomic weight (IUPAC 2021); NA where not defined}
#'   \item{electronegativity}{Pauling electronegativity; NA for noble gases and
#'     elements without reliable values}
#'   \item{atomic_radius_pm}{Empirical atomic radius in picometers (Slater 1964);
#'     NA where not available}
#'   \item{density_g_cm3}{Density at standard temp in g/cm3; NA where not determined}
#'   \item{melting_point_K}{Melting point in Kelvin; NA where not determined}
#'   \item{boiling_point_K}{Boiling point in Kelvin; NA where not determined}
#'   \item{ionization_energy_eV}{First ionization energy in eV (NIST)}
#'   \item{electron_affinity_eV}{Electron affinity in eV (NIST);
#'     0 indicates stable negative ion does not form}
#' }
#'
#' @source
#' Atomic weights: IUPAC Commission on Isotopic Abundances and Atomic Weights
#' (2021). \url{https://iupac.org/what-we-do/periodic-table-of-elements/}
#'
#' Electronegativity: Pauling, L. (1960). The Nature of the Chemical Bond.
#' Cornell University Press.
#'
#' Atomic radii: Slater, J.C. (1964). Journal of Chemical Physics, 41, 3199.
#'
#' Physical properties: NIST WebBook.
#' \url{https://webbook.nist.gov}
#'
#' @examples
#' data(ggpse_elements)
#' ggPSE(ggpse_elements, value_col = "electronegativity",
#'       legend_title = "Electronegativity (Pauling)")
#'
#' # Plot atomic radius
#' ggPSE(ggpse_elements, value_col = "atomic_radius_pm",
#'       color_high = "#08519c",
#'       legend_title = "Atomic radius (pm)")
#'
#' # Filter to d-block only
#' ggPSE(ggpse_elements[ggpse_elements$block == "d", ],
#'       value_col = "melting_point_K",
#'       legend_title = "Melting point (K)")
#'
#' # Join your own measurements against it
#' \dontrun{
#'   my_data <- merge(ggpse_elements, my_data, by = "symbol", all.x = TRUE)
#'   ggPSE(my_data, value_col = "my_measurement")
#' }
"ggpse_elements"

# Internal accessor used by all plotting functions: the minimal tile table
# (symbol, atomic_number, col, row). The data set is lazy-loaded, so it is
# available without library() and without data().
#' @keywords internal
.ggpse_elements <- function() ggPSE::ggpse_grid
