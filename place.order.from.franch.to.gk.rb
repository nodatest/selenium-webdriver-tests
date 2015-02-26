#!/bin/env ruby
# encoding: utf-8

def placeOrderFromFranchToGk(browser)
  begin
    franchiseeOrder(browser) unless @orderid #делаем заказ под франчем, если он не был сделан

    #проверяем часть переданных параметров командной строки и включаем логирование
    checkparametersandlog(browser)

    puts '===== Отправка заказа франча в ГК ====='.colorize(:green)
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
      @errors += 1
      @driver.save_screenshot("../screenshots/#{date} #{time} #{__method__.to_s}.png")
    end

    #логинимся в рут
    cpLoginFromRoot

    puts "#{time} переходим на вкладку 'Заказы'"
    @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
    puts "#{time} кликаем по нашему заказу"
    @driver.find_element(:link, "#{reorderid}").click #кликаем по нашему заказу
  rescue
    @errors += 1
    @driver.save_screenshot("../screenshots/#{date} #{time} #{__method__.to_s}.png")
  end

  countErrorsFlushLogBrowserQuit #подсчитываем ошибки, выводим их, скидываем записи в лог, выходим из браузера, если надо
end
