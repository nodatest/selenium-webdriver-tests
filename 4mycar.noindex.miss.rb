#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'
require_relative 'service.sites.noindex.existence'

#Проверка 4mycar на отсутствие noindex
def formycar_noindex_miss(browser, sites = @sites, pages = @pages)

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #запускаем браузер
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @client.timeout = 120 # seconds
    @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  end

  #если установлен параметр запуска бразуере в полнооконном режиме
  if @options[:fullscreen].nil? == false
    #делаем окно браузера на весь экран
    @driver.manage.window.maximize
  end

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')

  for index2 in 0 ... pages.size
    #задаём адрес ссылки
    puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: задаём адрес ссылки"
    link = "http://#{sites[0]}#{@lan.to_s}/?#{pages[index2]}"
    #переходим по ссылке
    puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: переходим по ссылке #{link}"
    @driver.navigate.to link
    #удаляем все куки
    puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: удаляем все куки"
    @driver.manage.delete_all_cookies
    #проверяем отсутствие noindex, nofollow на странице
    puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: проверяем наличие noindex, nofollow на странице"
    result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
    if result == 0 then
      puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: noindex [4mycar] отсутствует"
    else
      puts "#{time} Проверка отсутствия noindex, nofollow на страницах 4mycar: Ошибка! noindex [4mycar] присутствует!"
    end

    #закрываем файл лога
    $stdout.flush
  end

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end