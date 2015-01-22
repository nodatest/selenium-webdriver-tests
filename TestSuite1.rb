require 'selenium-webdriver'
require_relative 'test1'
require_relative 'test2'
require_relative 'test3'
require_relative 'test4'
require_relative 'common.functions'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

#задаём массив тестов
tests = %w(formycar_noindex_existence formycar_no_redirect_and_available_results service_sites_noindex_existence formycar_noindex_miss)

#основная логика работы
logic(tests)