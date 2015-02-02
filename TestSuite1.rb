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

#если задано имя функции теста
if @options[:name]
  #игнорируем параметр запуска тестов в одном бразуере
  @options[:aio] = false

  #выполняем тест
  send("#{@options[:name]}".to_sym, @browser[0])
else
  loop {
    for i in 0 ... @browser.size

      #если установлен параметр запуска тестов в одном бразуере
      startBrowser(@browser[i]) if @options[:aio]

      #выполняем тесты
      formycar_noindex_existence(@browser[i])
      formycar_no_redirect_and_available_results(@browser[i])
      service_sites_noindex_existence(@browser[i])
      formycar_noindex_miss(@browser[i])

      #если установлен параметр запуска тестов в одном бразуере
      @driver.quit if @options[:aio]
    end

    #ждём 1 час
    sleep 3600
  }
end