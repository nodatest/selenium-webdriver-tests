#!/bin/env ruby
# encoding: utf-8

require 'selenium-webdriver'
require_relative 'common.functions'
require_relative 'test3'

#Проверка 4mycar на отсутствие noindex
def test4(sites = @sites, pages = @pages, browser)
  for index2 in 0 ... pages.size
    link = "http://#{sites[0]}#{@lan.to_s}/?#{pages[index2]}"
    #переходим по ссылке
    @driver.navigate.to link
    #удаляем все куки
    @driver.manage.delete_all_cookies
    #проверяем наличие noindex, nofollow на странице
    result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
    if (result == 0) then
      puts "#{time} test4: noindex [4mycar] отсутствует. ссылка: #{link}"
    else
      puts "#{time} test4: Ошибка! noindex [4mycar] присутствует. ссылка: #{link}"
    end
  end
end