#!/bin/env ruby
# encoding: utf-8

load 'test1'
load './test2'
load './test3-4'
load './common.functions'

require "selenium-webdriver"
@client = Selenium::WebDriver::Remote::Http::Default.new
@client.timeout = 120 # seconds
@driver = Selenium::WebDriver.for(:chrome, :http_client => @client) #chrome

puts time+" ----- Chrome -----"

#test1()

test2()

test3()

test4()

@driver.quit


@client = Selenium::WebDriver::Remote::Http::Default.new
@client.timeout = 120 # seconds
@driver = Selenium::WebDriver.for(:ff, :http_client => @client) #firefox

puts time+" ----- Firefox -----"

#test1()

test2()

test3()

test4()

@driver.quit