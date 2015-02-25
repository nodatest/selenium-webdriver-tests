#!/bin/env ruby
# encoding: utf-8

#Проверка 4mycar на отсутствие noindex
def formycar_noindex_miss(browser, sites = @sites, pages = @pages)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка отсутствия noindex, nofollow на страницах 4mycar ====='.colorize(:green)

  begin
    puts "#{time} задаём адрес ссылки, переходим по ссылке, удаляем все куки, проверяем отсутствие noindex, nofollow на страницах"
    for index2 in 0 ... pages.size
      #задаём адрес ссылки
      link = "http://#{sites[0]}#{@lan.to_s}/?#{pages[index2]}"
      #переходим по ссылке
      @driver.navigate.to link
      #удаляем все куки
      @driver.manage.delete_all_cookies
      #проверяем отсутствие noindex, nofollow на странице
      begin
        result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
      rescue
        #noindex, nofollow на странице не найдены
      end
      if result > 0
        puts "#{time} Ошибка! noindex на #{link} присутствует #{result} раз(а)!".colorize(:red)
        @error += 1
      end
    end
  rescue
    @error += 1
  end

  countErrorsFlushLogBrowserQuit #подсчитываем ошибки, выводим их, скидываем записи в лог, выходим из браузера, если надо
end