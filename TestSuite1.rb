require 'selenium-webdriver'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

require_relative 'test1'
require_relative 'test2'
require_relative 'test3-4'
require_relative 'common.functions'

=begin
loop {
  #ждём 1 час
  sleep 3600
}
=end
