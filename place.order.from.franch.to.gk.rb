#!/bin/env ruby
# encoding: utf-8

def placeOrderFromFranchToGk(browser)

  franchiseeOrder(browser) unless @franchorderid #делаем заказ под франчем, если он не был сделан

  @name = 'Отправка заказа франча в ГК'

    #проверяем часть переданных параметров командной строки и включаем логирование
    checkparametersandlog(browser)

  begin
    #логинимся в ПУ под франчем
    cpLogin(@cpfranchlogin, @cpfranchpass)

    puts "#{time} переходим на вкладку 'Заказы'"
    @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
    puts "#{time} кликаем по нашему заказу"
    @driver.find_element(:link, @orderid).click #кликаем по нашему заказу
    puts "#{time} кликаем по чекбоксу 'Заказ', который отмечает все позиции в столбце"
    @driver.find_element(:xpath, '//*[@id="allPlacingOrder"]').click #кликаем по чекбоксу "Заказ", который отмечает все позиции в столбце
    puts "#{time} кликаем по кнопке 'Отправить заказ поставщику'"
    @driver.find_element(:xpath, '//*[@value="Отправить заказ поставщику"]').click #кликаем по кнопке "Отправить заказ поставщику"
    sleep 3 #сек
    puts "#{time} кликаем по кнопке 'Отправить' в появившемся модальном окне"
    @driver.find_element(:xpath, '//*[@class="ui-dialog-buttonset"]/button[1]/span').click #кликаем по кнопке "Отправить" в появившемся модальном окне
    reorderid = @driver.find_element(:xpath, '//*[@id="placeOrderDialogContent"]/form/h4[2]').text.split[1] #берём второе слово из строки, которое является номером заказа в ГК
    if reorderid == 0 or nil
      raise 'Пустой/нулевой номер перезаказа'
    end

    #логинимся в рут
    cpLoginFromRoot

    puts "#{time} переходим на вкладку 'Заказы'"
    @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
    puts "#{time} кликаем по нашему заказу"
    @driver.find_element(:link, "#{reorderid}").click #кликаем по нашему заказу
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end
