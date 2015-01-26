#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'

#Нет редиректа, доступны результаты
def formycar_no_redirect_and_available_results

  #задаём адрес ссылки
  puts 'задаём адрес ссылки'
  link = "http://4mycar.ru#{@lan.to_s}/parts/Liqui%20moly/3970"

  #переходим по ссылке
  puts 'переходим по ссылке'
  @driver.navigate.to link

  #проверяем, что нет редиректа
  puts 'проверяем, что нет редиректа'
  if @driver.current_url == link then
    puts "#{time} test2: Редиректа нет"
  else
    puts "#{time} test2: Ошибка! Редирект есть!"
  end

  #проверяем наличие на странице результатов
  puts 'проверяем наличие на странице результатов'
  begin
    result = @driver.find_element(:id, 'searchResultsDiv').nil?
  rescue
  end

  if (!result) then
    puts "#{time} test2: Результаты есть"
  else
    puts "#{time} test2: Ошибка! Результатов нет!"
  end

  #закрываем файл лога
  $stdout.flush
end