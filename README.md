# Examining Housing Choice Voucher (Section 8) in Delaware

This repo contains all scripts and documentation related to out exploratory work on Housing Choice Voucher (Section 8) assistance eligibility across Delaware.

## Overview
[Housing Choice Voucher (Section 8)](https://www.hud.gov/topics/housing_choice_voucher_program_section_8) provides housing for families in a housing crisis in the US. However, the program struggles to provide vouchers to most qualified families. We built this app to help people learn how well the program is doing in Delaware.

We draw data from [HUD](https://www.huduser.gov/portal/datasets/assthsg.html) and [ACS](https://www.census.gov/programs-surveys/acs).

We make the source code of this app publicly available, so that we can allow anyone to see how we source data and report findings. Please feel free to submit an issue. 


## App

-   The main branch is deployed at <https://techimpact.shinyapps.io/housing-voucher>
-   The explore page is directly accessible with this URL: <https://techimpact.shinyapps.io/housing-voucher/?page=explore>

### Test App

-   Each pull request is deployed at <https://techimpact.shinyapps.io/housing-voucher-test>
-   The explore page: <https://techimpact.shinyapps.io/housing-voucher-test/?page=explore>

## Project Structure

    voucher-eligibility/
    ├─ data/
    │  ├─ raw/
    │  ├─ processed/
    ├─ docs/ # EDA is hosted here as a GitHub page
    ├─ src/ # Source code (mainly .R files)
    ├─ app/ # Shiny app 

## Environment Variables

### .Renviron

-   `CENSUS_API_KEY`: API key to the Census API

For deployment to Shinyapps.io:

-   `SHINY_ACC_NAME`: Account name on shiny
-   `TOKEN`: Token from Shiny
-   `SECRET`: Secret from shiny
-   `MASTERNAME`: Name of shiny app on main
-   `TESTNAME`: Name of shiny app on pull request

### .Rprofile

There are two `.Rprofile` files in this repository

1.  Root folder - a dummy file that loads the `.Rprofile` file in the app folder. This file will be loaded when opening the `.Rproj` file on RStudio.
2.  `app/` - the actual `.Rprofile` file that sets up the environment for Python. This folder is being deployed to the shinyapps.io. And thus, the real `.Rprofile` file will be loaded there as well.

The `.Rprofile` file sets the following environment variables:

-   `VIRTUALENV_NAME` : Name for the virtual environment (default: `voucher-eligibility-env`)

-   `PYTHON_PATH` : $PATH to python (the script will look for `python` on Windows, and `python3` on Mac)

-   `RETICULATE_PYTHON` : Path to python. The value is set only for shinyapps. On local, RStudio takes care of setting this value automatically and thus the scripts leaves it blank.
