#!/bin/env ruby
# encoding: utf-8
require 'optparse'

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
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--name NAME', 'test name') { |n| @options[:name] = n }
  end.parse!

  if @options[:lan] == true
    @lan = '.lan'
  end
end

#функция включения логирование в файл и проверки условия, при котором происходит запуск браузера
def initializebrowserandlog(browser)

  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #запускаем браузер
    seleniumdriver(browser)
  end

  #лог выполнения тестов
  $stdout = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
end

#инициализируем запуск браузера
def seleniumdriver(browser)
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds
  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
end

#функция проверки условия, при котором происходит выход из браузера
def brwoserquit
  #если НЕ установлен параметр запуска тестов в одном бразуере
  if @options[:aio].nil? == true
    #выходим из браузера
    @driver.quit
  end
end

#функция с основной логикой работы
def logic(tests)

  #обрабатываем параметры командной строки
  options

  #задаём массив браузеров
  browsers = %w(chrome firefox)

  #если задано имя функции теста
  if @options[:name].nil? == false
    #лог выполнения тестов
    $stdout = File.open("../selenium-webdriver-logs/chrome_#{date}.txt", 'a')
    #запускаем браузер
    seleniumdriver(browsers[0])
    #выполняем тест
    send("#{@options[:name]}".to_sym)
    #выходим из браузера
    @driver.quit
  else
    loop {
      for i in 0 ... browsers.size

        #если установлен параметр запуска тестов в одном бразуере
        if @options[:aio] == true
          #запускаем браузер
          seleniumdriver(browsers[i])
        end

        for y in 0 ... tests.size
          #запускаем браузер и включаем логирование
          initializebrowserandlog(browsers[i])
          #выполняем тест
          send("#{tests[y]}")
          #закрываем файл лога
          $stdout.flush
          #выходим из браузера
          brwoserquit
        end

        #если установлен параметр запуска тестов в одном бразуере
        if @options[:aio] == true
          #выходим из браузера
          @driver.quit
        end
      end

      #ждём 1 час
      sleep 3600
    }
  end
end