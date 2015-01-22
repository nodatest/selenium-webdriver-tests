#!/bin/env ruby
# encoding: utf-8

require 'selenium-webdriver'
require_relative 'common.functions'

#Проверки на noindex
def formycarnoindexexistence(browser)

  #задаём адрес ссылки
  link = "http://4mycar.ru#{@lan.to_s}/parts/Febi/01089"

  #переходим по ссылке
  @driver.navigate.to link

  #проверяем наличие noindex в комментариях
=begin
  result = @driver.find_elements(:xpath, "//comment()[contains(.,'noindex')]").count
  puts result
=end

  #проверяем отсутствие noindex в результатах
  begin
    result = @driver.find_elements(:xpath, "//div[@id='searchResultsDiv']//noindex").nil?
  rescue
  end

  if !result then
    puts "#{time} test1: noindex в результатах нет"
  else
    puts "#{time} test1: Ошибка! noindex в результатах есть!"
  end
end



