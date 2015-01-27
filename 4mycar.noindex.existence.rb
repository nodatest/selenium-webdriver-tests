#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'

#Проверки на noindex
def formycar_noindex_existence(browser)

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

  #задаём адрес ссылки
  puts "#{time} Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar: задаём адрес ссылки"
  link = "http://4mycar.ru#{@lan.to_s}/parts/Febi/01089"

  #переходим по ссылке
  @driver.navigate.to link
  puts "#{time} Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar: переходим по ссылке #{link}"

  #проверяем наличие noindex в комментариях
=begin
  result = @driver.find_elements(:xpath, "//comment()[contains(.,'noindex')]").count
  puts result
=end

  #проверяем отсутствие noindex в результатах
  puts "#{time} Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar: проверяем отсутствие noindex в результатах"
  begin
    result = @driver.find_elements(:xpath, "//div[@id='searchResultsDiv']//noindex").nil?
  rescue
  end

  if !result then
    puts "#{time} Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar: noindex в результатах нет"
  else
    puts "#{time} Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar: Ошибка! noindex в результатах есть!"
  end

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end



