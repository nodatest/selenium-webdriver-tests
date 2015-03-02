#!/bin/env ruby
# encoding: utf-8

def franchiseeOrder(browser)

  #создаём франчайзи, если перед этим он не был создан
  createFranchisee(browser) unless @franchid

  @name = 'Добавление заказа на созданном франчайзи'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    #логинимся в рут
    cpLoginFromRoot
    #устанавливаем значение опции
    setOptionFromRoot(@franchid, 'cp/manually_add_customers', 1, 1)
    #авторизируемся в ПУ франчайзи
    cpLogin(@cpfranchlogin, @cpfranchpass)

    clientname = "test_user_#{rand(1..1000000).to_s}" #генерируем случайное имя клиента
    email = "#{clientname}@selenium.noda.pro" #генерируем мыло c именем клиента

    #создание клиента
    createClient(clientname, email, 0)

    link = @driver.find_element(:xpath, '//*/tr[3]/td/a[1]').attribute('href') #получаем адрес ссылки для перехода на сайт под клиентом
    link['http://selenium.noda.pro'] = "http://selenium.noda.pro#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный

    puts "#{time} переходим на сайт под клиентом"
    @driver.navigate.to link #переходим на сайт под клиентом

    #поиск
    search('Knecht', 'oc90')

    #добавляем товар в корзину
    addToCart

    puts "#{time} кликаем по кнопке 'Оформить заказ'"
    #кликаем по кнопке 'Оформить заказ'
    @driver.find_element(:xpath, '//*[@value="Оформить заказ"]').click

    #отправляем заказ
    sendOrder
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end