#!/usr/bin/env ruby

module Type
  LOWER = 1
  UPPER = 2
  NUMBER = 3
  SYMBOL = 4
end

class Character
  attr_reader :char
  attr_reader :type

  def initialize(char, type)
    @char = char
    @type = type
  end
end

# @return [String]
def generate(length, pool, max_symbols, unique_chars = false)
  password = ''
  pool.reject! { |e| e.char == password } if unique_chars
  symbol_count = 0

  (0...length).each do |_|
    pool = pool.shuffle
    chosen = pool[rand(pool.length)]
    password += chosen.char
    if symbol_count < max_symbols && chosen.type == Type::SYMBOL
      symbol_count += 1
      pool.reject! { |e| e.type == Type::SYMBOL } if symbol_count == max_symbols
    end
    pool.reject! { |e| e.char == chosen.char } if unique_chars
  end

  password
end

def parse_args
  nil if ARGV.empty?
  all_args = {}

  ARGV.each do |arg|
    next unless arg.start_with?('--')

    arg_key = arg[2..arg.length].downcase
    if arg_key.include?('=')
      k, v = arg_key.split('=')
      all_args[k] = v
    else
      all_args[arg_key] = true
    end
  end
  all_args
end

params = parse_args

if params.key?('help')
  puts 'passgen.rb'
  puts 'Usage: passgen [OPTION]...'
  puts 'Generate a password'
  puts '  --length=NUMBER         Specify the length of the password generated to NUMBER characters.'
  puts '  --no-symbols            Disallow symbols in password generation.'
  puts '  --no-digits             Disallow numbers in password generation.'
  puts '  --no-lower              Disallow lowercase letters in password generation.'
  puts '  --no-upper              Disallow uppercase letters in password generation.'
  puts '  --unique-chars          Characters can only be used once in password generation.'
  puts '  --max-symbols=NUMBER    Limit the amount of symbols to NUMBER.'
  puts '  --shuffles=NUMBER       Shuffles the password NUMBER of times.'
  exit
end

pool = (32..126).collect do |i|
  if i.between?(65, 90) # ASCII uppercase
    char_type = Type::UPPER
  elsif i.between?(97, 122) # ASCII lowercase
    char_type = Type::LOWER
  elsif i.between?(48, 57) # ASCII digits
    char_type = Type::NUMBER
  else # ASCII symbols
    char_type = Type::SYMBOL
  end
  Character.new(i.chr, char_type)
end

pool.reject! { |c| c.type == Type::SYMBOL } if params.key?('no-symbols')
pool.reject! { |c| c.type == Type::NUMBER } if params.key?('no-digits') ||
  params.key?('no-numbers')
pool.reject! { |c| c.type == Type::UPPER } if params.key?('no-upper')
pool.reject! { |c| c.type == Type::LOWER } if params.key?('no-lower')

length = if params.key?('length')
           [Integer(params['length']), 60].min
         else
           16
         end

if params.key?('no-symbols') && params.key?('no-digits') &&
   params.key?('no-upper') && params.key?('no-lower')
  puts 'No characters are allowed!'
  exit
end

max_symbols = (Integer(params['max-symbols']) if params.key?('max-symbols')) || length
shuffles = (Integer(params['shuffles']) if params.key?('shuffles')) || 0
pw = generate(length, pool, max_symbols, params.key?('unique-chars')).chars
(0..shuffles).each do |_|
  pw.shuffle!
end if params.key?('shuffles') and shuffles > 0
puts pw.join
