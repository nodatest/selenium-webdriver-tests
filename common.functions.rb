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
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds

  #проверяем указан ли браузер
  if browser == nil
    browser = 'chrome'
  end

  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)

  #вызываем нужный номер теста и нужный браузер
  send("test#{number}".to_sym, browser)

  #закрываем файл лога
  $stdout.flush

  #выходим из браузера
  @driver.quit
end

#параметры в командной строке
def options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'

    opts.on('-b', '--browser NAME', 'browser') { |b| @options[:browser] = b }
    opts.on('-l', '--lan', 'lan') { |l| @options[:lan] = l }
    opts.on('-n', '--number N', 'test number') { |n| @options[:number] = n }
  end.parse!

  if @options[:lan] == true
    @lan = '.lan'
  end


end