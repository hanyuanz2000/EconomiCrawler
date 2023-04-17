#!/bin/bash

# Specify the Conda environment name
conda_env_name="my_scrapy_venv"

# Check if the Conda command is available
if ! command -v conda &> /dev/null
then
    echo "Conda could not be found"
    exit
fi

# Activate the Conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $conda_env_name

# Define the path to the Scrapy project directory
scrapy_project_dir=".."

# Change to the Scrapy project directory
cd "$scrapy_project_dir" || { echo "Error: Failed to change to Scrapy project directory."; exit 1; }

scrapy crawl sequoia_capital
scrapy crawl Andreessen_Horowitz

