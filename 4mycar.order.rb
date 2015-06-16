#!/bin/env ruby
# encoding: utf-8

#Заказ на сайте 4mycar.ru
def formycar_order(browser)

  @name = 'Заказ на сайте 4mycar.ru'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin

    @driver.get("http://4mycar.ru#{@lan}")
    search('Knecht', 'OC90')

    @driver.find_element(:xpath, '//*[contains(text(),"Опт")]').click

    sleep 5

    if @driver.find_elements(:partial_link_text, 'о продавце').count == 10
      puts "#{time} Кнопка в результатах поиска называется верно"
    else
      puts "#{time} Кнопка в результатах поиска называется неверно!".colorize(:red)
      @error += 1
    end

    sellerId = @driver.find_element(:partial_link_text, 'о продавце').attribute('href').delete("http://4mycar.ru#{@lan}/shop/")

    dbparams = {'host' => '10.93.18.11', 'login' => 'abcp_autotest', 'password' => '5rqZEJanRRPvNxws', 'database' => 'order-api'}

    if @lan then
      clientIp = '10.0.4.254'
    else
      clientIp = '89.249.%'
    end

    query = "SELECT * FROM ContactsReview WHERE resellerId = 13194 AND sellerId = #{sellerId} AND clientIp LIKE '#{clientIp}' AND date >= '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' AND type = 1 LIMIT 5;"

    @driver.find_element(:partial_link_text, 'о продавце').click
    @driver.find_element(:partial_link_text, 'оставить свой').click

    sleep 3

    dbConnector(dbparams, query)

    if @n_rows == 2
      puts "#{time} В таблице ContactsReview 2 записи - всё ок"
    else
      puts "#{time} В таблице ContactsReview не 2 записи - ошибка!".colorize(:red)
      @error += 1
    end

    tabs = @driver.window_handles
    @driver.close
    @driver.switch_to.window(tabs[1])
    @driver.close
    @driver.switch_to.window(tabs[2])

    if @driver.find_elements(:xpath, '//*[contains(text(),"Опт")]').count == 1
      puts "#{time} В карточке продавца предупреждение выводится верно 'Опт'"
    else
      puts "#{time} В карточке продавца предупреждения 'Опт' нет либо оно выводится несколько раз!".colorize(:red)
      @error += 1
    end

    if @driver.find_elements(:xpath, '//*[contains(text(),"Купить")]').count == 0
      puts "#{time} В карточке продавца больше нет старой кнопки 'Купить'"
    else
      puts "#{time} В карточке продавца осталась старая кнопка 'Купить'!".colorize(:red)
      @error += 1
    end

    if @driver.find_elements(:xpath, '//*[contains(text(),"Послать заказ продавцу")]').count == 0
      puts "#{time} В карточке продавца больше нет кнопки 'Купить'"
    else
      puts "#{time} В карточке продавца осталась кнопка 'Купить'!".colorize(:red)
      @error += 1
    end

    if @driver.find_elements(:xpath, '//*[contains(text(),"я увидел, что цена указана для заказов от")]').count == 0
      puts "#{time} В карточке продавца нет предупреждения о мин. цене"
    else
      puts "#{time} В карточке продавца есть предупреждения о мин. цене!".colorize(:red)
      @error += 1
    end

    if @driver.find_elements(:xpath, '//*[contains(text(),"я прочитал сообщение от магазина")]').count == 0
      puts "#{time} В карточке продавца нет текста доп. инфо поставщика"
    else
      puts "#{time} В карточке продавца есть текст доп. инфо поставщика!".colorize(:red)
      @error += 1
    end

    query = "SELECT * FROM GoToSite WHERE resellerId = 13194 AND sellerId = #{sellerId} AND clientIp LIKE '89.249.%' AND date >= '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' LIMIT 5;"

    @driver.find_element(:id, 'siteLink').click

    sleep 3

    dbConnector(dbparams, query)

    if @n_rows == 1
      puts "#{time} В таблице GoToSite 1 запись - всё ок"
    else
      puts "#{time} В таблице GoToSite не 1 запись - ошибка!".colorize(:red)
      @error += 1
    end

    tabs = @driver.window_handles
    @driver.close
    @driver.switch_to.window(tabs.last)
