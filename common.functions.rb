#!/bin/env ruby
# encoding: utf-8
require 'json'
require 'net/http'

#получение ссылки в руте для перехода в пу
def cpLoginFromRoot(resellername='selenium.noda.pro')
  @driver.navigate.to 'http://root.abcp.ru/' #переходим в рут
  begin
    @driver.find_element(:css, '.inp').send_keys('autotest') #вводим логин
    @driver.find_element(:name, 'pass').send_keys('123123') #вводим пароль
    @driver.find_element(:name, 'go').click #кликаем на вкладку вход
  rescue
  end
  @driver.navigate.to "http://root.abcp.ru/?search=#{resellername}&page=customers" #переходим по ссылке, которая отфильтровывает нашего тестового реселлера
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
      @city = parsed[rand(0..parsed.size)]['name']
    rescue
      puts @city #отладка
    end
  end until @city #до тех пор пока не спарсим удачно, т.к. почему-то не всегда удаётся
  @driver.find_element(:name, 'city').send_keys(@city) #вводим название города
  @driver.find_element(:xpath, '//*[@value="Добавить"]').click #кликаем кнопку "Добавить"
  @cpfranchlogin = @driver.find_element(:xpath, '//*/div[1]/strong[1]').text #сохраняем логин для входа
  @cpfranchpass = @driver.find_element(:xpath, '//*/div[1]/strong[2]').text #сохраняем пароль для входа
  @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
  @franchid = @driver.find_element(:xpath, "//*[contains(.,'#{@city}')]/../td[5]").text #сохраняем id франчайзи
end

#функция поиска
def search(brand, number)
  @driver.find_element(:id, 'pcode').send_keys(number) #вводим поисковый запрос
  @driver.find_element(:xpath, '//*[@alt="Найти"]').click #жмём кнопку "Найти"
  begin
    @driver.find_element(:xpath, "//*[contains(text(),'#{brand}')]/../..//*[contains(text(),'#{number}')]/..//*[contains(text(),'Цены и аналоги')]").click if @driver.find_element(:xpath, '//*[contains(text(),"Цены и аналоги")]').displayed?
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

#функция установки значения опции реселлера/франча через рут
def setOptionFromRoot(resellerid, option, value, *isfranch)
  if isfranch
    @driver.navigate.to "http://root.abcp.ru/?page=reseller_edit_options&resellerId=#{resellerid}" #ищем в руте нашего реселлера по resellerid
    resellername = @city.to_s.downcase #если франч, то присваиваем имени реселлера город франча в нижнем регистре
  else
    @driver.navigate.to "http://root.abcp.ru/?search=#{resellerid}&page=customers" #ищем в руте нашего реселлера по resellerid
    resellername = @driver.find_element(:xpath, "//*/td[1]/span/a[contains(text(),'#{resellerid}']../../../tr[2]/td[2]/div/a[1]") #сохраняем имя ресселлера, соответствующее id
    @driver.find_element(:xpath, "//*[@title='Опции #{resellername}']").click #переходим по ссылке редактирования опций реселлера
  end
  begin
    @driver.find_element(:xpath, "//*[contains(text(),'Редактирование реселлера #{resellername}')]") #находим строчку, которая указывает на то, что мы редактируем нашего тестового реселлера
    sleep 1 #сек
    begin
      @driver.find_element(:xpath, "//*[@id='optionField']/option[@value='#{option}']").click #выбираем опцию
      @driver.find_element(:xpath, "//*[@id='valueField']/select/option[@value='#{value}']").click #выбираем значение
    rescue #иначе опция уже добавлена реселлеру
      @driver.find_element(:xpath, "//*[@name='val_#{option}']/option[@value='#{value}']").click #выбираем значение опции
    end
    @driver.find_element(:id, 'submit').click #сохраняем
  rescue
    puts 'Редактирование опций чужого реселлера!'
  end
end