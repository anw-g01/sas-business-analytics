# SAS Business Analytics Case Study
This repository contains a SAS case study project with a modular workflow for data preparation and analytics reporting.

## Repository Structure

### Execution Scripts
- `autoexec.sas`: Sets all library references and environment paths. Run first by changing the `ROOT` directory macro variable.
- `control.sas`: Main program that sequentially runs all required programs within `programs/`.

### Project Directories
- `programs/`: Core SAS workflow programs for import, cleaning, preparation, and analytics/reporting steps.
- `macros/`: Reusable SAS helper macros used by workflow programs.
- `formats/`: SAS format definitions and stored format catalog used during processing.
- `reports/`: Generated PDF report outputs of key summary tables produced during project execution.
- `python/`: Jupyter notebooks, data extracts, and chart images for visualisation.

## Run the Project
1. Open `autoexec.sas` and update the project root directory path for your local environment.
2. Run `autoexec.sas` to initialise all SAS libraries and environment settings.
3. Run `control.sas` to execute the complete project workflow.