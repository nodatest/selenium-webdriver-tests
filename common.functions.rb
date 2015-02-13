#!/bin/env ruby
# encoding: utf-8
require 'optparse'
require 'json'
require 'net/http'
require 'logger'

#класс для одновременного логирования в терминал и в файл
class MultiDelegator
  def initialize(*targets)
    @targets = targets
  end

  def self.delegate(*methods)
    methods.each do |m|
      define_method(m) do |*args|
        @targets.map { |t| t.send(m, *args) }
      end
    end
    self
  end

  class <<self
    alias to new
  end
end

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
  log_file = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
  $stdout = MultiDelegator.delegate(:write, :close, :puts, :print, :flush).to(STDOUT, log_file)
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
    @driver.find_element(:css, '.inp').send_keys('autotest') #вводим логин
    @driver.find_element(:name, 'pass').send_keys('123123') #вводим пароль
    @driver.find_element(:name, 'go').click #кликаем на вкладку вход
  rescue
  end
  @driver.navigate.to 'http://root.abcp.ru/?search=selen&page=customers' #переходим по ссылке, которая отфильтровывает нашего тестового реселлера
  link = @driver.find_element(:xpath, '//*[@class="q-login-menu"]/a[1]').attribute('href') #получаем адрес ссылки для перехода в пу
  link['http://cp.abcp.ru'] = "http://cp.abcp.ru#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный
  @driver.navigate.to link #переходим в пу под сотрудником нодасофт
end

#создание клиента
def createClient(clientname, email, profileid)
  @driver.find_element(:link, 'Клиенты').click #кликаем по ссылке "клиенты"
  @driver.find_element(:link, 'Добавить клиента').click #кликаем по ссылке "добавить клиента"
  @driver.find_element(:name, 'customerName').send_keys(clientname) #вводим имя клиента
  @driver.find_element(:name, 'customerEmail').send_keys(email) #вводим мыло
  @driver.find_element(:xpath, "//*[@name='customerProfiles']/*[@value='#{profileid}']").click #выбираем профиль клиента
  @driver.find_element(:class, 'ui-button-text').click #нажимаем кнопку "создать"
  @clientid = @driver.find_element(:xpath, '//*[contains(text(),"Системный код клиента:")]/../td') #сохраняем clientid
end

#добавление франчайзи
def addFranchisee(clientname, email)
  @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
  @driver.find_element(:link, 'Добавить франчайзи').click #кликаем по ссылке "Добавить франчайзи"
  @driver.find_element(:name, 'agreeWithCreation').click #отмечаем чекбокс
  @driver.find_element(:id, 'clientAliveSearch').send_keys(clientname) #вводим имя клиента
  sleep 3 #сек
  @driver.find_element(:id, 'clientAliveSearch').send_keys(' ') #костыль для случая, когда имя клиента не успевает попасть в список
  @driver.find_element(:xpath, "//*[contains(text(),'#{clientname}')]").click #кликаем по клиенту с нашим именем из выпадающего списка
  @driver.find_element(:name, 'email').send_keys("franch_#{email}") #вводим email
  begin
    json = Net::HTTP.get('address1.abcp.ru', '/city/getByRegionsCodes/?regionsCodes[0]='+rand(10..99).to_s) #get-запрос получения случайного города из address api
    parsed = JSON.parse(json) #парсим json-ответ
    begin
      city = parsed[rand(0..parsed.size)]['name']
    rescue
      puts city #отладка
    end
  end until city #до тех пор пока не спарсим удачно, т.к. почему-то не всегда удаётся
  @driver.find_element(:name, 'city').send_keys(city) #вводим название города
  @driver.find_element(:xpath, '//*[@value="Добавить"]').click #кликаем кнопку "Добавить"
  @cplogin = @driver.find_element(:xpath, '//*/div[1]/strong[1]').text #сохраняем логин для входа
  @cppass = @driver.find_element(:xpath, '//*/div[1]/strong[2]').text #сохраняем пароль для входа
  @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
  @franchid = @driver.find_element(:xpath, "//*[contains(.,'#{city}')]/../td[5]").text #сохраняем id франчайзи
end

#функция поиска
def search(brand, number)
  @driver.find_element(:id, 'pcode').send_keys(number) #вводим поисковый запрос
  @driver.find_element(:xpath, '//*[@alt="Найти"]').click #жмём кнопку "Найти"
  begin
    @driver.find_element(:xpath, "//*[@href='/?pbrandnumber=#{number}&pbrandname=#{brand}']").click if @driver.find_element(:xpath, '//*[@class="startSearching"]').displayed?
  rescue
  end
end

#функция добавления товара в корзину
def addToCart
  @driver.find_element(:xpath, '//*[@title="Купить"]').click #жмём кнопку добавить в корзину
  sleep 1 #сек
  #проверяем не появляется ли модальное окно
  begin
    @driver.find_element(:xpath, '//*[class="ui-button-text"]').click if @driver.find_element(:xpath, '//*[@id="dialogConfirm"]').displayed?
  rescue
  end
end

#отправка заказа
def sendOrder
  begin
    @driver.find_element(:name, 'enableSendingSms').click #снимаем чекбокс отправки смс
  rescue
  end
  @driver.find_element(:xpath, '//*[@value="Отправить заказ"]').click #кликаем по кнопке "Отправить заказ"
  @orderid = @driver.find_element(:xpath, '//*/div[2]/div[*]/strong').text #сохраняем id заказа
end

#функция авторизации в ПУ
def cpLogin(login, pass)
  @driver.navigate.to "http://cp.abcp.ru#{@lan}" #переходим в пу
  begin
    @driver.find_element(:link, 'Выйти').click #разлогиниваемся в ПУ
  rescue
  end
  @driver.find_element(:id, 'login').send_keys("#{login}") #вводим логин
  @driver.find_element(:id, 'pass').send_keys("#{pass}") #вводим пароль
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
    @driver.find_element(:xpath, "//*[@name='val_#{option}']/option[@value='#{value}']").click #выбираем значение опции
  end
  @driver.find_element(:id, 'submit').click #сохраняем
end