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

def startTest(number, browser)

  #проверяем указан ли браузер
  if browser == nil
    browser = 'chrome'
  end

  if @options[:browser].to_s.nil? == true
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @client.timeout = 120 # seconds
    @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  end

  #вызываем нужный номер теста и нужный браузер
  send("test#{number}".to_sym, browser)

  #закрываем файл лога
  $stdout.flush

  #выходим из браузера
  if @options[:browser].to_s.nil? == true
    @driver.quit
  end
end

#параметры в командной строке
def options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'

    opts.on('-a', '--all-tests-in-one-browser', 'all tests in one browser') { |a| @options[:aio] = a }
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--number N', 'test number') { |n| @options[:number] = n }
  end.parse!

  if @options[:lan] == false
    @lan = '.lan'
  end
end