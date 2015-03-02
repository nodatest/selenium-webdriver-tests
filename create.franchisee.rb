#!/bin/env ruby
# encoding: utf-8

#функция создания франчайзи
def createFranchisee(browser)

  @name = 'Создание франчайзи'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    #получение ссылки в руте для перехода в пу
    cpLoginFromRoot

    clientname = "test_user_#{rand(1..1000000).to_s}" #генерируем случайное имя клиента
    email = "#{clientname}@selenium.noda.pro" #генерируем мыло c именем клиента

    #создание клиента
    createClient(clientname, email, 0)

    #добавление франчайзи
    addFranchisee(clientname, email)
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end