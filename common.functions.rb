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
    opts.on('-b', '--browser NAME', 'set browser (chrome/firefox)') { |b| @options[:browser] = b }
    opts.on('-f', '--fullscreen', 'fullscreen mode') { |f| @options[:fullscreen] = f }
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--name NAME', 'test name') { |n| @options[:name] = n }
  end.parse!

  @lan = '.lan' if @options[:lan]

  #задаём массив браузеров в зависимости от переданного параметра -b
  case @options[:browser]
    when 'chrome'
      @browser = %w(chrome)
    when 'firefox'
      @browser = %w(firefox)
    else
      if @options[:name]
        @browser = %w(chrome)
      else
        @browser = %w(chrome firefox)
      end
  end
end

#функция проверки параметров запуска тестов в одном бразуере и запуска бразуера в полнооконном режиме
# + включения логирования в файл
def checkparametersandlog(browser)
  #если НЕ установлен параметр запуска тестов в одном бразуере
  startBrowser(browser) if !@options[:aio]

  #если установлен параметр запуска бразуера в полнооконном режиме
  @driver.manage.window.maximize if @options[:fullscreen]

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
end

#функция запуска браузера
def startBrowser(browser)
  puts browser
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds
  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
end