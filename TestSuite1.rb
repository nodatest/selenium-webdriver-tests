#!/bin/env ruby
# encoding: utf-8

load 'test1'
load './test2'
load './test3-4'
load './common.functions'

require "selenium-webdriver"

#выводим ошибки ruby в файл
$stderr = File.open("../selenium-webdriver-logs/!errors_log.txt", "w")

def chooseBrowser(ver)
@client = Selenium::WebDriver::Remote::Http::Default.new
@client.timeout = 120 # seconds
@driver = Selenium::WebDriver.for(:"#{ver}", :http_client => @client)

#лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{ver}_#{date}.txt", "a")

test1()

test2()

#test3()

#test4()

#закрываем файл лога
  $stdout.flush

@driver.quit
end

#таймер
loop {
    #запускаем chrome
    chooseBrowser('chrome')
    #запускаем firefox
    chooseBrowser('firefox')
    #ждём 1 час
    sleep 3600
}