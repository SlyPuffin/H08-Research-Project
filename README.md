# H08-Research-Project

A collection of coding work related to the H08 Water Resources Model.
Featured code was written by the author, Daniel Voss.

3 Resolutions were used (meter measurements at 34 degrees latitude):
HYO = 0.0083 x 0.0083 degrees (about 767.69m)
2ND = 0.0033 x 0.0033 degrees (about 307.08m)
HIRES = 0.00083 x 0.00083 degrees (about 76.77m)

# Files By Usage

Observation Data Processing
* Data acquired from the Japanese Ministry of Land, Infrastructure, Transport and Tourism
--run_folder.sh
--extract_means.py

* Optimization of old river routing algorithm (see River-Routing-Process-Time.jpg)
--calc_rivnxl_update.f

* Bash processes for upscaling resolution (using GMT)
--region_conversion.sh
--region_conversion_gl5.sh

* Files for computing hydro power potential (in order of use)
1. calc_usadis.sh (prep river flow data)
2. hydro.sh (Bash file for organizing input data, and settings)
3. hydro.f (Main Fortran Script)

* Comparing riverflow against observation data
--find_riv_data.sh
--prep_riv_data_all.sh
--batch_compute_riv_data.sh
--compute_coefficients_batch.py

* Comparing hydropower to the Japanese Ministry of the Environment's survey
--accuracy.sh
--accuracy.f
