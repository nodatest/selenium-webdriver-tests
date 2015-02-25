#!/bin/env ruby
# encoding: utf-8

#Проверки на noindex
def formycar_noindex_existence(browser)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка отсутствие noindex в результатах и наличия noindex в комментариях на 4mycar ====='.colorize(:green)

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
    @error += 1
  end

  @totalerrors += @errors #прибавляем кол-во ошибок к общему
  puts "info: тест завершён. кол-во ошибок - #{@errors}".colorize(:green)

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end