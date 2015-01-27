require 'selenium-webdriver'
require_relative '4mycar.no.redirect.and.available.results'
require_relative '4mycar.noindex.existence'
require_relative '4mycar.noindex.miss'
require_relative 'service.sites.noindex.existence'
require_relative 'common.functions'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

#обрабатываем параметры командной строки
options

#задаём массив браузеров
browsers = %w(chrome firefox)
#если задано имя функции теста
if @options[:name].nil? == false
  #если установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == false
    #запускаем браузер
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @client.timeout = 120 # seconds
    @driver = Selenium::WebDriver.for(:"#{browsers[0]}", :http_client => @client)
  end
  #выполняем тест
  send("#{@options[:name]}".to_sym, "#{browsers[0]}")
  #если установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == false
    #выходим из браузера
    @driver.quit
  end
else
  loop {
    for i in 0 ... browsers.size

      #если установлен параметр запуска тестов в одном бразуере
      if @options[:aio] == true
        #запускаем браузер
        @client = Selenium::WebDriver::Remote::Http::Default.new
        @client.timeout = 120 # seconds
        @driver = Selenium::WebDriver.for(:"#{browsers[i]}", :http_client => @client)
      end

      #выполняем тесты
      formycar_noindex_existence(browsers[i])
      formycar_no_redirect_and_available_results(browsers[i])
      service_sites_noindex_existence(browsers[i])
      formycar_noindex_miss(browsers[i])

      #если установлен параметр запуска тестов в одном бразуере
      if @options[:aio] == true
        #выходим из браузера
        @driver.quit
      end
    end

    #ждём 1 час
    sleep 3600
  }
end