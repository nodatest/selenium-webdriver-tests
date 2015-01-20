require 'selenium-webdriver'
require_relative 'test1'
require_relative 'test2'
require_relative 'test3'
require_relative 'test4'
require_relative 'common.functions'
require 'optparse'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

#обрабатываем параметры командной строки
options

if @options[:number].nil? == false
  startTest(@options[:number], 'chrome')
else
  loop {
    if @options[:aio].to_s.nil? == false
      @client = Selenium::WebDriver::Remote::Http::Default.new
      @client.timeout = 120 # seconds
      browser = 'chrome'
      @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
    end

    #тесты в хроме
    startTest(1, 'chrome')
    startTest(2, 'chrome')
    startTest(3, 'chrome')
    startTest(4, 'chrome')

    #выходим из браузера
    if @options[:aio].to_s.nil? == false
      @driver.quit
    end

    if @options[:aio].to_s.nil? == false
      @client = Selenium::WebDriver::Remote::Http::Default.new
      @client.timeout = 120 # seconds
      browser = 'firefox'
      @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
    end

    #тесты в firefox
    startTest(1, 'firefox')
    startTest(2, 'firefox')
    startTest(3, 'firefox')
    startTest(4, 'firefox')

    #выходим из браузера
    if @options[:aio].to_s.nil? == false
      @driver.quit
    end

    #ждём 1 час
    sleep 3600
  }
end
