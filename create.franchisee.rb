#!/bin/env ruby
# encoding: utf-8

#функция создания франчайзи
def createFranchisee(browser)
  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Создание франчайзи ====='.colorize(:green)

  #получение ссылки в руте для перехода в пу
  cpLoginFromRoot

  clientname = "test_user_#{rand(1..1000000).to_s}" #генерируем случайное имя клиента
  email = "#{clientname}@selenium.noda.pro" #генерируем мыло c именем клиента

  #создание клиента
  createClient(clientname, email, 0)

  #добавление франчайзи
  addFranchisee(clientname, email)

  @errors += 1 unless @franchid

  @totalerrors += @errors #прибавляем кол-во ошибок к общему
  puts "info: кол-во ошибок в тесте - #{@errors}"

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end