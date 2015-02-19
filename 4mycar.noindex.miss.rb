#!/bin/env ruby
# encoding: utf-8

#Проверка 4mycar на отсутствие noindex
def formycar_noindex_miss(browser, sites = @sites, pages = @pages)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка отсутствия noindex, nofollow на страницах 4mycar ====='

  for index2 in 0 ... pages.size
    #задаём адрес ссылки
    puts "#{time} задаём адрес ссылки"
    link = "http://#{sites[0]}#{@lan.to_s}/?#{pages[index2]}"
    #переходим по ссылке
    puts "#{time} переходим по ссылке #{link}"
    @driver.navigate.to link
    #удаляем все куки
    puts "#{time} удаляем все куки"
    @driver.manage.delete_all_cookies
    #проверяем отсутствие noindex, nofollow на странице
    puts "#{time} проверяем отсутствие noindex, nofollow на странице"
    begin
    result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
    rescue
      puts "#{time} noindex [4mycar] отсутствует"
    end
    if result > 0
      puts "#{time} Ошибка! noindex [4mycar] присутствует!"
    end

    #скидываем данные в лог
    $stdout.flush
  end

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end