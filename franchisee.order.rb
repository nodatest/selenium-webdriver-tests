#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'
require_relative 'create.franchisee'

def franchiseeOrder(browser)

  #создаём франчайзи, если перед этим он не был создан
  createFranchisee(browser) if @options[:name] or @login.nil?

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Добавление заказа на созданном франчайзи ====='

  #логинимся в рут
  cpLoginFromRoot

  #устанавливаем значение опции
  setOptionFromRoot(@franchid, 'cp/manually_add_customers', 1)

  #авторизируемся в ПУ франчайзи
  cpLogin

  #создаём клиента, ищем товар, добавляем его в корзину и оформляем заказ
  createClientAndSearchAndSendOrder

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end