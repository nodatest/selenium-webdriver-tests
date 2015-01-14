#!/bin/env ruby
# encoding: utf-8

load 'test1'
load './test2'
load './test3-4'
load './common.functions'

require "selenium-webdriver"

def chooseBrowser(ver)
@client = Selenium::WebDriver::Remote::Http::Default.new
@client.timeout = 120 # seconds
@driver = Selenium::WebDriver.for(:"#{ver}", :http_client => @client)

puts time+" ----- "+ver+" -----"

#test1()

test2()

test3()

test4()

@driver.quit
end

#запускаем chrome
chooseBrowser('chrome')
#запускаем firefox
chooseBrowser('firefox')