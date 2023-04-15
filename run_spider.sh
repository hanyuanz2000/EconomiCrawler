#!/bin/bash
cd "$(dirname "$0")"

# Activate the conda environment
source /Users/zhanghanyuan/opt/anaconda3/bin/activate my_scrapy_venv
conda activate myenv

# Run the spider
scrapy crawl sequoia_capital

# Deactivate the conda environment
conda deactivate