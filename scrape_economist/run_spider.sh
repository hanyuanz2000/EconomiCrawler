#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
EMAIL="hanyuanz2000@gmail.com"
SUBJECT="weekly scraping shell script output"
LOGFILE="/Users/zhanghanyuan/PycharmProjects/scrape_economist/logs/logfile-${TIMESTAMP}.log"

# Source system-wide environment variables
# Ensures the script has access to the same settings as your terminal session.
source /etc/profile

# Source user-specific environment variables
# ensures the script gains access to the user's custom settings and environment variables
source ~/.bashrc
# ensures that your script has access to the user's settings
source ~/.bash_profile

# Source the env.sh file containing the environment variables for MongoDB Atlas
source /Users/zhanghanyuan/PycharmProjects/scrape_economist/env.sh

# Log the start of the script execution
echo "$(date) - Script started" >> "$LOGFILE"

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
scrapy_project_dir="/Users/zhanghanyuan/PycharmProjects/scrape_economist"

# Change to the Scrapy project directory
cd "$scrapy_project_dir" || { echo "Error: Failed to change to Scrapy project directory."; exit 1; }

# Define a function to run a Scrapy spider and log its output
run_spider() {
    spider_name=$1
    LOGFILE=$2

    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting spider: $spider_name" >> "$LOGFILE"
    scrapy_output=$(scrapy crawl "$spider_name" --nolog -s LOG_LEVEL=ERROR 2>&1 | grep -E '^\[[0-9]+ [a-zA-Z]+\] (ERROR|INFO):')
    echo "$scrapy_output" >> "$LOGFILE"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Finished spider: $spider_name" >> "$LOGFILE"
}

# Run your Scrapy spiders
run_spider "sequoia_capital" "$LOGFILE"
echo " "
run_spider "Andreessen_Horowitz" "$LOGFILE"

# Log the end of the script execution
echo "$(date) - Script finished" >> "$LOGFILE"

# Check if the mail command is installed
if ! command -v mail &> /dev/null
then
    echo "mail command not found. Please install mailutils or similar package."
    exit 1
fi

# Send the log file contents via email
# shellcheck disable=SC2002
cat "$LOGFILE" | mail -s "$SUBJECT" "$EMAIL"

