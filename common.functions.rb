#!/bin/env ruby
# encoding: utf-8
require 'json'
require 'net/http'

#получение ссылки в руте для перехода в пу
def cpLoginFromRoot(resellername=@resellername)
  begin
    puts "#{time} переходим в рут"
    @driver.navigate.to "http://root.abcp.ru#{@lan}/" #переходим в рут
    if @driver.find_elements(:css, '.inp').count > 0
      puts "#{time} вводим логин и пароль"
      @driver.find_element(:css, '.inp').send_keys('autotest') #вводим логин
      @driver.find_element(:name, 'pass').send_keys('123123') #вводим пароль
      puts "#{time} кликаем на кнопку вход"
      @driver.find_element(:name, 'go').click #кликаем на кнопку вход
    end
    puts "#{time} переходим по ссылке, которая отфильтровывает нашего тестового реселлера"
    @driver.navigate.to "http://root.abcp.ru#{@lan}/?search=#{resellername}&page=customers" #переходим по ссылке, которая отфильтровывает нашего тестового реселлера
    puts "#{time} получаем адрес ссылки для перехода в ПУ"
    link = @driver.find_element(:xpath, '//*[@class="q-login-menu"]/a[1]').attribute('href') #получаем адрес ссылки для перехода в пу
    link['http://cp.abcp.ru'] = "http://cp.abcp.ru#{@lan}" #если передан параметр lan, то адрес ссылки меняется на локальный
    puts "#{time} переходим в ПУ под Сотрудником НодаСофт"
    @driver.navigate.to link #переходим в пу под сотрудником нодасофт
    if @driver.find_elements(:xpath, "//*[contains(text(),'#{resellername}')]").count == 0 #проверяем, что мы перешли в ПУ выбранного
      @errors += 1
      puts "Выбран неверный реселлер '#{resellername}!".colorize(:red)
      raise "Выбран неверный реселлер '#{resellername}!"
    end
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
    if @clientid == /(\D{6,7}|0)/ or nil
      @errors += 1
      puts "Неверный id клиента #{@clientid}".colorize(:red)
      raise "Неверный id клиента #{@clientid}"
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
    sleep 1 #сек
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
    @franchid = @driver.find_element(:xpath, "//*[contains(.,'#{city}')]/../td[5]").text #сохраняем id франчайзи
    if @franchid == /(\D{6,7}|0)/ or nil
      @errors += 1
      puts "Неверный id франча #{@franchid}".colorize(:red)
      raise "Неверный id франча #{@franchid}"
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
    if @driver.find_elements(:xpath, '//*[@title="Купить"]').count > 0
      @driver.find_element(:xpath, '//*[@title="Купить"]').click #жмём кнопку добавить в корзину
    else
      @errors += 1
      puts 'Товара нет в наличии!'.colorize(:red)
      raise 'Товара нет в наличии!'
    end
    sleep 1 #сек
    if @driver.find_elements(:xpath, '//*[@role="dialog"]').count == 1 #проверяем не появляется ли модальное окно
      puts "#{time} кликаем 'Да' в появившемся модальном окне"
      @driver.find_element(:xpath, '//*[text()[class="ui-button-text"]]').click #кликаем 'Да'
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
    if @orderid == /(\D{6,7}|0)/ or nil
      puts @orderid
      @errors += 1
      puts "Неверный id заказа #{@orderid}".colorize(:red)
      raise "Неверный id заказа #{@orderid}"
    end
    check = @driver.find_elements(:xpath, '//*[@class="headCity logged" and contains(text(),"test_")]').count #если заказ сделан на франче
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
    if @driver.find_elements(:xpath, "//*[contains(text(),'#{@franchid}')]").count == 0
      @errors += 1
      puts "Залогинились под неверным франчем '#{@franchid}'!".colorize(:red)
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция установки значения опции реселлера/франча через рут
def setOptionFromRoot(resellerid, option, value, *isfranch)
  begin
    if isfranch #если франч, то
      puts "#{time} переходим по ссылке редактирования опций нашего франча"
      @driver.navigate.to "http://root.abcp.ru#{@lan}/?page=reseller_edit_options&resellerId=#{resellerid}" #переходим по ссылке редактирования опций нашего франча
      resellername = 'test_' #присваиваем имени реселлера префикс города франча
    else #иначе
      puts "#{time} ищем в руте нашего реселлера по resellerid"
      @driver.navigate.to "http://root.abcp.ru#{@lan}/?search=#{resellerid}&page=customers" #ищем в руте нашего реселлера по resellerid
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
      @errors += 1
      puts "Редактирование опций чужого реселлера '#{resellername}'!".colorize(:red)
      raise "Редактирование опций чужого реселлера '#{resellername}'!"
    end
    puts "#{time} кликаем на кнопке 'Сохранить'"
    @driver.find_element(:id, 'submit').click #сохраняем
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция сохранения id тестовых клиентов
def saveClients(days, *del)
  begin
    puts "#{time} переходим на вкладку 'Клиенты'"
    @driver.find_element(:link, 'Клиенты').click #кликаем на вкладке "Клиенты"
    unless del.empty? #если передан необязательный параметр del
      @driver.find_element(:xpath, "//*[contains(text(),'Удалённые')]").click #кликаем на радиобаттон "Удалённые клиенты",
      del = 'удалённых '
    else
      del = ''
    end
    days += 1
    date = (Time.now - 60*60*24*days).strftime('%d.%m.%Y') #дата, по которую необходимо удалять клиентов
    puts "#{time} вводим данные в поле 'Поиск'"
    @driver.find_element(:name, 'filterCustomersBySearchString').send_keys('test_user_') #вбиваем в поле "поиск"
    puts "#{time} вводим данные в поле 'Зарегестрированы по'"
    @driver.find_element(:id, 'dateRegTo').send_keys(date) #вбиваем в поле "зарегестрированы по"
    puts "#{time} кликаем на кнопке 'Найти'"
    @driver.find_element(:xpath, '//*[@value="Найти"]').click #кликаем на кнопке "Найти"
    sleep 5 #сек
    puts "#{time} сохраняем id клиентов на каждой из страниц"
    @clients = @driver.find_elements(:xpath, "//*[contains(text(),'test_user_')]/../td[2]").collect { |t| t.text } #сохраняем массив id клиентов на первой странице, преобразуя в текст
    while @driver.find_elements(:link, '>').count == 2 #до тех пор, пока есть кнопки следующей страницы
      @driver.find_element(:link, '>').click unless @driver.find_elements(:link, '>').count == 0 #кликаем на ссылке следующей страницы, до тех пор, пока кнопки следующей страницы не пропадут
      sleep 2 #сек
      @clients += @driver.find_elements(:xpath, "//*[contains(text(),'test_user_')]/../td[2]").collect { |t| t.text } #добавляем в массив id клиентов на этой странице, преобразуя в текст
    end
    puts "#{time} найдено #{@clients.count} #{del}тестовых клиентов"
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end


