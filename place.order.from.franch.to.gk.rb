#!/bin/env ruby
# encoding: utf-8

def placeOrderFromFranchToGk(browser)
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

  @errors += 1 unless reorderid
  @totalerrors += @errors #прибавляем кол-во ошибок к общему

  #логинимся в рут
  cpLoginFromRoot

  puts "#{time} переходим на вкладку 'Заказы'"
  @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
  puts "#{time} кликаем по нашему заказу"
  @driver.find_element(:link, "#{reorderid}").click #кликаем по нашему заказу

  puts "info: кол-во ошибок в тесте - #{@errors}"

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end
