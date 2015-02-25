#!/bin/env ruby
# encoding: utf-8

def gkOrder(browser)
  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Добавление заказа на сайте ГК ====='.colorize(:green)

  begin
    #получение ссылки в руте для перехода в пу
    cpLoginFromRoot

    clientname = "test_user_#{rand(1..1000000).to_s}" #генерируем случайное имя клиента
    email = "#{clientname}@selenium.noda.pro" #генерируем мыло c именем клиента

    #создание клиента
    createClient(clientname, email, 0)

    link = @driver.find_element(:xpath, '//*[@class="linkTempLogin"]').attribute('href') #получаем адрес ссылки для перехода на сайт под клиентом
    link['http://selenium.noda.pro'] = "http://selenium.noda.pro#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный

    puts "#{time} переходим на сайт под клиентом"
    @driver.navigate.to link #переходим на сайт под клиентом

    #поиск
    search('Febi', '01089')

    #добавляем товар в корзину
    addToCart

    puts "#{time} кликаем по кнопке 'Оформить заказ'"
    #кликаем по кнопке "Оформить заказ"
    @driver.find_element(:xpath, '//*[@value="Оформить заказ"]').click

    #отправляем заказ
    sendOrder
  rescue
    @errors += 1
  end

  countErrorsFlushLogBrowserQuit #подсчитываем ошибки, выводим их, скидываем записи в лог, выходим из браузера, если надо
end