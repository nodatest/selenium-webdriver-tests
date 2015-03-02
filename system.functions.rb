#!/bin/env ruby
# encoding: utf-8
require 'optparse'
require 'logger'
=begin
require 'unicode'

=begin
#класс конвертации русских букв в различные регистры
class String
  def downcase
    Unicode::downcase(self)
  end

  def downcase!
    self.replace downcase
  end

  def upcase
    Unicode::upcase(self)
  end

  def upcase!
    self.replace upcase
  end

  def capitalize
    Unicode::capitalize(self)
  end

  def capitalize!
    self.replace capitalize
  end
end
=end

#класс для одновременного логирования в терминал и в файл
class MultiDelegator
  def initialize(*targets)
    @targets = targets
  end

  def self.delegate(*methods)
    methods.each do |m|
      define_method(m) do |*args|
        @targets.map { |t| t.send(m, *args) }
      end
    end
    self
  end

  class <<self
    alias to new
  end
end

#время начала выполнения теста
def time()
  time = Time.now.strftime('%H:%M:%S')
end

#дата
def date
  date = Time.now.strftime('%d-%m-%Y')
end

#параметры в командной строке
def options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'
    opts.on('-a', '--all-tests-in-one-browser', 'all tests in one browser') { |a| @options[:aio] = a }
    opts.on('-b', '--browser NAME', 'set browser (chrome/firefox)') { |b| @options[:browser] = b }
    opts.on('-f', '--fullscreen', 'fullscreen mode') { |f| @options[:fullscreen] = f }
    opts.on('-l', '--lan', 'use local code') { |l| @options[:lan] = l }
    opts.on('-n', '--name NAME', 'test name') { |n| @options[:name] = n }
  end.parse!

  @lan = '.lan' if @options[:lan]

  #задаём массив браузеров в зависимости от переданного параметра -b
  case @options[:browser]
    when 'firefox'
      @browser = %w(firefox)
    when 'chrome'
      @browser = %w(chrome)
    else
      @browser = %w(chrome firefox)
  end
end

#функция проверки параметров запуска тестов в одном бразуере + включения логирования в файл
def checkparametersandlog(browser)
  @errors = 0 # задаём кол-во ошибок в начале теста

  #если НЕ установлен параметр запуска тестов в одном бразуере
  startBrowser(browser) unless @options[:aio]

  #лог выполнения тестов
  log_file = File.open("../selenium-webdriver-logs/#{browser}_#{date}.txt", 'a')
  $stdout = MultiDelegator.delegate(:write, :close, :puts, :flush).to(STDOUT, log_file)
  puts @name.colorize(:green)
end

#функция запуска браузера
def startBrowser(browser)
  @client = Selenium::WebDriver::Remote::Http::Default.new
  @client.timeout = 120 # seconds
  @driver = Selenium::WebDriver.for(:"#{browser}", :http_client => @client)
  if @lan
    @driver.manage.timeouts.implicit_wait = 15 # seconds
  else
    @driver.manage.timeouts.implicit_wait = 5 # seconds
  end

  #если установлен параметр запуска бразуера в полнооконном режиме
  @driver.manage.window.maximize if @options[:fullscreen]
end

#функция подсчёта всех ошибок, их вывода, сбрасывания записей в лог, выхода из браузера, если надо
def countTotalErrorsFlushLogBrowserQuit
  @totalerrors += @errors #прибавляем кол-во ошибок к общему

  if @errors == 0
    puts "info: тест завершён. кол-во ошибок - #{@errors}".colorize(:green)
  else
    puts "info: тест завершён. кол-во ошибок - #{@errors}".colorize(:red)
  end

  #скидываем данные в лог
  $stdout.flush

  #если НЕ установлен параметр запуска тестов в одном бразуере
  @driver.quit unless @options[:aio]
end

#функция подсчёта ошибок и снятия скриншота
def countErrorsTakeScreenshot
  @errors += 1
  @driver.save_screenshot("../screenshots/#{date} #{time} #{@name}.png")
end

#функция удаления старых скриншотов
def deleteScreenshots(path, days)
  files = Dir.new(path).entries #сохраняем имена файлов и директорий
  files.delete('.') #избавляемся от стандартной директории (текущей)
  files.delete('..') #избавляемся от стандартной директории (корневой)
  files.each do |i|
    file = "#{path}/#{i}" #прибавляем к имени путь
    File.delete(file) if Time.now - File.ctime(file) > 60*60*24*days #удаляем файл, если он дата его создания больше days дней
  end
end
