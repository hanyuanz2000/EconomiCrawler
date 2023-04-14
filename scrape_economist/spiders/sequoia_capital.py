import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule
from dateutil.parser import parse, ParserError
from datetime import datetime, timedelta
import pytz


class SequoiaCapitalSpider(CrawlSpider):
    name = "sequoia_capital"
    allowed_domains = ["www.economist.com"]

    # define search query
    search_query = 'sequoia capital'

    # replace space with + to fit into url format
    search_query = search_query.replace(" ", "+")
    start_urls = [f"https://www.economist.com/search?q={search_query}&sort=date"]

    custom_settings = {
        'COOKIES_ENABLED': False,
    }

    rules = (
        # Rule to follow the links to the news articles
        Rule(LinkExtractor(restrict_xpaths="//li[@class='_result-item']/div/a"), callback="parse_item", follow=True),
        # Rule to follow the next page link
        Rule(LinkExtractor(restrict_xpaths="(//a[@rel='next'])[1]")),
    )

    def parse_item(self, response, rules=rules):
        date_string = response.xpath('//time/@datetime').get()

        try:
            article_date = datetime.strptime(date_string, '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=pytz.UTC)

        # it's possible for us to go to some page without article_date
        # for simplicity and avoid repeated record in our database, we choose to skip such item and move to next one
        except ParserError:
            # Handle the error
            self.logger.warning(f'Unable to parse date from: {date_string}')
            yield {}

        now = datetime.now()
        # Convert the timezone-naive datetime object to a timezone-aware one
        now_aware = now.replace(tzinfo=pytz.UTC)

        # Check if the article is within a year
        if now_aware - article_date <= timedelta(days=1000):
            # get title of article
            main_content = response.xpath('//main[@role="main"]')
            title = main_content.xpath('//h1/text()').get()

            # get content of news

            # the content of news is divided into many blocks
            # we collect them first and then join the strings together
            content_list = response.xpath('//p[@class="article__body-text"]/text()').getall()
            content = ''.join(content_list)

            yield {
                'date': article_date,
                'title': title,
                'content': content,
            }

        else:  # Stop following the next page link when the first article older than 365 days is found
            # Stop following the next page link when the first article older than a year is found
            rules = rules[:1]  # Keep only the first rule (to follow the news article links)
