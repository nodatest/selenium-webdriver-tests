#!/bin/env ruby
# encoding: utf-8

#задаём массив сайтов
@sites = %w(4mycar.ru vmolchanov.abcp.ru training.noda.pro www.franch.abcp.ru www.mir.franch.abcp.ru)
#задаём массив страниц
@pages = %w(page=catalog page=catalog&man=16 page=catalog&man=16&model=6414 page=catalog&man=16&model=6414&modelVariant=31960 page=catalog&man=16&model=6414&modelVariant=31960&group=100384 search_type=&pcode=oc90 pbrandnumber=OC90&pbrandname=Knecht page=carbase page=carbase&manufacturerId=15 page=carbase&modelId=1207 page=carbase&modificationId=13073 page=goods_catalog&action=search&goods_group=tires page=goods_catalog&action=search&goods_group=disks page=goods_info&brand=ABT&number=FCR1985351257DM)

#Проверка сервисных cайтов на наличие noindex [tecdoc]
def service_sites_noindex_existence(browser, sites = @sites, pages = @pages)

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Проверка наличия noindex, nofollow на страницах сервисных сайтов ====='.colorize(:green)
  puts "#{time} задаём адрес ссылки, переходим по ссылке, удаляем все куки, проверяем наличие noindex, nofollow на страницах"

  for index1 in 1 ... sites.size
    for index2 in 0 ... pages.size
      #задаём адрес ссылки
      link = "http://#{sites[index1]}#{@lan.to_s}/?#{pages[index2]}"
      #переходим по ссылке
      @driver.navigate.to link
      #удаляем все куки
      @driver.manage.delete_all_cookies
      #проверяем наличие noindex, nofollow на странице
      begin
        result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
      rescue
        puts "#{time} Ошибка! noindex на #{link} отсутствует!".colorize(:red)
        @errors += 1
      end
      puts "#{time} Ошибка! noindex на #{link} встречается #{result} раз(а)!".colorize(:red) if result > 1

      #скидываем данные в лог
      $stdout.flush
    end
  end

  @totalerrors += @errors #прибавляем кол-во ошибок к общему
  puts "info: кол-во ошибок в тесте - #{@errors}"

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end