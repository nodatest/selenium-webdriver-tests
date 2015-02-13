#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'
require_relative 'franchisee.order'

def placeOrderFromFranchToGk(browser)
  franchiseeOrder(browser) if @orderid.nil? #делаем заказ под франчем, если он не был сделан

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Отправка заказа франча в ГК ====='

  #логинимся в ПУ под франчем
  cpLogin(@cplogin, @cppass)

  @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
  @driver.find_element(:link, @orderid).click #кликаем по нашему заказу
  @driver.find_element(:xpath, '//*[@id="allPlacingOrder"]').click #кликаем по чекбоксу "Заказ", который отмечает все позиции в столбце
  @driver.find_element(:xpath, '//*[@value="Отправить заказ поставщику"]').click #кликаем по кнопке "Отправить заказ поставщику"
  sleep 3 #сек
  @driver.find_element(:xpath, '//*[@class="ui-dialog-buttonset"]/button[1]/span').click #кликаем по кнопке "Отправить"
  reorderid = @driver.find_element(:xpath, '//*[@id="placeOrderDialogContent"]/form/h4[2]').text.split[1] #берём второе слово из строки, которое является номером заказа в ГК

  #логинимся в рут
  cpLoginFromRoot

  @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
  @driver.find_element(:link, "#{reorderid}").click #кликаем по нашему заказу

  @orderid = nil #задаём пустым номер заказа для того, чтобы сделать заказ на существующем франче под существующим юзером

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end
