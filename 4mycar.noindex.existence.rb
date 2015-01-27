#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'

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
    result = @driver.find_elements(:xpath, "//div[@id='searchResultsDiv']//noindex").nil?
  rescue
  end

  if !result then
    puts "#{time} noindex в результатах нет"
  else
    puts "#{time} Ошибка! noindex в результатах есть!"
  end

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end