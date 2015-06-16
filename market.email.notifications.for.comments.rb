#!/bin/env ruby
# encoding: utf-8

def market_email_notifications_for_comments(browser)

  employeeLastnames = %w(admin test_admin2 test_employee) #массив фамилий сотрудников
  employeeRoles = ['Администратор', 'Администратор', 'Менеджер по продажам'] #массив ролей сотрудников
  employeeEmails = ['vmolchanov@nodasoft.com', "#{employeeLastnames[1]}@#{@resellername}", "#{employeeLastnames[2]}@#{@resellername}"] #массив email'ов сотрудников
  alertEmails = %w(vmolchanov@nodasoft.com test@gmail.com test@aol.com) #массив email'ов сотрудников для оповещений

  @name = 'Проверка рассылки уведомлений владельцу и сотрудникам магазина об оставленных отзывах'

  #проверяем часть переданных параметров командной строки и включаем логирование
  checkparametersandlog(browser)

  begin
    puts "#{time} получение ссылки в руте для перехода в ПУ"
    cpLoginFromRoot #получение ссылки в руте для перехода в ПУ

    puts "#{time} заполняем карточку магазина"
    editMarketCard #заполняем карточку магазина

    recoverEmployees(employeeEmails) #восстанавливаем удалённых сотрудников

    @driver.find_element(:link, 'Персонал').click #переходим по ссылке "Персонал"

    activeEmployeeEmails = @driver.find_elements(:xpath, '//tr[*]/td[5]').each.map { |t| t.text } #сохраняем массив email'ов активных сотрудников
    editEmployeeEmails = employeeEmails & activeEmployeeEmails #сохраняем массив из совпавших email'ов активных и наших тестовых

    addOrEditEmployees('edit', employeeLastnames, employeeRoles, editEmployeeEmails) #редактируем сотрудников

    newEmployeeEmails = employeeEmails - editEmployeeEmails #задаём массив несозданных сотрудников

    addOrEditEmployees('add', employeeLastnames, employeeRoles, newEmployeeEmails) #добавляем сотрудников

    deleteAlertEmail(employeeLastnames) #удаляем email'ы наших тестовых сотрудников для оповещений

    addAlertEmail(employeeLastnames, alertEmails) #добавляем email'ы наших тестовых сотрудников для оповещений

=begin
  rescue
    countErrorsTakeScreenshot #подсчитываем ошибки и делаем скриншот
=end
  end
  countTotalErrorsFlushLogBrowserQuit #подсчитываем общее кол-во ошибок, выводим их, скидываем записи в лог, выходим из браузера, если надо
end