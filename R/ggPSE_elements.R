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
#'   \item{atomic_radius_pm}{Empirical atomic radius in picometres (Slater 1964);
#'     NA where not available}
#'   \item{density_g_cm3}{Density at STP in g/cm3; NA where not determined}
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

utils::globalVariables("ggpse_grid")
# Internal function used by all plotting functions.
# Points at ggpse_grid (the minimal dataset) when the package is loaded,
# and falls back to a hardcoded data frame when sourcing files directly
# (e.g. during development without usethis::use_data() having been run yet).
#' @keywords internal
.ggpse_elements <- function() {
  if (exists("ggpse_grid")) {
    return(ggpse_grid)
  }
  .ggpse_elements_fallback()
}

# Hardcoded fallback — only the four columns needed for plotting.
# Used when source()-ing R files directly without running prepare_element_data.R.
#' @keywords internal
.ggpse_elements_fallback <- function() {
  data.frame(
    symbol = c(
      "H",  "He", "Li", "Be", "B",  "C",  "N",  "O",  "F",  "Ne",
      "Na", "Mg", "Al", "Si", "P",  "S",  "Cl", "Ar",
      "K",  "Ca", "Sc", "Ti", "V",  "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn",
      "Ga", "Ge", "As", "Se", "Br", "Kr",
      "Rb", "Sr", "Y",  "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd",
      "In", "Sn", "Sb", "Te", "I",  "Xe",
      "Cs", "Ba", "La", "Hf", "Ta", "W",  "Re", "Os", "Ir", "Pt", "Au", "Hg",
      "Tl", "Pb", "Bi", "Po", "At", "Rn",
      "Fr", "Ra", "Ac", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn",
      "Nh", "Fl", "Mc", "Lv", "Ts", "Og",
      "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu",
      "Th", "Pa", "U",  "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr"
    ),
    atomic_number = c(
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10,
      11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
      31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
      41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
      51, 52, 53, 54, 55, 56, 57, 72, 73, 74,
      75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
      85, 86, 87, 88, 89,104,105,106,107,108,
     109,110,111,112,113,114,115,116,117,118,
      58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
      90, 91, 92, 93, 94, 95, 96, 97, 98, 99,100,101,102,103
    ),
    col = c(
       1, 18,  1,  2, 13, 14, 15, 16, 17, 18,
       1,  2, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17,
       4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17
    ),
    row = c(
      1, 1, 2, 2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3, 3, 3, 3,
      4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
      9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
     10,10,10,10,10,10,10,10,10,10,10,10,10,10
    ),
    stringsAsFactors = FALSE
  )
}
