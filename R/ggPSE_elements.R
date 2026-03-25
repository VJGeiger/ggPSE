#' Element grid positions
#'
#' A data frame with the standard 18-column IUPAC periodic table layout.
#' Used internally by all ggPSE functions. Export it if you want to join
#' your own data against it before plotting.
#'
#' @format A data frame with 118 rows and 4 columns:
#' \describe{
#'   \item{symbol}{Element symbol, e.g. "Fe"}
#'   \item{atomic_number}{Atomic number (integer)}
#'   \item{col}{Column in the 18-column IUPAC layout (1-18)}
#'   \item{row}{Row; lanthanides = 9, actinides = 10}
#' }
"ggpse_elements"

#' @keywords internal
.ggpse_elements <- function() {
  data.frame(
    symbol = c(
      "H",  "He",
      "Li", "Be", "B",  "C",  "N",  "O",  "F",  "Ne",
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
