# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
import pymongo
import os
from itemadapter import ItemAdapter
import logging


class ScrapeEconomistPipeline:
    def process_item(self, item, spider):
        return item


class MongodbPipeline:
    # this function run when spider starts
    collection_name = 'Economist'

    def __init__(self):
        # you can set env variable in your shell with: export MY_API_KEY="your_api_key_here"
        self.connection_code = os.environ.get('Mongodb_connection_code')
        # replace below line with self.connection_code = 'replace it with your Mongodb_connection_code in string
        # format' if you are using crontab job scheduler since it is unstable to have access to env variable even if
        # we add it in the shell script

    def open_spider(self, spider):
        self.client = pymongo.MongoClient(self.connection_code)
        self.db = self.client['My_Database']

    # this function run when spider ends
    def close_spider(self, spider):
        self.client.close()

    def process_item(self, item, spider):
        self.db[self.collection_name].insert(item)
        return item