#функция удаления клиентов, старше days дней
def deleteClients(days)
  begin
    saveClients(days) #получаем список id зарегестрированных клиентов

    puts "#{time} переходим по ссылке редактирования клиента и удаляем клиента"
    if @clients.count > 0 #актуально, когда хоть один клиент найден
      @clients.sort.each do |i| #для каждого элемента массива, сортированного в порядке возрастания, выполняем
        @driver.get("http://cp.abcp.ru#{@lan}/?page=customers&customerId=#{i}&action=editCustomer") #переходим по ссылке редактирования клиента
        if @driver.find_elements(:xpath, "//*[contains(text(),'Системный код клиента:')]/../td[contains(text(),'#{i}')]").count == 1 #проверяем, что редактируем выбранного клиента
          deleteButton = @driver.find_elements(:xpath, "//*[@value='Удалить учетную запись']")
          if deleteButton.count == 1 #проверяем, что кнопка удаления есть на старнице
            deleteButton[0].click #кликаем по кнопке
            if @driver.find_elements(:xpath, "//*[contains(text(),'Вы действительно хотите удалить учётную запись пользователя?')]").count == 1 #проверяем, что появляется модальное окно
              @driver.find_element(:xpath, "//*[@value='OK']").click #кликаем по кнопке "ОК" в модальном окне
              if @driver.find_elements(:xpath, "//*[contains(text(),'Учетная запись клиента удалена!')]").count == 0 #если нет сообщения об успешном удалении
                @errors += 1
                puts 'Учетная запись клиента не удалена!'.colorize(:red)
              else
                puts "#{time} клиент #{i} удалён"
              end
            else
              @errors += 1
              puts 'Всплывающее окно не появилось!'.colorize(:red)
            end
          else
            @errors += 1
            puts 'Кнопка "Удалить" отсутствует!'.colorize(:red)
          end
        else
          @errors += 1
          puts "Выбран неверный id клиента #{i}!".colorize(:red)
        end
      end
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция удаления заказов, старше days дней
def deleteOrders(days)
  begin
    puts "#{time} переходим в ПУ"
    @driver.navigate.to "http://cp.abcp.ru#{@lan}" #переходим в пу
    puts "#{time} переходим на вкладку 'Заказы'"
    @driver.find_element(:link, 'Заказы').click #переходим на вкладку "Заказы"
    puts "#{time} переходим на вкладку 'Все заказы'"
    @driver.find_element(:link, 'Все заказы').click #переходим на вкладку "Все заказы"
    days += 1
    date = (Time.now - 60*60*24*days).strftime('%d.%m.%Y') #дата, по которую необходимо удалять заказы
    puts "#{time} вводим дату 'по'"
    @driver.execute_script("document.getElementById('date_to').setAttribute('value', '#{date}');") #вводим в задизейбленное поле средствами js дату по
    puts "#{time} кликаем по кнопке 'Применить фильтры'"
    @driver.find_element(:xpath, '//*[@value="Применить фильтры"]').click #кликаем по кнопке "Применить фильтры"
    sleep 2 #сек
    puts "#{time} сохраняем id заказов на каждой из страниц"
    orders = @driver.find_elements(:xpath, "//*[contains(text(),'test_user_')]/../..//*[@title='Подробнее']").collect { |t| t.text } #сохраняем в массив id заказов на первой странице, преобразуя их в текст
    while @driver.find_elements(:link, '>').count == 2 #до тех пор, пока есть кнопки следующей страницы
      @driver.find_element(:link, '>').click unless @driver.find_elements(:link, '>').count == 0 #кликаем на ссылке следующей страницы, до тех пор, пока кнопки следующей страницы не пропадут
      sleep 2 #сек
      orders += @driver.find_elements(:xpath, "//*[contains(text(),'test_user_')]/../..//*[@title='Подробнее']").collect { |t| t.text } #добавляем в массив id заказов на этой странице, преобразуя их в текст
    end
    puts "#{time} найдено #{orders.count} заказов"

    puts "#{time} переходим по ссылке редактирования заказа и удаляем его"
    if orders.count > 0 #актуально, когда хоть один заказ найден
      orders.sort.each do |i| #для каждого элемента массива, сортированного в порядке возрастания, выполняем
        @driver.get("http://cp.abcp.ru#{@lan}/?page=orders&id_order_hidden=#{i}") #переходим по ссылке редактирования клиента
        if @driver.find_elements(:xpath, "//*[contains(text(),'test_user_')]/../..//*[contains(text(),'#{i}')]").count == 1 #проверяем, что редактируем выбранного заказ от тестового клиента
          @driver.find_element(:xpath, "//*[@title='Удалить заказ']").click #кликаем на кнопке "Удалить заказ"
          @driver.switch_to.alert.accept #кликаем "ок" на всплывающем окне
          if @driver.find_elements(:xpath, "//*[contains(text(),'Заказ #{i} успешно удалён.')]").count == 1 #проверяем, что заказ был успешно удалён
            puts "#{time} заказ #{i} успешно удалён"
          else
            @errors += 1
            puts "Заказ #{i} не удалён!".colorize(:red)
          end
        else
          @errors += 1
          puts "Выбран неверный заказ #{i} или клиент!".colorize(:red)
        end
      end
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end

