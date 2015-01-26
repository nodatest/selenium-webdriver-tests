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
  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/chrome_#{date}.txt", 'a')
  #запускаем браузер
  seleniumdriver(browsers[0])
  #выполняем тест
  send("#{@options[:name]}".to_sym)
  #выходим из браузера
  @driver.quit
else
  loop {
    for i in 0 ... browsers.size

      #если установлен параметр запуска тестов в одном бразуере
      if @options[:aio] == true
        #запускаем браузер
        seleniumdriver(browsers[i])
      end

      #выполняем тесты

      #запускаем браузер и включаем логирование
      initializebrowserandlog(browsers[i])
      formycar_noindex_existence
      #выходим из браузера
      brwoserquit
      #запускаем браузер и включаем логирование
      initializebrowserandlog(browsers[i])
      formycar_no_redirect_and_available_results
      #выходим из браузера
      brwoserquit
      #запускаем браузер и включаем логирование
      initializebrowserandlog(browsers[i])
      service_sites_noindex_existence
      #выходим из браузера
      brwoserquit
      #запускаем браузер и включаем логирование
      initializebrowserandlog(browsers[i])
      formycar_noindex_miss
      #выходим из браузера
      brwoserquit

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