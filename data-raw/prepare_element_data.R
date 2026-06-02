# Builds two datasets bundled with ggPSE:
#
#   ggpse_grid     - minimal layout table (symbol, atomic_number, col, row)
#                    used internally by all plotting functions
#
#   ggpse_elements - properties table, opt-in for users who want to have
#                    built-in properties without own data
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

ggpse_elements <- data.frame(
  stringsAsFactors = FALSE,
  
  symbol = c(
    # H-He
    "H", "He",
    # Li-Ne
    "Li", "Be", "B",  "C",  "N",  "O",  "F",  "Ne",
    # Na-Ar
    "Na", "Mg", "Al", "Si", "P",  "S",  "Cl", "Ar",
    # K-Kr
    "K",  "Ca", "Sc", "Ti", "V",  "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn",
    "Ga", "Ge", "As", "Se", "Br", "Kr",
    # Rb-Xe
    "Rb", "Sr", "Y",  "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd",
    "In", "Sn", "Sb", "Te", "I",  "Xe",
    # Cs-Rn
    "Cs", "Ba", "La", "Hf", "Ta", "W",  "Re", "Os", "Ir", "Pt", "Au", "Hg",
    "Tl", "Pb", "Bi", "Po", "At", "Rn",
    # Fr-Og
    "Fr", "Ra", "Ac", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn",
    "Nh", "Fl", "Mc", "Lv", "Ts", "Og",
    # Lanthanides Ce-Lu
    "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu",
    # Actinides Th-Lr
    "Th", "Pa", "U",  "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr"
  ),
  
  name = c(
    # H-He
    "Hydrogen", "Helium",
    # Li-Ne
    "Lithium", "Beryllium", "Boron", "Carbon", "Nitrogen",
    "Oxygen", "Fluorine", "Neon",
    # Na-Ar
    "Sodium", "Magnesium", "Aluminium", "Silicon",
    "Phosphorus", "Sulfur", "Chlorine", "Argon",
    # K-Kr
    "Potassium", "Calcium", "Scandium", "Titanium", "Vanadium", "Chromium",
    "Manganese", "Iron", "Cobalt", "Nickel", "Copper", "Zinc",
    "Gallium", "Germanium", "Arsenic", "Selenium", "Bromine", "Krypton",
    # Rb-Xe
    "Rubidium", "Strontium", "Yttrium", "Zirconium", "Niobium", "Molybdenum",
    "Technetium", "Ruthenium", "Rhodium", "Palladium", "Silver", "Cadmium",
    "Indium", "Tin", "Antimony", "Tellurium", "Iodine", "Xenon",
    # Cs-Rn
    "Caesium", "Barium", "Lanthanum", "Hafnium", "Tantalum", "Tungsten",
    "Rhenium", "Osmium", "Iridium", "Platinum", "Gold", "Mercury",
    "Thallium", "Lead", "Bismuth", "Polonium", "Astatine", "Radon",
    # Fr-Og
    "Francium", "Radium", "Actinium",
    "Rutherfordium", "Dubnium", "Seaborgium", "Bohrium", "Hassium",
    "Meitnerium", "Darmstadtium", "Roentgenium", "Copernicium",
    "Nihonium", "Flerovium", "Moscovium", "Livermorium", "Tennessine", "Oganesson",
    # Lanthanides Ce-Lu
    "Cerium", "Praseodymium", "Neodymium", "Promethium", "Samarium", "Europium",
    "Gadolinium", "Terbium", "Dysprosium", "Holmium", "Erbium", "Thulium",
    "Ytterbium", "Lutetium",
    # Actinides Th-Lr
    "Thorium", "Protactinium", "Uranium", "Neptunium", "Plutonium", "Americium",
    "Curium", "Berkelium", "Californium", "Einsteinium", "Fermium", "Mendelevium",
    "Nobelium", "Lawrencium"
  ),
  
  atomic_number = c(
    # H-He
    1,  2,
    # Li-Ne
    3,  4,  5,  6,  7,  8,  9, 10,
    # Na-Ar
    11, 12, 13, 14, 15, 16, 17, 18,
    # K-Kr
    19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
    # Rb-Xe
    37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
    # Cs-Rn
    55, 56, 57, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
    # Fr-Og
    87, 88, 89, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118,
    # Lanthanides Ce-Lu
    58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
    # Actinides Th-Lr
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103
  ),
  
  col = c(
    # H-He
    1, 18,
    # Li-Ne
    1,  2, 13, 14, 15, 16, 17, 18,
    # Na-Ar
    1,  2, 13, 14, 15, 16, 17, 18,
    # K-Kr
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Rb-Xe
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Cs-Rn
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Fr-Og
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Lanthanides Ce-Lu
    4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17,
    # Actinides Th-Lr
    4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17
  ),
  
  row = c(
    # H-He
    1, 1,
    # Li-Ne
    2, 2, 2, 2, 2, 2, 2, 2,
    # Na-Ar
    3, 3, 3, 3, 3, 3, 3, 3,
    # K-Kr
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    # Rb-Xe
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    # Cs-Rn
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    # Fr-Og
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    # Lanthanides Ce-Lu
    9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
    # Actinides Th-Lr
    10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
  ),
  
  period = c(
    # H-He
    1, 1,
    # Li-Ne
    2, 2, 2, 2, 2, 2, 2, 2,
    # Na-Ar
    3, 3, 3, 3, 3, 3, 3, 3,
    # K-Kr
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    # Rb-Xe
    5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
    # Cs-Rn
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    # Fr-Og
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    # Lanthanides Ce-Lu (period 6)
    6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    # Actinides Th-Lr (period 7)
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
  ),
  
  group = c(
    # H-He
    1, 18,
    # Li-Ne
    1,  2, 13, 14, 15, 16, 17, 18,
    # Na-Ar
    1,  2, 13, 14, 15, 16, 17, 18,
    # K-Kr
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Rb-Xe
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Cs-Rn
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Fr-Og
    1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    # Lanthanides Ce-Lu -> here NA to keep group numerical
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    # Actinides Th-Lr  -> here NA to keep group numerical
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
  ),
  
  block = c(
    # H-He
    "s", "s",
    # Li-Ne
    "s", "s", "p", "p", "p", "p", "p", "p",
    # Na-Ar
    "s", "s", "p", "p", "p", "p", "p", "p",
    # K-Kr
    "s", "s", "d", "d", "d", "d", "d", "d", "d", "d", "d", "d", "p", "p", "p", "p", "p", "p",
    # Rb-Xe
    "s", "s", "d", "d", "d", "d", "d", "d", "d", "d", "d", "d", "p", "p", "p", "p", "p", "p",
    # Cs-Rn
    "s", "s", "d", "d", "d", "d", "d", "d", "d", "d", "d", "d", "p", "p", "p", "p", "p", "p",
    # Fr-Og
    "s", "s", "d", "d", "d", "d", "d", "d", "d", "d", "d", "d", "p", "p", "p", "p", "p", "p",
    # Lanthanides Ce-Lu
    "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f",
    # Actinides Th-Lr
    "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f"
  ),
  
  category = c(
    # H-He
    "nonmetal", "noble gas",
    # Li-Ne
    "alkali metal", "alkaline earth metal", "metalloid",
    "nonmetal", "nonmetal", "nonmetal", "halogen", "noble gas",
    # Na-Ar
    "alkali metal", "alkaline earth metal", "post-transition metal", "metalloid",
    "nonmetal", "nonmetal", "halogen", "noble gas",
    # K-Kr
    "alkali metal", "alkaline earth metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal",
    "post-transition metal", "metalloid", "metalloid", "nonmetal", "halogen", "noble gas",
    # Rb-Xe
    "alkali metal", "alkaline earth metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal",
    "post-transition metal", "post-transition metal", "metalloid", "metalloid",
    "halogen", "noble gas",
    # Cs-Rn
    "alkali metal", "alkaline earth metal", "lanthanide",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal",
    "post-transition metal", "post-transition metal", "post-transition metal",
    "post-transition metal", "halogen", "noble gas",
    # Fr-Og
    "alkali metal", "alkaline earth metal", "actinide",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal", "transition metal", "transition metal",
    "transition metal", "transition metal",
    # Lanthanides Ce-Lu
    "lanthanide", "lanthanide", "lanthanide", "lanthanide", "lanthanide", "lanthanide",
    "lanthanide", "lanthanide", "lanthanide", "lanthanide", "lanthanide", "lanthanide",
    "lanthanide", "lanthanide",
    # Actinides Th-Lr
    "actinide", "actinide", "actinide", "actinide", "actinide", "actinide",
    "actinide", "actinide", "actinide", "actinide", "actinide", "actinide",
    "actinide", "actinide"
  ),
  
  # IUPAC 2021 standard atomic weights (NA = no stable isotope / not determined)
  atomic_weight = c(
    # H-He
    1.008,   4.003,
    # Li-Ne
    6.941,   9.012,  10.811,  12.011,  14.007,  15.999,  18.998,  20.180,
    # Na-Ar
    22.990,  24.305,  26.982,  28.086,  30.974,  32.060,  35.450,  39.948,
    # K-Kr
    39.098,  40.078,  44.956,  47.867,  50.942,  51.996,  54.938,  55.845,
    58.933,  58.693,  63.546,  65.380,  69.723,  72.630,  74.922,  78.971,
    79.904,  83.798,
    # Rb-Xe
    85.468,  87.620,  88.906,  91.224,  92.906,  95.950,
    NA, 101.070, 102.906, 106.420, 107.868, 112.414,
    114.818, 118.710, 121.760, 127.600, 126.904, 131.293,
    # Cs-Rn
    132.905, 137.327, 138.905, 178.490, 180.948, 183.840, 186.207, 190.230,
    192.217, 195.084, 196.967, 200.592, 204.380, 207.200, 208.980,
    NA,      NA,      NA,
    # Fr-Og
    NA,      NA,      NA,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,      NA,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,
    # Lanthanides Ce-Lu
    140.116, 140.908, 144.242,      NA, 150.360, 151.964, 157.250, 158.925,
    162.500, 164.930, 167.259, 168.934, 173.045, 174.967,
    # Actinides Th-Lr
    232.038, 231.036, 238.029,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,      NA,      NA,      NA,      NA
  ),
  
  # Pauling electronegativity (NA = not meaningful / not determined)
  electronegativity = c(
    # H-He
    2.20,   NA,
    # Li-Ne
    0.98, 1.57, 2.04, 2.55, 3.04, 3.44, 3.98,   NA,
    # Na-Ar
    0.93, 1.31, 1.61, 1.90, 2.19, 2.58, 3.16,   NA,
    # K-Kr
    0.82, 1.00, 1.36, 1.54, 1.63, 1.66, 1.55, 1.83, 1.88, 1.91, 1.90, 1.65,
    1.81, 2.01, 2.18, 2.55, 2.96, 3.00,
    # Rb-Xe
    0.82, 0.95, 1.22, 1.33, 1.60, 2.16, 1.90, 2.20, 2.28, 2.20, 1.93, 1.69,
    1.78, 1.96, 2.05, 2.10, 2.66, 2.60,
    # Cs-Rn
    0.79, 0.89, 1.10, 1.30, 1.50, 2.36, 1.90, 2.20, 2.20, 2.28, 2.54, 2.00,
    1.62, 2.33, 2.02, 2.00, 2.20,   NA,
    # Fr-Og
    0.70, 0.90, 1.10,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,
    NA,   NA,   NA,   NA,   NA,   NA,
    # Lanthanides Ce-Lu
    1.12, 1.13, 1.14,   NA, 1.17, 1.20, 1.20, 1.10, 1.22, 1.23, 1.24, 1.25,
    1.10, 1.27,
    # Actinides Th-Lr
    1.30, 1.50, 1.38,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,   NA,
    NA,   NA
  ),
  
  # Empirical atomic radius in pm (NA = not available)
  atomic_radius_pm = c(
    # H-He
    53,  31,
    # Li-Ne
    167, 112,  87,  67,  56,  48,  42,  38,
    # Na-Ar
    190, 145, 118, 111,  98,  88,  79,  71,
    # K-Kr
    243, 194, 184, 176, 171, 166, 161, 156, 152, 149, 145, 142,
    136, 125, 114, 103,  94,  88,
    # Rb-Xe
    265, 219, 212, 206, 198, 190, 183, 178, 173, 169, 165, 161,
    156, 145, 133, 123, 115, 108,
    # Cs-Rn
    298, 253, 195, 208, 200, 193, 188, 185, 180, 177, 174, 171,
    156, 154, 143, 135,  NA,  NA,
    # Fr-Og
    NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,
    NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,
    # Lanthanides Ce-Lu
    185, 185, 185,  NA, 185, 185, 180, 175, 175, 175, 175, 175, 175, 175,
    # Actinides Th-Lr
    180,  NA, 175,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA,  NA
  ),
  
  # Density at STP in g/cm3
  density_g_cm3 = c(
    # H-He
    0.0000899, 0.0001785,
    # Li-Ne
    0.535,  1.848,  2.340,  2.267,  0.001251, 0.001429, 0.001696, 0.0009,
    # Na-Ar
    0.968,  1.738,  2.700,  2.330,  1.823,  2.067,  0.003214, 0.001784,
    # K-Kr
    0.856,  1.550,  2.985,  4.507,  6.110,  7.190,  7.470,  7.874,
    8.900,  8.908,  8.960,  7.133,  5.910,  5.323,  5.730,  4.809,
    3.120,  0.003749,
    # Rb-Xe
    1.532,  2.630,  4.472,  6.511,  8.570, 10.280, 11.500, 12.370,
    12.410, 12.020, 10.490,  8.650,  7.310,  7.287,  6.685,  6.232,
    4.933,  0.005887,
    # Cs-Rn
    1.873,  3.510,  6.162, 13.310, 16.650, 19.300, 21.020, 22.590,
    22.560, 21.450, 19.300, 13.534, 11.850, 11.340,  9.780,
    NA,     NA,  0.00973,
    # Fr-Og
    NA,  5.000, 10.070,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,     NA,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,
    # Lanthanides Ce-Lu
    6.689,  6.640,  7.010,     NA,  7.353,  5.244,  7.901,  8.219,
    8.551,  8.795,  9.066,  9.321,  6.570,  9.841,
    # Actinides Th-Lr
    11.724, 15.370, 19.050, 20.450, 19.840, 13.670, 13.510, 14.780,
    15.100,     NA,     NA,     NA,     NA,     NA
  ),
  
  # Melting point in Kelvin (NA = not determined)
  melting_point_K = c(
    # H-He
    14.0,   0.95,
    # Li-Ne
    453.7, 1560.0, 2349.0, 3800.0,   63.2,   54.4,   53.5,   24.6,
    # Na-Ar
    370.9,  923.0,  933.5, 1687.0,  317.3,  388.4,  171.7,   83.8,
    # K-Kr
    336.5, 1115.0, 1814.0, 1941.0, 2183.0, 2180.0, 1519.0, 1811.0,
    1768.0, 1728.0, 1357.8,  692.7,  302.9, 1211.4, 1090.0,  494.0,
    265.9,  115.8,
    # Rb-Xe
    312.5, 1050.0, 1799.0, 2128.0, 2750.0, 2896.0, 2430.0, 2607.0,
    2237.0, 1828.1, 1234.9,  594.2,  429.7,  505.1,  903.8,  722.7,
    386.9,  161.4,
    # Cs-Rn
    301.6, 1000.0, 1193.0, 2506.0, 3290.0, 3695.0, 3459.0, 3306.0,
    2719.0, 2041.4, 1337.3,  234.3,  577.0,  600.6,  544.6,  527.0,
    575.0,  202.0,
    # Fr-Og
    300.0,  973.0, 1500.0,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,     NA,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,
    # Lanthanides Ce-Lu
    1068.0, 1208.0, 1297.0, 1315.0, 1345.0, 1099.0, 1585.0, 1629.0,
    1680.0, 1734.0, 1802.0, 1818.0, 1097.0, 1925.0,
    # Actinides Th-Lr
    2023.0, 1841.0, 1405.3,  912.0,  912.5, 1449.0, 1613.0, 1259.0,
    1173.0, 1133.0,     NA,     NA,     NA,     NA
  ),
  
  # Source: NIST WebBook https://webbook.nist.gov
  # Boiling point in Kelvin (NA = not determined)
  boiling_point_K = c(
    # H-He
    20.3,   4.2,
    # Li-Ne
    1603.0, 2742.0, 4200.0, 4300.0,   77.4,   90.2,   85.0,   27.1,
    # Na-Ar
    1156.0, 1363.0, 2792.0, 3538.0,  550.0,  717.8,  239.1,   87.3,
    # K-Kr
    1032.0, 1757.0, 3109.0, 3560.0, 3680.0, 2944.0, 2334.0, 3134.0,
    3200.0, 3186.0, 2835.0, 1180.0, 2477.0, 3106.0,  887.0,  958.0,
    332.0,  119.9,
    # Rb-Xe
    961.0, 1655.0, 3609.0, 4682.0, 5017.0, 4912.0, 4538.0, 4423.0,
    3968.0, 3236.0, 2435.0, 1040.0, 2345.0, 2875.0, 1860.0, 1261.0,
    457.4,  165.1,
    # Cs-Rn
    944.0, 2170.0, 3737.0, 4876.0, 5731.0, 5828.0, 5869.0, 5285.0,
    4701.0, 4098.0, 3129.0,  629.9, 1746.0, 2022.0, 1837.0, 1235.0,
    610.0,  211.5,
    # Fr-Og
    950.0, 1413.0, 3471.0,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,     NA,     NA,     NA,     NA,     NA,     NA,
    NA,     NA,
    # Lanthanides Ce-Lu
    3716.0, 3793.0, 3347.0,     NA, 2173.0, 1802.0, 3546.0, 3396.0,
    2840.0, 2993.0, 3141.0, 2223.0, 1469.0, 3675.0,
    # Actinides Th-Lr
    5061.0, 4300.0, 4404.0, 4175.0, 3501.0, 2880.0, 3383.0,     NA,
    NA,     NA,     NA,     NA,     NA,     NA
  ),
  
  # Source: NIST WebBook https://webbook.nist.gov
  # First ionization energy in eV (NA = not determined)
  ionization_energy_eV = c(
    # H-He
    13.598,  24.587,
    # Li-Ne
    5.392,   9.323,   8.298,  11.260,  14.534,  13.618,  17.423,  21.565,
    # Na-Ar
    5.139,   7.646,   5.986,   8.152,  10.487,  10.360,  12.968,  15.760,
    # K-Kr
    4.341,   6.113,   6.561,   6.828,   6.746,   6.767,   7.434,   7.902,
    7.881,   7.640,   7.727,   9.394,   5.999,   7.900,   9.789,   9.752,
    11.814,  14.000,
    # Rb-Xe
    4.177,   5.695,   6.217,   6.634,   6.759,   7.092,   7.280,   7.361,
    7.459,   8.337,   7.576,   8.994,   5.786,   7.344,   8.608,   9.010,
    10.451,  12.130,
    # Cs-Rn
    3.894,   5.212,   5.577,   6.825,   7.550,   7.864,   7.834,   8.438,
    8.967,   8.959,   9.226,  10.438,   6.108,   7.417,   7.286,   8.414,
    9.318,  10.749,
    # Fr-Og
    4.073,   5.279,   5.170,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,      NA,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,
    # Lanthanides Ce-Lu
    5.539,   5.473,   5.525,   5.582,   5.644,   5.670,   6.150,   5.864,
    5.939,   6.022,   6.108,   6.184,   6.254,   5.426,
    # Actinides Th-Lr
    6.307,   5.890,   6.194,   6.266,   6.060,   5.993,   5.991,   6.198,
    6.282,   6.420,   6.500,   6.580,   6.650,   4.900
  ),
  
  # Source: NIST WebBook https://webbook.nist.gov
  # Electron affinity in eV (NA = not determined, 0 = stable negative ion does not form)
  electron_affinity_eV = c(
    # H-He
    0.754,   0.000,
    # Li-Ne
    0.618,   0.000,   0.277,   1.263,   0.007,   1.461,   3.401,   0.000,
    # Na-Ar
    0.548,   0.000,   0.441,   1.385,   0.747,   2.077,   3.613,   0.000,
    # K-Kr
    0.502,   0.025,   0.188,   0.079,   0.525,   0.666,   0.000,   0.151,
    0.662,   1.156,   1.235,   0.000,   0.300,   1.233,   0.804,   2.021,
    3.364,   0.000,
    # Rb-Xe
    0.486,   0.052,   0.307,   0.426,   0.893,   0.746,   0.550,   1.050,
    1.137,   0.562,   1.302,   0.000,   0.300,   1.112,   1.047,   1.971,
    3.059,   0.000,
    # Cs-Rn
    0.472,   0.145,   0.470,   0.000,   0.323,   0.816,   0.150,   1.100,
    1.565,   2.128,   2.309,   0.000,   0.200,   0.364,   0.946,   1.900,
    2.416,   0.000,
    # Fr-Og
    0.486,   0.100,   0.350,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,      NA,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,
    # Lanthanides Ce-Lu
    0.500,   0.100,   0.100,      NA,   0.162,   0.116,   0.500,   1.165,
    0.352,   0.338,   0.312,   1.029,   0.020,   0.346,
    # Actinides Th-Lr
    0.608,      NA,   0.536,      NA,      NA,      NA,      NA,      NA,
    NA,      NA,      NA,      NA,      NA,      NA
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

# Save both — no usethis needed, base R does this fine
dir.create("data", showWarnings = FALSE)
save(ggpse_grid,     file = "data/ggpse_grid.rda",     compress = "bzip2")
save(ggpse_elements, file = "data/ggpse_elements.rda", compress = "bzip2")

message("Saved data/ggpse_grid.rda     — ",
        nrow(ggpse_grid), " rows, ", ncol(ggpse_grid), " columns")
message("Saved data/ggpse_elements.rda — ",
        nrow(ggpse_elements), " rows, ", ncol(ggpse_elements), " columns")