#функция удаления франчей, старше days дней
def deleteFranches(days)
  begin
    puts "#{time} переходим на вкладку 'Клиенты'"
    @driver.find_element(:link, 'Клиенты').click #переходим на вкладку "Клиенты"
    puts "#{time} переходим на вкладку 'Франчайзи'"
    #@driver.get "http://cp.abcp.ru#{@lan}/?page=customers&franchises&dropCache" #заглушка для локального запуска с ворнингами
    @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
    if @driver.find_elements(:xpath, "//*[contains(text(),'test_')]").count > 0 #актуально, когда хоть один тестовый франч есть
      franchClients = @driver.find_elements(:xpath, "//td[contains(text(),'test_')]/../td[4]").collect { |t| t.text } #сохраняем в массив id клиентов-основ франчей, преобразуя их в текст
      puts "#{time} сохранено в массив #{franchClients.count} id клиентов-основ тестовых франчей"

      puts "#{time} сохраняем список зарегистрированных тестовых клиентов"
      saveClients(days) #сохраняем список id клиентов
      activeClients = @clients #сохраняем список зарегистрированных клиентов
      puts "#{time} сохраняем список удалённых тестовых клиентов"
      saveClients(days, 'del') #сохраняем список удалённых id клиентов
      allClients = activeClients + @clients #прибавляем к списку зарегистрированных клиентов список удалённых клиентов
      puts "#{time} сохранено в массив всего #{allClients.count} тестовых клиентов"

      if allClients.count > 0 #актуально, когда хоть один клиент есть
        puts "#{time} переходим на вкладку 'Франчайзи'"
        @driver.find_element(:link, 'Франчайзи').click #переходим на вкладку "Франчайзи"
        matchClients = franchClients & allClients #оставляем в массиве только уникальные совпавшие id
        puts "#{time} совпавших клиентов и клиентов-основ франчей #{matchClients.count}"

        franches=[] #задаём пустой массив
        puts "#{time} сохраняем в массив список id франчей"
        if matchClients.count > 0 #если совпавших клиентов больше нуля
          matchClients.sort { |x, y| y <=> x }.each do |i| #для каждого элемента массива в обратном порядке выполняем
            franches << @driver.find_elements(:xpath, "//*[contains(text(),'#{i}')]/../../td[5]").collect { |t| t.text } #сохраняем в массив id франчей, преобразуя их в текст
          end

          puts "#{time} переходим в рут"
          @driver.get("http://root.abcp.ru#{@lan}/") #переходим в рут
          puts "#{time} переходим по сссылке 'Удалить реселлера'"
          @driver.find_element(:partial_link_text, 'Клиенты').send_key(:tab) #наводим фокус на выпадающее меню "Клиенты"
          @driver.find_element(:partial_link_text, 'Удалить реселлера').click #кликаем "Удалить реселлера"
          puts "#{time} удаляем тестовых франчей"
          franches.sort.each do |i| #для каждого элемента массива, сортированного в порядке возрастания, выполняем
            @driver.find_element(:xpath, "//*[@placeholder='Идентификатор или название реселлера']").send_keys(i) #вводим id франча
            #если элемент списка появился, то проверяем его, что он является именно нашим тестовым франчем и кликаем по нему
            sleep 2 #сек
            @driver.find_element(:xpath, "//*[contains(a, '(франчайзи)  test_')]").click #клик на элементе выпадающего списка с содержанием слов "франчайзи" и "test_"
            @driver.find_element(:xpath, "//*[@value='Удалить данные реселлера из БД']").click #клик на кнопке удаления
            @driver.switch_to.alert.accept #кликаем "ок" на всплывающем окне
            #@driver.find_element(:xpath, "//*[@placeholder='Идентификатор или название реселлера']").clear #заглушка для отладки
            if @driver.find_elements(:xpath, "//*[contains(text(),'Данные удалены успешно.')]").count == 1 #проверяем, что заказ был успешно удалён
              puts "#{time} франч #{i} удалён"
            else
              @errors += 1
              puts "Франч #{i} не удалён!".colorize(:red)
            end
          end
        else
          puts "#{time} нет ни одного совпавшего тестового клиента и клиента-основы франча"
        end
      else
        puts "#{time} ни одного тестового клиента нет"
      end
    else
      puts "#{time} ни одного тестового франча нет"
    end
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
  end
end
