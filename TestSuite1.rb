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
if @options[:name]
  #игнорируем параметр запуска тестов в одном бразуере
  @options[:aio] = false

  #выполняем тест
  send("#{@options[:name]}".to_sym, browsers[0])
else
  loop {
    for i in 0 ... browsers.size

      #если установлен параметр запуска тестов в одном бразуере
      startBrowser(browsers[i]) if @options[:aio]

      #выполняем тесты
      formycar_noindex_existence(browsers[i])
      formycar_no_redirect_and_available_results(browsers[i])
      service_sites_noindex_existence(browsers[i])
      formycar_noindex_miss(browsers[i])

      #если установлен параметр запуска тестов в одном бразуере
      @driver.quit if @options[:aio]
    end

    #ждём 1 час
    sleep 3600
  }
end