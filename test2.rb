#!/bin/env ruby
# encoding: utf-8

require 'selenium-webdriver'
require_relative 'common.functions'

#Нет редиректа, доступны результаты
def test2(ver)

  #задаём адрес ссылки
  link = 'http://4mycar.ru/parts/Liqui%20moly/3970'

  #переходим по ссылке
  @driver.navigate.to link

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{ver}_#{date}.txt", 'a')

  #проверяем, что нет редиректа
  if @driver.current_url == link then
    puts time+' test2: Редиректа нет'
  else
    puts time+' test2: Ошибка! Редирект есть!'
  end

  #проверяем наличие на странице результатов
  begin
    result = @driver.find_element(:id, 'searchResultsDiv').nil?
  rescue
  end

  if result == false then
    puts time+' test2: Результаты есть'
  else
    puts time+' test2: Ошибка! Результатов нет!'
  end
end

#запускаем себя
startTest(2, 'chrome')
startTest(2, 'firefox')