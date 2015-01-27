#!/bin/env ruby
# encoding: utf-8

require_relative 'common.functions'

#задаём массив сайтов
@sites = %w(4mycar.ru vmolchanov.abcp.ru training.noda.pro www.franch.abcp.ru www.mir.franch.abcp.ru)
#задаём массив страниц
@pages = %w(page=catalog page=catalog&man=16 page=catalog&man=16&model=6414 page=catalog&man=16&model=6414&modelVariant=31960 page=catalog&man=16&model=6414&modelVariant=31960&group=100384 search_type=&pcode=oc90 pbrandnumber=OC90&pbrandname=Knecht page=carbase page=carbase&manufacturerId=15 page=carbase&modelId=1207 page=carbase&modificationId=13073 page=goods_catalog&action=search&goods_group=tires page=goods_catalog&action=search&goods_group=disks page=goods_info&brand=ABT&number=FCR1985351257DM)

#Проверка сервисных cайтов на наличие noindex [tecdoc]
def service_sites_noindex_existence(browser, sites = @sites, pages = @pages)

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #запускаем браузер
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @client.timeout = 120 # seconds
    @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  end

  #если установлен параметр запуска бразуере в полнооконном режиме
  if @options[:fullscreen].nil? == false
    #делаем окно браузера на весь экран
    @driver.manage.window.maximize
  end

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')

  for index1 in 1 ... sites.size
    for index2 in 0 ... pages.size
      #задаём адрес ссылки
      puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: задаём адрес ссылки"
      link = "http://#{sites[index1]}#{@lan.to_s}/?#{pages[index2]}"
      #переходим по ссылке
      puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: переходим по ссылке #{link}"
      @driver.navigate.to link
      #удаляем все куки
      puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: удаляем все куки"
      @driver.manage.delete_all_cookies
      #проверяем наличие noindex, nofollow на странице
      puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: проверяем наличие noindex, nofollow на странице"
      result = @driver.find_elements(:xpath, "//meta[@name='robots' and @content='noindex, nofollow']").count
      if (result == 1) then
        puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: noindex [tecdoc] присутствует"
      else
        puts "#{time} Проверка наличия noindex, nofollow на страницах сервисных сайтов: Ошибка! noindex [tecdoc] отсутствует!"
      end

      #закрываем файл лога
      $stdout.flush
    end
  end

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end