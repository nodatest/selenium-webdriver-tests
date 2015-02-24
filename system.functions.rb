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
  time = Time.now.strftime('%d-%m-%Y %H-%M-%S')[11, 8]
end

#дата
def date
  date = Time.now.strftime('%d-%m-%Y %H-%M-%S')[0, 10]
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

  if @options[:aio]
    puts 'info: тесты выполняются в одном браузере'
  else
    puts 'info: каждый тест в отдельном браузере'
  end

  puts 'info: запускаем весь тестовый набор' unless @options[:name]

  if @options[:lan]
    @lan = '.lan'
    puts 'info: локальный запуск'
  else
    puts 'info: нелокальный запуск'
  end

  puts 'info: во весь экран' if @options[:fullscreen]

  #задаём массив браузеров в зависимости от переданного параметра -b
  case @options[:browser]
    when 'firefox'
      @browser = %w(firefox)
    when 'chrome'
      @browser = %w(chrome)
    else
      @browser = %w(chrome firefox)
  end

  if @options[:name]
    puts "info: используемый бразуер: #{@browser[0]}"
  else
    puts "info: используемые бразуеры: #{@browser}"
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