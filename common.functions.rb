#!/bin/env ruby
# encoding: utf-8

#время начала выполнения теста
def time()
  time = Time.now.strftime('%d-%m-%Y %H-%M-%S')
end

#дата
def date
  date = time[0, 10]
end

def startTest(number, ver = nil)
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds

  #проверяем указан ли браузер
  if ver == nil then
    ver = 'chrome'
  end

  @driver = Selenium::WebDriver.for(:"#{ver}", :http_client => @client)

  #вызываем нужный номер теста и нужный браузер
  send("test#{number}".to_sym, ver)

  #закрываем файл лога
  $stdout.flush

  #выходим из браузера
  @driver.quit
end