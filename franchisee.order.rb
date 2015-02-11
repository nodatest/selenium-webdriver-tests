#!/bin/env ruby
# encoding: utf-8
require_relative 'common.functions'
require_relative 'create.franchisee'

def franchiseeOrder(browser)

  #если перед этим франчайзи не был создан
  if @franchid.nil?
    #создаём франчайзи
    createFranchisee(browser)
  end

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  puts '===== Добавление заказа на созданном франчайзи ====='

  if @link.nil? or @options[:name].nil?
    #логинимся в рут
    cpLoginFromRoot
    #устанавливаем значение опции
    setOptionFromRoot(@franchid, 'cp/manually_add_customers', 1)
    #авторизируемся в ПУ франчайзи
    cpLogin
    createClient(0) #создание клиента
    @link = @driver.find_element(:xpath, '//*/tr[3]/td/a[1]').attribute('href') #получаем адрес ссылки для перехода на сайт под клиентом
    @link['http://selenium.noda.pro'] = "http://selenium.noda.pro#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный
  end

  @driver.navigate.to @link #переходим на сайт под клиентом

  #поиск
  search('oc90')

  #добавляем товар в корзину
  addToCart

  #кликаем по кнопке "Оформить заказ"
  @driver.find_element(:xpath, '//*[@id="formTrash"]/div[2]/div[2]/input').click

  #отправляем заказ
  sendOrder

  #закрываем файл лога
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit if !@options[:aio]
end