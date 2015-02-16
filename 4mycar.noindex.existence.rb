#!/bin/env ruby
# encoding: utf-8

#Проверки на noindex
def formycar_noindex_existence(browser)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar ====='

  #задаём адрес ссылки
  puts "#{time} задаём адрес ссылки"
  link = "http://4mycar.ru#{@lan.to_s}/parts/Febi/01089"

  #переходим по ссылке
  @driver.navigate.to link
  puts "#{time} переходим по ссылке #{link}"

  #проверяем наличие noindex в комментариях
=begin
  result = @driver.find_elements(:xpath, "//comment()[contains(.,'noindex')]").count
  puts result
=end

  #проверяем отсутствие noindex в результатах
  puts "#{time} проверяем отсутствие noindex в результатах"
  begin
    result = !@driver.find_elements(:xpath, "//div[@id='searchResultsDiv']//noindex")
  rescue
    puts "#{time} Ошибка! noindex в результатах есть!"
  end

  if !result
    puts "#{time} noindex в результатах нет"
  end

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end