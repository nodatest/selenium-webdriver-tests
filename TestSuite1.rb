require 'selenium-webdriver'
require_relative 'test1'
require_relative 'test2'
require_relative 'test3'
require_relative 'test4'
require_relative 'common.functions'
require 'optparse'

#выводим ошибки ruby в файл
$stderr = File.open('../selenium-webdriver-logs/!errors_log.txt', 'w')

options

puts @options[:number]

if @options[:number].nil? == false
  startTest(@options[:number], 'chrome')
else
  loop {
    #тест1
    startTest(1, 'chrome')
    startTest(1, 'firefox')

    #тест2
    startTest(2, 'chrome')
    startTest(2, 'firefox')

    #тест3
    startTest(3, 'chrome')
    startTest(3, 'firefox')

    #тест4
    startTest(4, 'chrome')
    startTest(4, 'firefox')

    #ждём 1 час
    sleep 3600
  }
end
