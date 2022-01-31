# Examining Housing Choice Voucher (Section 8) in Delaware
This repo contains all scripts and documentation related to out exploratory work on Housing Choice Voucher (Section 8) assistance eligibility across Delaware.

## App

The development version of the app is available at: https://nami-techimpact.shinyapps.io/housing-voucher/

Each pull request will be deployed at:
https://nami-techimpact.shinyapps.io/housing-voucher-test

## Project Structure

```
voucher-eligibility/
├─ data/
│  ├─ raw/
│  ├─ processed/
├─ docs/ # EDA is hosted here as a GitHub page
├─ src/ # Source code (mainly .R files)
├─ app/ # Shiny app 
```

## Environmental Variables

- `CENSUS_API_KEY`: API key to the Census API

For deployment to Shinyapps.io:
- `SHINY_ACC_NAME`: Account name on shiny
- `TOKEN`: Token from Shiny
- `SECRET`: Secret from shiny
- `MASTERNAME`: Name of shiny app on main
- `TESTNAME`: Name of shiny app on pull request
