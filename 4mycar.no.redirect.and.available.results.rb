#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'

#Нет редиректа, доступны результаты
def formycar_no_redirect_and_available_results(browser)

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
  puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: задаём адрес ссылки"
  link = "http://4mycar.ru#{@lan.to_s}/parts/Liqui%20moly/3970"

  #переходим по ссылке
  puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: переходим по ссылке #{link}"
  @driver.navigate.to link

  #проверяем, что нет редиректа
  puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: проверяем, что нет редиректа"
  if @driver.current_url == link then
    puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: Редиректа нет"
  else
    puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: Ошибка! Редирект есть!"
  end

  #проверяем наличие на странице результатов
  puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: проверяем наличие на странице результатов"
  begin
    result = @driver.find_element(:id, 'searchResultsDiv').nil?
  rescue
  end

  if (!result) then
    puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: Результаты есть"
  else
    puts "#{time} Проверка отсутствие редиректа и наличия на странице результатов на 4mycar: Ошибка! Результатов нет!"
  end

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end