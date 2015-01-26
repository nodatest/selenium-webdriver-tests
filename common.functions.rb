#!/bin/env ruby
# encoding: utf-8
require 'optparse'

#время начала выполнения теста
def time()
  time = Time.now.strftime('%d-%m-%Y %H-%M-%S')
end

#дата
def date
  date = time[0, 10]
end

#параметры в командной строке
def options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'

    opts.on('-a', '--all-tests-in-one-browser', 'all tests in one browser') { |a| @options[:aio] = a }
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--name NAME', 'test name') { |n| @options[:name] = n }
    opts.on('-f', '--fullscreen', 'fullscreen mode') { |m| @options[:fullscreen] = m }
  end.parse!

  if @options[:lan] == true
    @lan = '.lan'
  end
end

#функция включения логирование в файл и проверки условия, при котором происходит запуск браузера
def initializebrowserandlog(browser)

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #запускаем браузер
    seleniumdriver(browser)
  end

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
end

#инициализируем запуск браузера
def seleniumdriver(browser)
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds
  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  #если установлен параметр запуска бразуере в полнооконном режиме
  if @options[:fullscreen].nil? == false
    #делаем окно браузера на весь экран
    @driver.manage.window.maximize
  end
end

#функция проверки условия, при котором происходит выход из браузера
def brwoserquit
  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end