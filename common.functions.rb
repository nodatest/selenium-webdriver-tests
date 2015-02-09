#!/bin/env ruby
# encoding: utf-8
require 'optparse'
require 'json'
require 'net/http'

#время начала выполнения теста
def time()
  time = Time.now.strftime('%d-%m-%Y %H-%M-%S')
end

#дата
def date
  date = time[0, 10]
end

#параметры в командной строке
def options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'
    opts.on('-a', '--all-tests-in-one-browser', 'all tests in one browser') { |a| @options[:aio] = a }
    opts.on('-b', '--browser NAME', 'set browser (chrome/firefox)') { |b| @options[:browser] = b }
    opts.on('-f', '--fullscreen', 'fullscreen mode') { |f| @options[:fullscreen] = f }
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--name NAME', 'test name') { |n| @options[:name] = n }
  end.parse!

  @lan = '.lan' if @options[:lan]

  #задаём массив браузеров в зависимости от переданного параметра -b
  case @options[:browser]
    when 'firefox'
      @browser = %w(firefox)
    when 'chrome'
      @browser = %w(chrome)
    else
      @browser = %w(chrome firefox)
  end
end

#функция проверки параметров запуска тестов в одном бразуере и запуска бразуера в полнооконном режиме
# + включения логирования в файл
def checkparametersandlog(browser)
  #если НЕ установлен параметр запуска тестов в одном бразуере
  startBrowser(browser) if !@options[:aio]

  #если установлен параметр запуска бразуера в полнооконном режиме
  @driver.manage.window.maximize if @options[:fullscreen]

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
end

#функция запуска браузера
def startBrowser(browser)
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds
  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  if @lan
    @driver.manage.timeouts.implicit_wait = 15 # seconds
  else
    @driver.manage.timeouts.implicit_wait = 5 # seconds
  end
end

#получение ссылки в руте для перехода в пу
def cpLoginFromRoot
  @driver.navigate.to 'http://root.abcp.ru/' #переходим в рут
  begin
    @driver.find_element(:css, '.inp').send_keys('') #вводим логин
    @driver.find_element(:name, 'pass').send_keys('') #вводим пароль
    @driver.find_element(:name, 'go').click #кликаем на вкладку вход
  rescue
  end
  @driver.navigate.to 'http://root.abcp.ru/?search=selen&page=customers' #переходим по ссылке, которая отфильтровывает нашего тестового реселлера
  link = @driver.find_element(:xpath, '//*[@id="content"]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/div/a[1]').attribute('href') #получаем адрес ссылки для перехода в пу
  link['http://cp.abcp.ru'] = "http://cp.abcp.ru#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный
  @driver.navigate.to link #переходим в пу под сотрудником нодасофт
end

#создание клиента
def createClient(profileid)
  @driver.find_element(:link, 'Клиенты').click #кликаем по ссылке "клиенты"
  @driver.find_element(:link, 'Добавить клиента').click #кликаем по ссылке "добавить клиента"
  @driver.find_element(:name, 'customerName').send_keys("user_#{time}") #вводим имя клиента
  @email = "user_#{rand(1..1000000).to_s}@selenium.noda.pro" #генерируем мыло
  @driver.find_element(:name, 'customerEmail').send_keys(@email) #вводим мыло
  @driver.find_element(:xpath, "//*[@id='addCustomerDialog']/table/tbody/tr[6]/td/select/option[@value='#{profileid}']").click
  @driver.find_element(:class, 'ui-button-text').click #нажимаем кнопку "создать"
  @clientid = @driver.find_element(:xpath, '//*[@id="commonSettings"]/div/table/tbody/tr[1]/td').text.to_s #сохраняем clientid
end

