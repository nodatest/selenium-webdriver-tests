#!/bin/env ruby
# encoding: utf-8

#функция выполнения пост-действий
def postActions(browser)

  @totalerrors = 0 #задаём кол-во ошибок в начале выполнения
  @name = 'Выполнение пост-действий'

  @options[:aio] = nil

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    @name = 'Удаление скриншотов недельной давности'
    deleteScreenshots('../screenshots', 7) #Удаляем скриншоты недельной давности

    cpLoginFromRoot #логинимся на сайт из рута

    @name = 'Удаление тестовых франчей'
    deleteFranches(2) #удаляем тестовых франчей, которым > 2 дней

    @name = 'Удаление заказов тестовых клиентов'
    deleteOrders(2) #удаляем заказы тестовых клиентов, которым > 2 дней

    @name = 'Удаление клиентов, которым > 2 дней'
    deleteClients(2) #удаляем тестовых клиентов, которым > 2 дней

  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
  puts "Пост-действия выполнены, кол-во ошибок - #{@totalerrors}".colorize(:blue)
end