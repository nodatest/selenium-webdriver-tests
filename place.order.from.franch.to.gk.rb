#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'
require_relative 'franchisee.order'

def placeOrderFromFranchToGk(browser)

  #делаем заказ под франчем, если он не был сделан
  franchiseeOrder(browser) if @orderid.nil?

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Отправка заказа франча в ГК ====='

  #логинимся в ПУ под франчем
  cpLogin

  @driver.find_element(:link, @orderid).click #кликаем по нашему заказу
  @driver.find_element(:xpath, '//*[@id="allPlacingOrder"]').click #кликаем по чекбоксу "Заказ", который отмечает все позиции в столбце
  @driver.find_element(:xpath, '//*[@id="postable"]/tbody/tr[4]/td[3]/input').click #кликаем по кнопке "Отправить заказ поставщику"
  sleep 1 #сек
  @driver.find_element(:xpath, '/html/body/div[5]/div[11]/div/button[1]/span').click #кликаем по кнопке "Отправить"
  orderid = @driver.find_element(:xpath, '//*[@id="placeOrderDialogContent"]/form/h4[2]').text.split[1] #берём второе слово из строки, которое является номером заказа в ГК

  #логинимся в рут
  cpLoginFromRoot

  @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
  @driver.find_element(:link, "#{orderid}").click #кликаем по нашему заказу


  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end
