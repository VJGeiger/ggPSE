# data-raw/prepare_element_data.R
#
# Builds two datasets bundled with ggPSE:
#
#   ggpse_grid     — minimal layout table (symbol, atomic_number, col, row)
#                    used internally by all plotting functions
#
#   ggpse_elements — full properties table, opt-in for users who want to
#                    plot built-in properties without supplying their own data
#
# Sources:
#   Atomic weights:      IUPAC 2021 Table of Standard Atomic Weights
#                        https://iupac.org/what-we-do/periodic-table-of-elements/
#   Electronegativity:   Pauling scale via WebElements
#   Atomic radius:       Slater, J.C. (1964). J. Chem. Phys., 41, 3199
#   Physical properties: NIST WebBook https://webbook.nist.gov
#   Grid positions:      IUPAC 18-column periodic table layout
#
# Run once to regenerate:
#   source("data-raw/prepare_element_data.R")
#
# Requires: usethis

ggpse_elements <- data.frame(
  stringsAsFactors = FALSE,

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

  name = c(
    "Hydrogen","Helium","Lithium","Beryllium","Boron","Carbon","Nitrogen",
    "Oxygen","Fluorine","Neon","Sodium","Magnesium","Aluminium","Silicon",
    "Phosphorus","Sulfur","Chlorine","Argon","Potassium","Calcium","Scandium",
    "Titanium","Vanadium","Chromium","Manganese","Iron","Cobalt","Nickel",
    "Copper","Zinc","Gallium","Germanium","Arsenic","Selenium","Bromine",
    "Krypton","Rubidium","Strontium","Yttrium","Zirconium","Niobium",
    "Molybdenum","Technetium","Ruthenium","Rhodium","Palladium","Silver",
    "Cadmium","Indium","Tin","Antimony","Tellurium","Iodine","Xenon",
    "Caesium","Barium","Lanthanum","Hafnium","Tantalum","Tungsten","Rhenium",
    "Osmium","Iridium","Platinum","Gold","Mercury","Thallium","Lead",
    "Bismuth","Polonium","Astatine","Radon","Francium","Radium","Actinium",
    "Rutherfordium","Dubnium","Seaborgium","Bohrium","Hassium","Meitnerium",
    "Darmstadtium","Roentgenium","Copernicium","Nihonium","Flerovium",
    "Moscovium","Livermorium","Tennessine","Oganesson",
    "Cerium","Praseodymium","Neodymium","Promethium","Samarium","Europium",
    "Gadolinium","Terbium","Dysprosium","Holmium","Erbium","Thulium",
    "Ytterbium","Lutetium",
    "Thorium","Protactinium","Uranium","Neptunium","Plutonium","Americium",
    "Curium","Berkelium","Californium","Einsteinium","Fermium","Mendelevium",
    "Nobelium","Lawrencium"
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

  period = c(
    1, 1, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
  ),

  group = c(
     1, 18,  1,  2, 13, 14, 15, 16, 17, 18,
     1,  2, 13, 14, 15, 16, 17, 18,
     1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
     1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
     1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
     1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
  ),

  block = c(
    "s","s","s","s","p","p","p","p","p","p",
    "s","s","p","p","p","p","p","p",
    "s","s","d","d","d","d","d","d","d","d","d","d","p","p","p","p","p","p",
    "s","s","d","d","d","d","d","d","d","d","d","d","p","p","p","p","p","p",
    "s","s","d","d","d","d","d","d","d","d","d","d","p","p","p","p","p","p",
    "s","s","d","d","d","d","d","d","d","d","d","d","p","p","p","p","p","p",
    "f","f","f","f","f","f","f","f","f","f","f","f","f","f",
    "f","f","f","f","f","f","f","f","f","f","f","f","f","f"
  ),

  category = c(
    "nonmetal","noble gas","alkali metal","alkaline earth metal","metalloid",
    "nonmetal","nonmetal","nonmetal","halogen","noble gas",
    "alkali metal","alkaline earth metal","post-transition metal","metalloid",
    "nonmetal","nonmetal","halogen","noble gas",
    "alkali metal","alkaline earth metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal",
    "post-transition metal","metalloid","metalloid","nonmetal","halogen","noble gas",
    "alkali metal","alkaline earth metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal",
    "post-transition metal","post-transition metal","metalloid","metalloid",
    "halogen","noble gas",
    "alkali metal","alkaline earth metal","lanthanide",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal",
    "post-transition metal","post-transition metal","post-transition metal",
    "post-transition metal","halogen","noble gas",
    "alkali metal","alkaline earth metal","actinide",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal","transition metal","transition metal",
    "transition metal","transition metal",
    "lanthanide","lanthanide","lanthanide","lanthanide","lanthanide","lanthanide",
    "lanthanide","lanthanide","lanthanide","lanthanide","lanthanide","lanthanide",
    "lanthanide","lanthanide",
    "actinide","actinide","actinide","actinide","actinide","actinide",
    "actinide","actinide","actinide","actinide","actinide","actinide",
    "actinide","actinide"
  ),

  atomic_weight = c(
      1.008,   4.003,   6.941,   9.012,  10.811,  12.011,  14.007,
     15.999,  18.998,  20.180,  22.990,  24.305,  26.982,  28.086,
     30.974,  32.060,  35.450,  39.948,  39.098,  40.078,  44.956,
     47.867,  50.942,  51.996,  54.938,  55.845,  58.933,  58.693,
     63.546,  65.380,  69.723,  72.630,  74.922,  78.971,  79.904,
     83.798,  85.468,  87.620,  88.906,  91.224,  92.906,  95.950,
         NA, 101.070, 102.906, 106.420, 107.868, 112.414, 114.818,
    118.710, 121.760, 127.600, 126.904, 131.293, 132.905, 137.327,
    138.905, 178.490, 180.948, 183.840, 186.207, 190.230, 192.217,
    195.084, 196.967, 200.592, 204.380, 207.200, 208.980,
         NA,     NA,     NA,     NA,     NA,     NA,     NA,     NA,
         NA,     NA,     NA,     NA,     NA,     NA,     NA,     NA,
         NA,     NA,     NA,     NA,
    140.116, 140.908, 144.242,     NA, 150.360, 151.964, 157.250,
    158.925, 162.500, 164.930, 167.259, 168.934, 173.045, 174.967,
    232.038, 231.036, 238.029,     NA,     NA,     NA,     NA,
         NA,     NA,     NA,     NA,     NA,     NA,     NA, NA
  ),

  electronegativity = c(
    2.20,   NA, 0.98, 1.57, 2.04, 2.55, 3.04, 3.44, 3.98,   NA,
    0.93, 1.31, 1.61, 1.90, 2.19, 2.58, 3.16,   NA,
    0.82, 1.00, 1.36, 1.54, 1.63, 1.66, 1.55, 1.83, 1.88, 1.91, 1.90, 1.65,
    1.81, 2.01, 2.18, 2.55, 2.96, 3.00,
    0.82, 0.95, 1.22, 1.33, 1.60, 2.16, 1.90, 2.20, 2.28, 2.20, 1.93, 1.69,
    1.78, 1.96, 2.05, 2.10, 2.66, 2.60,
    0.79, 0.89, 1.10, 1.30, 1.50, 2.36, 1.90, 2.20, 2.20, 2.28, 2.54, 2.00,
    1.62, 2.33, 2.02, 2.00, 2.20,   NA,
    0.70, 0.90, 1.10,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,
      NA,   NA,   NA,   NA,   NA,   NA,
    1.12, 1.13, 1.14,   NA, 1.17, 1.20, 1.20, 1.10, 1.22, 1.23, 1.24, 1.25,
    1.10, 1.27,
    1.30, 1.50, 1.38,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,
      NA,   NA
  ),

  atomic_radius_pm = c(
     53,  31, 167, 112,  87,  67,  56,  48,  42,  38,
    190, 145, 118, 111,  98,  88,  79,  71,
    243, 194, 184, 176, 171, 166, 161, 156, 152, 149, 145, 142,
    136, 125, 114, 103,  94,  88,
    265, 219, 212, 206, 198, 190, 183, 178, 173, 169, 165, 161,
    156, 145, 133, 123, 115, 108,
    298, 253, 195, 208, 200, 193, 188, 185, 180, 177, 174, 171,
    156, 154, 143, 135,  NA,  NA,
     NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,
     NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,
    185, 185, 185,  NA, 185, 185, 180, 175, 175, 175, 175, 175, 175, 175,
    180,  NA, 175,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA
  ),

  density_g_cm3 = c(
    0.0000899, 0.0001785, 0.535,  1.848,  2.340,  2.267,  0.001251,
    0.001429,  0.001696,  0.0009,
    0.968,  1.738,  2.700,  2.330,  1.823,  2.067,  0.003214, 0.001784,
    0.856,  1.550,  2.985,  4.507,  6.110,  7.190,  7.470,  7.874,
    8.900,  8.908,  8.960,  7.133,  5.910,  5.323,  5.730,  4.809,
    3.120,  0.003749,
    1.532,  2.630,  4.472,  6.511,  8.570, 10.280, 11.500, 12.370,
   12.410, 12.020, 10.490,  8.650,  7.310,  7.287,  6.685,  6.232,
    4.933,  0.005887,
    1.873,  3.510,  6.162, 13.310, 16.650, 19.300, 21.020, 22.590,
   22.560, 21.450, 19.300, 13.534, 11.850, 11.340,  9.780,
       NA,    NA,  0.00973,
       NA,  5.000, 10.070,    NA,    NA,    NA,    NA,    NA,
       NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,
    6.689,  6.640,  7.010,    NA,  7.353,  5.244,  7.901,  8.219,
    8.551,  8.795,  9.066,  9.321,  6.570,  9.841,
   11.724, 15.370, 19.050, 20.450, 19.840, 13.670, 13.510, 14.780,
   15.100,    NA,    NA,    NA,    NA,    NA
  ),

  melting_point_K = c(
     14.0,   0.95,  453.7, 1560.0, 2349.0, 3800.0,   63.2,   54.4,
     53.5,  24.6,
    370.9,  923.0,  933.5, 1687.0,  317.3,  388.4,  171.7,   83.8,
    336.5, 1115.0, 1814.0, 1941.0, 2183.0, 2180.0, 1519.0, 1811.0,
   1768.0, 1728.0, 1357.8,  692.7,  302.9, 1211.4, 1090.0,  494.0,
    265.9,  115.8,
    312.5, 1050.0, 1799.0, 2128.0, 2750.0, 2896.0, 2430.0, 2607.0,
   2237.0, 1828.1, 1234.9,  594.2,  429.7,  505.1,  903.8,  722.7,
    386.9,  161.4,
    301.6, 1000.0, 1193.0, 2506.0, 3290.0, 3695.0, 3459.0, 3306.0,
   2719.0, 2041.4, 1337.3,  234.3,  577.0,  600.6,  544.6,  527.0,
    575.0,  202.0,
    300.0,  973.0, 1500.0,    NA,    NA,    NA,    NA,    NA,
       NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,    NA,
   1068.0, 1208.0, 1297.0, 1315.0, 1345.0, 1099.0, 1585.0, 1629.0,
   1680.0, 1734.0, 1802.0, 1818.0, 1097.0, 1925.0,
   2023.0, 1841.0, 1405.3,  912.0,  912.5, 1449.0, 1613.0, 1259.0,
   1173.0, 1133.0,    NA,    NA,    NA,    NA
  )
)

# Minimal grid — just what the plotting functions need internally
ggpse_grid <- ggpse_elements[, c("symbol", "atomic_number", "col", "row")]

# Sanity checks
stopifnot(nrow(ggpse_elements) == 118)
stopifnot(nrow(ggpse_grid)     == 118)
stopifnot(length(unique(ggpse_elements$symbol)) == 118)
stopifnot(all(ggpse_grid$col >= 1 & ggpse_grid$col <= 18))
stopifnot(all(ggpse_grid$row >= 1 & ggpse_grid$row <= 10))

# Save both
usethis::use_data(ggpse_grid,     overwrite = TRUE)
usethis::use_data(ggpse_elements, overwrite = TRUE)

message("Saved data/ggpse_grid.rda     — ",
        nrow(ggpse_grid), " rows, ", ncol(ggpse_grid), " columns")
message("Saved data/ggpse_elements.rda — ",
        nrow(ggpse_elements), " rows, ", ncol(ggpse_elements), " columns")
