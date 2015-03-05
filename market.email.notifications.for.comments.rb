#!/bin/env ruby
# encoding: utf-8


def market_email_notifications_for_comments(browser)

  @name = 'Проверка рассылки уведомлений владельцу и сотрудникам магазина об оставленных отзывах'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    cpLoginFromRoot #получение ссылки в руте для перехода в ПУ
=begin
    @driver.find_element(:link, '4MyCar').doubleclick
    @driver.find_element(:link, '4MyCar').click #переходим на вкладку "4MyCar"
    @driver.find_element(:id, 'name').send_keys('test_market') #вводим наименование организации
    @driver.find_element(:id, 'email').send_keys('test_market@selenium.noda.pro') #вводим контактный email
    @driver.find_element(:xpath, '//*[contains(text(),"Москва")]').click #выбираем регион "Москва"
    @driver.find_element(:id, 'street').send_keys('Пушкина') #вводим улицу
    @driver.find_element(:id, 'building').send_keys('100') #вводим номер дома
    @driver.find_element(:name, 'newContactValue[]').send_keys('+7 (900) 123-45-67') #вводим номер телефона
    @driver.find_element(:xpath, '//*[contains(text(),"Легковые")]').click #выбираем специализацию
    @driver.find_element(:xpath, '//*[contains(text(),"Розница")]').click #выбираем опт
    @driver.find_element(:xpath, '//*[@value="Сохранить"]').click #кликаем кнопку сохранить

  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
=end


  end

  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end