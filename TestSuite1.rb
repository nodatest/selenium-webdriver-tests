require 'selenium-webdriver'
require_relative 'common.functions'
require_relative '4mycar.no.redirect.and.available.results'
require_relative '4mycar.noindex.existence'
require_relative '4mycar.noindex.miss'
require_relative 'service.sites.noindex.existence'
require_relative 'create.franchisee'
require_relative 'gk.order'
require_relative 'franchisee.order'
require_relative 'place.order.from.franch.to.gk'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

#обрабатываем параметры командной строки
options

#если задано имя функции теста
if @options[:name]
  #игнорируем параметр запуска тестов в одном бразуере
  @options[:aio] = false

  #если установлен параметр запуска тестов в одном бразуере
  startBrowser(@browser[0]) if @options[:aio]

  #выполняем тест
  send("#{@options[:name]}".to_sym, @browser[0])

  #если установлен параметр запуска тестов в одном бразуере
  @driver.quit if @options[:aio]
else
  loop {
    for i in 0 ... @browser.size

      #если установлен параметр запуска тестов в одном бразуере
      startBrowser(@browser[i]) if @options[:aio]

      #выполняем тесты
      #formycar_noindex_existence(@browser[i])
      #formycar_no_redirect_and_available_results(@browser[i])
      #service_sites_noindex_existence(@browser[i])
      #formycar_noindex_miss(@browser[i])

      createFranchisee(@browser[i])
      gkOrder(@browser[i])
      franchiseeOrder(@browser[i])
      placeOrderFromFranchToGk(@browser[i])

      #если установлен параметр запуска тестов в одном бразуере
      @driver.quit if @options[:aio]
    end

    #ждём 1 час
    sleep 3600
  }
end