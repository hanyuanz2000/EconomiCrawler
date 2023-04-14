# Scrape Economists Articles with Scrapy
This project involves web scraping articles from The Economists, 
with a focus on various search queries such as 'sequoia capital'. 
To achieve this, we employ individual spiders for each search query. 
Additionally, consider the article releasing frequency in The Economists, 
we decide to keep our search results up-to-date on a 30-days basis, 
meaning that the spider will stop searching once it reaches the first article 
published over 30 days ago, and return from the parse function.

## Some Notes before running the spider
1. Scrapy processes requests asynchronously, which means that the order in which the output file 
is written may not correspond to the order in which the links appear on the webpage. 
If you need to use the scraped data in time order, 
you may need to perform additional sorting or ordering in the output database.

## Explanation on Spiders
### sequoia_capital.py
You can check the code [here](./scrape_economist/spiders/sequoia_capital.py). 
Our spider aims to gather the latest articles regarding sequoia capital. 
Fortunately, the website features a "sort by date" button that we can use. 
Upon clicking it, we observed that the only modification to the URL is the addition of "&sort=date" at the end. 
As a result, we made a simple adjustment to the start URL, which is now: 
https://www.economist.com/search?q=sequoia+capital&sort=date.

One issue we are facing is that when we execute requests in the Scrapy shell, we successfully obtain the
desired content. However, when we use a spider, we run into a `DEBUG: Forbidden by robots.txt` error. 
We believe this may be due to the fact that the Scrapy shell doesn't store cookies or sessions between requests,
while a spider does. As a result, we have decided to try disabling the COOKIES_ENABLED setting
in the spider's settings by using the following command: 
`custom_settings = {'COOKIES_ENABLED': False,}`. However, this still doesn't work. 

So we decide to modify the settings.py by adding: `ROBOTSTXT_OBEY = False`. However, we need to be 
cautious while using this setting and ensure you are respecting the website's terms of service and privacy policies.


## How to Run Spiders and Store the scraping results in Different Locations?
### Store Locally
On certain occasions, we may need to perform local testing and store the scraped data locally. 
To accomplish this, we can execute a command in the terminal, such as the following:

`scrapy crawl sequoia_capital -o output_data/sequoia_capital.csv`

By running this command, we can run the spider named "sequoia_capital"
and store the scraped data in the "output_data" folder.

We can check the demo output [here](./output_data/sequoia_capital.csv). 
Since the relevant articles in The Economists doesn't update very frequently, 
I collect all articles related to sequoia capital within 1000 days before Apr 13 2023 by modifying the line to

`if now_aware - article_date <= timedelta(days=1000)` 

in the [sequoia_capital.py](./scrape_economist/spiders/sequoia_capital.py). Of course, if we want to update our database
in a monthly basis later, we can modify above line back to 

`if now_aware - article_date <= timedelta(days=30)`.

## Make Spider Run on a weekly basis
1. Open 

##