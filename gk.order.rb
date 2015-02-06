#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'

def gkOrder(browser)
  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Добавление заказа на сайте ГК ====='

  #получение ссылки в руте для перехода в пу
  cpLoginFromRoot

  #создаём клиента, ищем товар, добавляем его в корзину и оформляем заказ
  createClientAndSearchAndSendOrder

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end

