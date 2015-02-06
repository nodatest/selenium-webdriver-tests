#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'

#функция создания франчайзи
def createFranchisee(browser)
  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Создание франчайзи ====='

  #получение ссылки в руте для перехода в пу
  cpLoginFromRoot

  #создание клиента
  createClient(0)

  #добавление франчайзи
  addFranchisee

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end