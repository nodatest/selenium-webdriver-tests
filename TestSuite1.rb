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

#задаём массив браузеров
browsers = %w(chrome firefox)


if @options[:number].nil? == false
  startTest(@options[:number], 'chrome')
else
  loop {
    for i in 0 ... browsers.size
      if @options[:aio] == true
        @client = Selenium::WebDriver::Remote::Http::Default.new
        @client.timeout = 120 # seconds
        @driver = Selenium::WebDriver.for(:"#{browsers[i]}", :http_client => @client)
      end

      #запускаем тесты в различных браузерах
      startTest(1, browsers[i])
      startTest(2, browsers[i])
      startTest(3, browsers[i])
      startTest(4, browsers[i])

      #выходим из браузера
      if @options[:aio] == true
        @driver.quit
      end
    end
    #ждём 1 час
    sleep 3600
  }
end