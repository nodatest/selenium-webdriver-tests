#!/bin/env ruby
# encoding: utf-8

#Проверки на noindex
def formycar_noindex_existence(browser)

  @name = 'Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    #задаём адрес ссылки
    puts "#{time} задаём адрес ссылки"
    link = "http://4mycar.ru#{@lan.to_s}/parts/Febi/01089"

    #переходим по ссылке
    @driver.navigate.to link
    puts "#{time} переходим по ссылке #{link}"

    #проверяем наличие noindex в комментариях
    result = @driver.find_elements(:xpath, "//*[comment()[contains(.,'noindex')]]").count
    if result == 2
      puts "#{time} noindex в комментариях встречается 2 раза"
    else
      puts "#{time} Ошибка! noindex в комментариях встречается не 2 раза, а #{result} раз(а)".colorize(:red)
      @error += 1
    end

    #проверяем отсутствие noindex в результатах
    puts "#{time} проверяем отсутствие noindex в результатах"
    result = @driver.find_elements(:xpath, "//*[@id='searchResultsDiv']//noindex").count
    if result > 0
      puts "#{time} Ошибка! noindex в результатах есть!".colorize(:red)
      @error += 1
    else
      puts "#{time} noindex в результатах нет"
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end