###############################################


    @driver.get("http://4mycar.ru#{@lan}")
    search('Febi', '01089')

    @driver.find_element(:xpath, '//*[contains(text(),"Розница")]').click unless @driver.find_element(:xpath, '//*[contains(text(),"Розница")]').enabled?

    if @driver.find_elements(:partial_link_text, 'купить').count == 31
      puts "#{time} Кнопка в результатах поиска называется верно"
    else
      puts "#{time} Кнопка в результатах поиска называется неверно!".colorize(:red)
      @error += 1
    end

    sellerId = @driver.find_elements(:partial_link_text, 'оставить свой')[1].attribute('href').sub!("http://4mycar.ru#{@lan}/shop/", '')

    dbparams = {'host' => '10.93.18.11', 'login' => 'abcp_autotest', 'password' => '5rqZEJanRRPvNxws', 'database' => 'order-api'}

    query = "SELECT * FROM ContactsReview WHERE resellerId = 13194 AND sellerId = #{sellerId} AND clientIp LIKE '89.249.%' AND date >= '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' AND type = 1 LIMIT 5;"

    @driver.find_elements(:partial_link_text, 'купить')[2].click
    price = @driver.find_elements(:class, 'priceSaleOutRight')[1].text
    @driver.find_elements(:partial_link_text, 'оставить свой')[1].click

    sleep 3

    dbConnector(dbparams, query)

    if @n_rows == 2
      puts "#{time} В таблице ContactsReview 2 записи - всё ок"
    else
      puts "#{time} В таблице ContactsReview не 2 записи - ошибка!".colorize(:red)
      @error += 1
    end

    for i in 1..2
      tabs = @driver.window_handles
      @driver.switch_to.window(tabs[i])

=begin
      if i == 1
        @driver.close
        @driver.switch_to.window(tabs[i])
      else
        @driver.switch_to.window(tabs.last)
        @driver.close
        @driver.switch_to.window(tabs[1])
      end
=end

      if @driver.find_elements(:xpath, '//*[contains(text(),"Розница")]').count == 1
        puts "#{time} В карточке продавца предупреждение выводится верно 'Розница'"
      else
        puts "#{time} В карточке продавца предупреждения 'Розница' нет либо оно выводится несколько раз!".colorize(:red)
        @error += 1
      end

      if @driver.find_elements(:xpath, '//*[contains(text(),"Купить")]').count == 0
        puts "#{time} В карточке продавца больше нет старой кнопки 'Купить'"
      else
        puts "#{time} В карточке продавца осталась старая кнопка 'Купить'!".colorize(:red)
        @error += 1
      end

      query = "SELECT * FROM GoToSite WHERE resellerId = 13194 AND sellerId = #{sellerId} AND clientIp LIKE '89.249.%' AND date >= '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' LIMIT 5;"

      @driver.find_element(:id, 'siteLink').click

      sleep 3

      dbConnector(dbparams, query)

      if @n_rows == 1
        puts "#{time} В таблице GoToSite 1 запись - всё ок"
      else
        puts "#{time} В таблице GoToSite не 1 запись - ошибка!".colorize(:red)
        @error += 1
      end
    end

    partPrice = @driver.find_element(:id, 'partPrice').text

    if partPrice == price
      puts "#{time} Цены в поиске и в карточке продавца совпадают - всё ок"
    else
      puts "#{time} Цены в поиске и в карточке продавца не совпадают - ошибка!".colorize(:red)
      @error += 1
    end

    if @driver.find_elements(:xpath, '/html/body/div[2]/div[2]/div[3]/div/div/table/tbody/tr/td[1]/div[1]/div[2]').count == 1
      puts "#{time} Форма покупки находится в верхнем сером блоке - всё ок"
    else
      puts "#{time} Вероятно, форма покупки уже не находится в верхнем сером блоке - ошибка!".colorize(:red)
      @error += 1
    end

=begin
    tabs = @driver.window_handles
    @driver.switch_to.window(tabs.last)
    @driver.close
    @driver.switch_to.window(tabs.first)
    @driver.close
=end

  end
end
