# Scrape Economists Articles with Scrapy
This project involves web scraping articles from The Economists, 
with a focus on various search queries such as 'sequoia capital'. 
To achieve this, we employ individual spiders for each search query. 
Additionally, consider the article releasing frequency in The Economists, 
we decide to keep our search results up-to-date on a weekly basis, 
meaning that the spider will stop searching once it reaches the first article 
published over 7 days ago, and return from the parse function.

## 1 Some Notes before running the spider
1. Scrapy processes requests asynchronously, which means that the order in which the output file 
is written may not correspond to the order in which the links appear on the webpage. 
If you need to use the scraped data in time order, 
you may need to perform additional sorting or ordering in the output database.

## 2 Explanation on Spiders

The spiders form the foundation of a scrapy project and reside in the [./scrape_economist/spiders](./scrape_economist/spiders) directory. 
These spiders allow us to tailor our web scraping approach for each website.
A specific spider, sequoia_capital.py, will be elaborated on as an example.

### sequoia_capital.py
We use crawl template here, which provides additional functionality 
for more advanced crawling scenarios, such as following links and applying rules for URL extraction. 
To create this spider, we can simply write: 
`scrapy genspider -t crawl sequoia_capital www.economist.com` 
in the command line. 
If we provides full url in the first place like: 
` scrapy genspider -t crawl Andreessen_Horowitz ‘www.economist.com/search?q=sequoia+capital&sort=date`, 
we may encounter an error because of the special characters in the URL.

After creating the spider, we can edit the start_urls attribute in the generated Python file
to include the search URL with the query parameters.


You can check the code [here](./scrape_economist/spiders/sequoia_capital.py). 
Our spider aims to gather the latest articles regarding sequoia capital. 
Fortunately, the website features a "sort by date" button that we can use. 
Upon clicking it, we observed that the only modification to the URL is the addition of "&sort=date" at the end. 
As a result, we made a simple adjustment to the start URL, which is now: 
https://www.economist.com/search?q=sequoia+capital&sort=date.

One issue we are facing is that when we execute requests in the Scrapy shell, we successfully obtain the
desired content. However, when we use a spider, we run into a `DEBUG: Forbidden by robots.txt` error. 
At first we thought this may be due to the fact that the Scrapy shell doesn't store cookies or sessions between requests,
while a spider does. As a result, we have decided to try disabling the COOKIES_ENABLED setting
in the spider's settings by using the following command: 
`custom_settings = {'COOKIES_ENABLED': False,}`. However, this doesn't work. 

So we decide to modify the settings.py by adding: `ROBOTSTXT_OBEY = False`. However, we need to be 
cautious while using this setting and ensure you are respecting the website's terms of service and privacy policies.
You can try different approaches to solve this problem in your own spiders.

## 3 How to Run Spiders and Store the scraping results in Different Locations?
The storage location of the web scraping output can be determined based on the size of the results; 
it can either be stored locally or in the cloud.

### Store Scraping Results Locally
On certain occasions, we may need to perform local testing and store the scraped data locally. 
To accomplish this, we can execute a command in the terminal, such as the following:

`scrapy crawl sequoia_capital -o output_data/sequoia_capital.csv`

By running this command, we can run the spider named "sequoia_capital"
and store the scraped data in the "output_data" folder. I will explain the output_data folder more in next section.

### Store the Scraping Results in Cloud Database
If we want to store data remotely, we need to modify the [pipeline.py](./scrape_economist/pipelines.py)
 and [settings.py](./scrape_economist/settings.py).

#### pipelines.py
For instance, if we want to store our scraping results in Mongodb, 
we can implement a class `MongodbPipeline`. Inside this class, 
we implement 3 functions:  `open_spider()` (which runs before spider starts); 
`close_spider()` (which runs after spider starts);
`process_item()` (which load output to the Mongodb cloud).
As we can see from the code, the output will be stored at My_database.Economist
directory in the cloud. 

#### settings.py
In order to save the output obtained from sequoia_capital.py to the Mongodb cloud, 
it is also necessary to both comment out the line containing "ITEM_PIPELINES" 
in the file and modify it to 
"ITEM_PIPELINES = {"scrapy_trial.pipelines.MongodbPipeline": 300, },"
so that it matches the class name in pipelines.py.

#### In Mongodb cloud
This is a demonstration of the way data is stored in a MongoDB cloud database:
![alt text](Images_for_Readme/Mongodb.png)


## 4 Local Output Demo

Within the [output_data](./output_data) directory, a few sample web scraping outputs have been stored. 
As an example, the scraping results for Sequoia Capital in CSV format can be accessed [here](./output_data/sequoia_capital.csv). 
This CSV file contains four columns:

```csv
article release date, query key, title, content, url
```
In this context, the term "release date" refers to the date on which the article is published in The Economist. 
The "query key" denotes the search query utilized during web scraping to retrieve information related to an investor's name. 
The "title" pertains to the title of the article, while the "content" refers to the complete article text. 
Lastly, the "url" indicates the web address where the article is located.

As the articles relevant to Sequoia Capital in The Economist are not updated frequently, 
for the purposes of this demonstration CSV file, 
I have gathered all articles related to Sequoia Capital published within 365 days 
before April 17, 2023, by altering the following line in [sequoia_capital.py](./scrape_economist/spiders/sequoia_capital.py):

`if now_aware - article_date <= timedelta(days=365)` 

Naturally, if we wish to update our database on a weekly basis in the future, 
we can revert the aforementioned line back to:

`if now_aware - article_date <= timedelta(days=7)`.

## 5 Automatically Running Spiders
To automate the execution of our spider and update our database on a weekly basis, 
we can use a combination of a shell script and the Cron job scheduler.

### Shell Script
I store all my Shell Scripts inside the 
[scrape_economist/shell_script_for_running_spider](scrape_economist/shell_script_for_running_spider) folder.
Essentially, it enables the desired conda environment and 
then executes various spiders within that environment.
To execute the script, navigate to its directory and enter the command `bash run_spider





