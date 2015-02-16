#!/bin/env ruby
# encoding: utf-8

#Нет редиректа, доступны результаты
def formycar_no_redirect_and_available_results(browser)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка отсутствие редиректа и наличия на странице результатов на 4mycar ====='

  #задаём адрес ссылки
  puts "#{time} задаём адрес ссылки"
  link = "http://4mycar.ru#{@lan.to_s}/parts/Liqui%20moly/3970"

  #переходим по ссылке
  puts "#{time} переходим по ссылке #{link}"
  @driver.navigate.to link

  #проверяем, что нет редиректа
  puts "#{time} проверяем, что нет редиректа"
  if @driver.current_url == link then
    puts "#{time} Редиректа нет"
  else
    puts "#{time} Ошибка! Редирект есть!"
  end

  #проверяем наличие на странице результатов
  puts "#{time} проверяем наличие на странице результатов"
  begin
    result = !@driver.find_element(:id, 'searchResultsDiv')
  rescue
    puts "#{time} Ошибка! Результатов нет!"
  end

  puts "#{time} Результаты есть" if !result

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end