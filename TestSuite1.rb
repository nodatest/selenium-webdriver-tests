#!/bin/env ruby
# encoding: utf-8

require 'selenium-webdriver'
require 'colorize'
require_relative 'system.functions'
require_relative 'common.functions'
require_relative '4mycar.no.redirect.and.available.results'
require_relative '4mycar.noindex.existence'
require_relative '4mycar.noindex.miss'
require_relative 'service.sites.noindex.existence'
require_relative 'create.franchisee'
require_relative 'gk.order'
require_relative 'franchisee.order'
require_relative 'place.order.from.franch.to.gk'
require_relative 'post.actions'
require_relative 'market.email.notifications.for.comments'
require_relative '4mycar.order'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

@resellername='selenium.noda.pro'

#обрабатываем параметры командной строки
options

#если задано имя функции теста
if @options[:name]
  @totalerrors = 0 #задаём кол-во ошибок в начале выполнения тестового набора

  #игнорируем параметр запуска тестов в одном бразуере
  @options[:aio] = false
  puts "info: запускаем конкретный тест".colorize(:blue)

  #если установлен параметр запуска тестов в одном бразуере
  startBrowser(@browser[0]) if @options[:aio]

  #выполняем тест
  send("#{@options[:name]}".to_sym, @browser[0])

  #если установлен параметр запуска тестов в одном бразуере
  @driver.quit if @options[:aio]
  puts "info: единственный тест выполнен. кол-во ошибок - #{@totalerrors}".colorize(:blue)
else
  loop {
    for i in 0 ... @browser.size

      @totalerrors = 0 #задаём кол-во ошибок в начале выполнения тестового набора
      puts 'info: тестовый набор запущен'.colorize(:blue)

      if @options[:aio]
        puts 'info: тесты выполняются в одном браузере'
      else
        puts 'info: каждый тест в отдельном браузере'
      end

      if @options[:lan]
        puts 'info: локальный запуск'
      else
        puts 'info: нелокальный запуск'
      end

      puts 'info: во весь экран' if @options[:fullscreen]

      puts "info: используемый бразуер: #{@browser[i]}" unless @options[:name]

      #если установлен параметр запуска тестов в одном бразуере
      startBrowser(@browser[i]) if @options[:aio]

      #выполняем тесты

      formycar_order(@browser[i])

      market_email_notifications_for_comments(@browser[i])

      formycar_noindex_existence(@browser[i])
      formycar_no_redirect_and_available_results(@browser[i])
      service_sites_noindex_existence(@browser[i])
      formycar_noindex_miss(@browser[i])

      createFranchisee(@browser[i])
      gkOrder(@browser[i])
      franchiseeOrder(@browser[i])
      placeOrderFromFranchToGk(@browser[i])

      #если установлен параметр запуска тестов в одном бразуере
      @driver.quit if @options[:aio]
      puts "info: тестовый набор выполнен, кол-во ошибок - #{@totalerrors}".colorize(:blue)
    end

    postActions(@browser[0]) #выполняем пост-действия
    puts 'ждём 1 час...'
    #ждём 1 час
    sleep 3600
  }
end