#добавление франчайзи
def addFranchisee
  @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
  @driver.find_element(:link, 'Добавить франчайзи').click #кликаем по ссылке "Добавить франчайзи"
  @driver.find_element(:name, 'agreeWithCreation').click #отмечаем чекбокс
  for i in 0 .. @clientid.size
    @driver.find_element(:id, 'clientAliveSearch').send_keys(@clientid[i]) #вводим id клиента
    sleep 1 #пауза в сек
  end
  sleep 3
  @driver.find_element(:xpath, '//*/tbody/tr[1]/td/div/div/table/tbody/tr/td[1]').click #кликаем по первому элементу выпадающего списка
  @driver.find_element(:name, 'email').send_keys("franch_#{@email}") #вводим email
  begin
    json = Net::HTTP.get('address1.abcp.ru', '/city/getByRegionsCodes/?regionsCodes[0]='+rand(10..99).to_s) #get-запрос получения случайного города из address api
    parsed = JSON.parse(json) #парсим json-ответ
    begin
      city = parsed[rand(0..parsed.size)]['name']
    rescue
      puts city
    end
  end until city #до тех пор пока не спарсим удачно, т.к. почему-то не всегда удаётся
  @driver.find_element(:name, 'city').send_keys(city) #вводим название города
  @driver.find_element(:xpath, '//*/tr[11]/td/input').click #кликаем кнопку "Добавить"
  @login = @driver.find_element(:xpath, '//*/div[1]/strong[1]').text #сохраняем логин для входа
  @pass = @driver.find_element(:xpath, '//*/div[1]/strong[2]').text #сохраняем пароль для входа
  @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
  @franchid = @driver.find_element(:xpath, "//*[@id='tsortable']/tbody/tr[*]/td[contains(.,'#{city}')]/../td[5]").text #сохраняем id франчайзи
end

#функция поиска
def search(number)
  @driver.find_element(:id, 'pcode').send_keys(number) #вводим поисковый запрос
  @driver.find_element(:xpath, '/html/body/div[5]/table/tbody/tr[1]/td[2]/a').click #кликаем по первому элементу выпадающего списка
end

#функция добавления товара в корзину
def addToCart
  @driver.find_element(:xpath, '//*[@id="searchResultsTable"]/tbody/tr[3]/td[9]/div/div[2]/button').click #жмём кнопку добавить в корзину
  sleep 1 #сек
  #проверяем не появляется ли модальное окно
  begin
    @driver.find_element(:xpath, '/html/body/div[6]/div[3]/div/button[1]/span').click if @driver.find_element(:xpath, '/html/body/div[6]').displayed?
  rescue
  end
end

#отправка заказа
def sendOrder
  begin
    @driver.find_element(:name, 'enableSendingSms').click #снимаем чекбокс отправки смс
  rescue
  end
  @driver.find_element(:xpath, '//*[@id="trashAcceptorderForm"]/table/tbody/tr[2]/td/div[*]/div/input[2]').click #кликаем по кнопке "Отправить заказ"
  @orderid = @driver.find_element(:xpath, '/html/body/div[3]/div[3]/div/div/div[2]/div[*]/strong').text #сохраняем id заказа
end

#функция авторизации в ПУ
def cpLogin
  @driver.navigate.to "http://cp.abcp.ru#{@lan}" #переходим в пу
  begin
  @driver.find_element(:link, 'Выйти').click #разлогиниваемся в ПУ
  rescue
  end
  @driver.find_element(:id, 'login').send_keys("#{@login}") #вводим логин
  @driver.find_element(:id, 'pass').send_keys("#{@pass}") #вводим пароль
  @driver.find_element(:id, 'go').click #кликаем по кнопке
end

#функция установки значения опции реселлера через рут
def setOptionFromRoot(resellerid, option, value)
  @driver.navigate.to "http://root.abcp.ru/?page=reseller_edit_options&resellerId=#{resellerid}" #переходим в рут для редактирования опций реселлера

  sleep 1 #сек

  begin
    @driver.find_element(:xpath, "//*[@id='optionField']/option[@value='#{option}']").click #выбираем опцию
    @driver.find_element(:xpath, "//*[@id='valueField']/select/option[@value='#{value}']").click #выбираем значение
  rescue #иначе опция уже добавлена реселлеру
    @driver.find_element(:xpath, "//*[@id='content']/table/tbody/tr/td/form/table/tbody/tr[17]/td[4]/select[@name='val_#{option}']/option[@value='#{value}']").click #выбираем значение опции
  end
  @driver.find_element(:id, 'submit').click #сохраняем
end