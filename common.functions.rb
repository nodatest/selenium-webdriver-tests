#!/bin/env ruby
# encoding: utf-8
require 'json'
require 'net/http'

#получение ссылки в руте для перехода в пу
def cpLoginFromRoot(resellername='selenium.noda.pro')
  begin
    puts "#{time} переходим в рут"
    @driver.navigate.to 'http://root.abcp.ru/' #переходим в рут
    if @driver.find_elements(:css, '.inp').count > 0
      puts "#{time} вводим логин и пароль"
      @driver.find_element(:css, '.inp').send_keys('autotest') #вводим логин
      @driver.find_element(:name, 'pass').send_keys('123123') #вводим пароль
      puts "#{time} кликаем на кнопку вход"
      @driver.find_element(:name, 'go').click #кликаем на кнопку вход
    end
    puts "#{time} переходим по ссылке, которая отфильтровывает нашего тестового реселлера"
    @driver.navigate.to "http://root.abcp.ru/?search=#{resellername}&page=customers" #переходим по ссылке, которая отфильтровывает нашего тестового реселлера
    puts "#{time} получаем адрес ссылки для перехода в ПУ"
    link = @driver.find_element(:xpath, '//*[@class="q-login-menu"]/a[1]').attribute('href') #получаем адрес ссылки для перехода в пу
    link['http://cp.abcp.ru'] = "http://cp.abcp.ru#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный
    puts "#{time} переходим в ПУ под Сотрудником НодаСофт"
    @driver.navigate.to link #переходим в пу под сотрудником нодасофт
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#создание клиента
def createClient(clientname, email, profileid)
  begin
    puts "#{time} кликаем по ссылке 'Клиенты'"
    @driver.find_element(:link, 'Клиенты').click #кликаем по ссылке "клиенты"
    puts "#{time} кликаем по ссылке 'Добавить клиента'"
    @driver.find_element(:link, 'Добавить клиента').click #кликаем по ссылке "добавить клиента"
    puts "#{time} вводим имя клиента, e-mail, выбираем профиль клиента"
    @driver.find_element(:name, 'customerName').send_keys(clientname) #вводим имя клиента
    @driver.find_element(:name, 'customerEmail').send_keys(email) #вводим мыло
    @driver.find_element(:xpath, "//*[@name='customerProfiles']/*[@value='#{profileid}']").click #выбираем профиль клиента
    puts "#{time} нажимаем кнопку 'Создать'"
    @driver.find_element(:class, 'ui-button-text').click #нажимаем кнопку "создать"
    @clientid = @driver.find_element(:xpath, '//*[contains(text(),"Системный код клиента:")]/../td') #сохраняем clientid
    if @clientid == 0 or nil
      @errors += 1
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#добавление франчайзи
def addFranchisee(clientname, email)
  begin
    puts "#{time} переходим на вкладку 'Франчайзи'"
    @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
    puts "#{time} кликаем по ссылке 'Добавить франчайзи'"
    @driver.find_element(:link, 'Добавить франчайзи').click #кликаем по ссылке "Добавить франчайзи"
    puts "#{time} отмечаем чекбокс"
    @driver.find_element(:name, 'agreeWithCreation').click #отмечаем чекбокс
    puts "#{time} вводим имя клиента, e-mail, название города"
    @driver.find_element(:id, 'clientAliveSearch').send_keys(clientname) #вводим имя клиента
    sleep 3 #сек
    @driver.find_element(:id, 'clientAliveSearch').send_keys(' ') #костыль для случая, когда имя клиента не успевает попасть в список
    @driver.find_element(:xpath, "//*[contains(text(),'#{clientname}')]").click #кликаем по клиенту с нашим именем из выпадающего списка
    @driver.find_element(:name, 'email').send_keys("test_franch_#{email}") #вводим email
    json = Net::HTTP.get('address1.abcp.ru', '/city/getByRegionsCodes/?regionsCodes[0]='+rand(10..99).to_s) #get-запрос получения случайного города из address api
    parsed = JSON.parse(json) #парсим json-ответ
    begin
      city = "test_#{parsed[rand(0..parsed.size)]['name']}"
    rescue
      city = 'test_печалька' unless city #если не спарсили удачно, то задаём принудительно, т.к. почему-то не всегда удаётся
    end
    @driver.find_element(:name, 'city').send_keys(city) #вводим название города
    puts "#{time} кликаем кнопку 'Добавить'"
    @driver.find_element(:xpath, '//*[@value="Добавить"]').click #кликаем кнопку "Добавить"
    @cpfranchlogin = @driver.find_element(:xpath, '//*/div[1]/strong[1]').text #сохраняем логин для входа
    @cpfranchpass = @driver.find_element(:xpath, '//*/div[1]/strong[2]').text #сохраняем пароль для входа
    puts "#{time} переходим на вкладку 'Франчайзи'"
    @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
    @franchid = @driver.find_element(:xpath, "//*[contains(.,'#{@city}')]/../td[5]").text #сохраняем id франчайзи
    if @franchid == 0 or nil
      raise 'Id франчайзи нулевой или отсутсвует!'
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция поиска
def search(brand, number)
  begin
    puts "#{time} вводим поисковый запрос в строку поиска"
    @driver.find_element(:id, 'pcode').send_keys(number) #вводим поисковый запрос в строку поиска
    puts "#{time} кликаем по кнопке 'Найти'"
    @driver.find_element(:xpath, '//*[@alt="Найти"]').click #жмём кнопку "Найти"
    if @driver.find_elements(:xpath, '//*[contains(text(),"Цены и аналоги")]').count > 0
      puts "#{time} первый этап поиска: кликаем по ссылке 'Цены и аналоги'"
      @driver.find_element(:xpath, "//*[contains(text(),'#{brand}')]/../..//*[contains(text(),'#{number}')]/..//*[contains(text(),'Цены и аналоги')]").click
    else
      puts "#{time} второй этап поиска"
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция добавления товара в корзину
def addToCart
  begin
    puts "#{time} жмём кнопку 'Добавить в корзину'"
    @driver.find_element(:xpath, '//*[@title="Купить"]').click #жмём кнопку добавить в корзину
    sleep 1 #сек
    if @driver.find_elements(:xpath, '//*[@id="dialogConfirm"]').count > 0 #проверяем не появляется ли модальное окно
      puts "#{time} кликаем 'Да' в появившемся модальном окне"
      @driver.find_element(:xpath, '//*[class="ui-button-text"]').click #кликаем 'Да'
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#отправка заказа
def sendOrder
  begin
    if @driver.find_elements(:name, 'enableSendingSms').count > 0
      puts "#{time} снимаем чекбокс отправки смс"
      @driver.find_element(:name, 'enableSendingSms').click #снимаем чекбокс отправки смс
    end
    puts "#{time} кликаем по кнопке 'Отправить заказ'"
    @driver.find_element(:xpath, '//*[@value="Отправить заказ"]').click #кликаем по кнопке "Отправить заказ"
    @orderid = @driver.find_element(:xpath, '//*/div[2]/div[*]/strong').text #сохраняем id заказа
    if @orderid == 0 or nil
      raise 'Id заказа пустой или нулевой!'
    end
    check = @driver.find_elements(:xpath, '//*[@class="headCity logged" and contains(text(),"test_")]').count #если заказ сделан на франче
    puts check
    if check == 1
      @franchorderid = @orderid #присваиваем номер заказа номеру заказа франча
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция авторизации в ПУ
def cpLogin(login, pass)
  begin
    puts "#{time} переходим в ПУ"
    @driver.navigate.to "http://cp.abcp.ru#{@lan}" #переходим в пу
    if @driver.find_elements(:link, 'Выйти').count == 1
      puts "#{time} разлогиниваемся в ПУ"
      @driver.find_element(:link, 'Выйти').click #разлогиниваемся в ПУ
    end
    puts "#{time} вводим логин и пароль"
    @driver.find_element(:id, 'login').send_keys("#{login}") #вводим логин
    @driver.find_element(:id, 'pass').send_keys("#{pass}") #вводим пароль
    puts "#{time} кликаем по кнопке 'Войти'"
    @driver.find_element(:id, 'go').click #кликаем по кнопке 'Войти'
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция установки значения опции реселлера/франча через рут
def setOptionFromRoot(resellerid, option, value, *isfranch)
  begin
    if isfranch #если франч, то
      puts "#{time} переходим по ссылке редактирования опций нашего франча"
      @driver.navigate.to "http://root.abcp.ru/?page=reseller_edit_options&resellerId=#{resellerid}" #переходим по ссылке редактирования опций нашего франча
      resellername = 'test_' #присваиваем имени реселлера префикс города франча
    else #иначе
      puts "#{time} ищем в руте нашего реселлера по resellerid"
      @driver.navigate.to "http://root.abcp.ru/?search=#{resellerid}&page=customers" #ищем в руте нашего реселлера по resellerid
      resellername = @driver.find_element(:xpath, "//*[contains(text(),'#{resellerid}']../../../tr[2]/td[2]/div/a[1]") #сохраняем имя ресселлера, соответствующее id
      puts "#{time} переходим по ссылке редактирования опций реселлера"
      @driver.find_element(:xpath, "//*[@title='Опции #{resellername}']").click #переходим по ссылке редактирования опций реселлера
    end
    if @driver.find_elements(:xpath, "//*[contains(text(),'Редактирование реселлера #{resellername}')]").count == 1
      puts "#{time} находим строчку, которая указывает на то, что мы редактируем нашего тестового реселлера/франча"
      @driver.find_element(:xpath, "//*[contains(text(),'Редактирование реселлера #{resellername}')]") #находим строчку, которая указывает на то, что мы редактируем нашего тестового реселлера/франча
      sleep 1 #сек
      if @driver.find_elements(:xpath, "//*[@id='optionField']/option[@value='#{option}']").count == 1
        puts "#{time} выбираем новую опцию и выставляем ей значение"
        @driver.find_element(:xpath, "//*[@id='optionField']/option[@value='#{option}']").click #выбираем новую опцию
        @driver.find_element(:xpath, "//*[@id='valueField']/select/option[@value='#{value}']").click #выбираем значение новой опции
      else #иначе опция уже добавлена реселлеру
        puts "#{time} выбираем значение уже существующей опции"
        @driver.find_element(:xpath, "//*[@name='val_#{option}']/option[@value='#{value}']").click #выбираем значение уже существующей опции
      end
    else
      raise 'Редактирование опций чужого реселлера!'
    end
    puts "#{time} кликаем на кнопке 'Сохранить'"
    @driver.find_element(:id, 'submit').click #сохраняем
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end