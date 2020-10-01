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

  i = 0
  while i < length
    pool = pool.shuffle
    chosen = pool[rand(pool.length)]
    password += chosen.char
    if symbol_count < max_symbols && chosen.type == Type::SYMBOL
      symbol_count += 1
      pool.reject! { |e| e.type == Type::SYMBOL } if symbol_count == max_symbols
    end
    pool.reject! { |e| e.char == chosen.char } if unique_chars
    i += 1
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

pool = [
  Character.new('a', Type::LOWER), Character.new('b', Type::LOWER),
  Character.new('c', Type::LOWER), Character.new('d', Type::LOWER),
  Character.new('e', Type::LOWER), Character.new('f', Type::LOWER),
  Character.new('g', Type::LOWER), Character.new('h', Type::LOWER),
  Character.new('i', Type::LOWER), Character.new('j', Type::LOWER),
  Character.new('k', Type::LOWER), Character.new('l', Type::LOWER),
  Character.new('m', Type::LOWER), Character.new('n', Type::LOWER),
  Character.new('o', Type::LOWER), Character.new('p', Type::LOWER),
  Character.new('q', Type::LOWER), Character.new('r', Type::LOWER),
  Character.new('s', Type::LOWER), Character.new('t', Type::LOWER),
  Character.new('u', Type::LOWER), Character.new('v', Type::LOWER),
  Character.new('w', Type::LOWER), Character.new('x', Type::LOWER),
  Character.new('y', Type::LOWER), Character.new('z', Type::LOWER),
  Character.new('A', Type::UPPER), Character.new('B', Type::UPPER),
  Character.new('C', Type::UPPER), Character.new('D', Type::UPPER),
  Character.new('E', Type::UPPER), Character.new('F', Type::UPPER),
  Character.new('G', Type::UPPER), Character.new('H', Type::UPPER),
  Character.new('I', Type::UPPER), Character.new('J', Type::UPPER),
  Character.new('K', Type::UPPER), Character.new('L', Type::UPPER),
  Character.new('M', Type::UPPER), Character.new('N', Type::UPPER),
  Character.new('O', Type::UPPER), Character.new('P', Type::UPPER),
  Character.new('Q', Type::UPPER), Character.new('R', Type::UPPER),
  Character.new('S', Type::UPPER), Character.new('T', Type::UPPER),
  Character.new('U', Type::UPPER), Character.new('V', Type::UPPER),
  Character.new('W', Type::UPPER), Character.new('X', Type::UPPER),
  Character.new('Y', Type::UPPER), Character.new('Z', Type::UPPER),
  Character.new('1', Type::NUMBER), Character.new('2', Type::NUMBER),
  Character.new('3', Type::NUMBER), Character.new('4', Type::NUMBER),
  Character.new('5', Type::NUMBER), Character.new('6', Type::NUMBER),
  Character.new('7', Type::NUMBER), Character.new('8', Type::NUMBER),
  Character.new('9', Type::NUMBER), Character.new('0', Type::NUMBER),
  Character.new('/', Type::SYMBOL), Character.new('!', Type::SYMBOL),
  Character.new('@', Type::SYMBOL), Character.new('#', Type::SYMBOL),
  Character.new('$', Type::SYMBOL), Character.new('%', Type::SYMBOL),
  Character.new('^', Type::SYMBOL), Character.new('&', Type::SYMBOL),
  Character.new('*', Type::SYMBOL), Character.new('(', Type::SYMBOL),
  Character.new(')', Type::SYMBOL), Character.new('[', Type::SYMBOL),
  Character.new(']', Type::SYMBOL), Character.new('{', Type::SYMBOL),
  Character.new('}', Type::SYMBOL), Character.new(':', Type::SYMBOL),
  Character.new(';', Type::SYMBOL), Character.new('<', Type::SYMBOL),
  Character.new('>', Type::SYMBOL), Character.new(',', Type::SYMBOL),
  Character.new('.', Type::SYMBOL), Character.new('/', Type::SYMBOL),
  Character.new('?', Type::SYMBOL), Character.new('`', Type::SYMBOL),
  Character.new('~', Type::SYMBOL), Character.new(' ', Type::SYMBOL)
]

params = parse_args

length = if params.key?('length')
           [Integer(params['length']), 40].min
         else
           16
         end

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
  exit
end

if params.key?('no-symbols') && params.key?('no-digits') &&
   params.key?('no-upper') && params.key?('no-lower')
  puts 'No characters are allowed!'
  exit
end

pool.reject! { |c| c.type == Type::SYMBOL } if params.key?('no-symbols')
pool.reject! { |c| c.type == Type::NUMBER } if params.key?('no-digits') ||
                                               params.key?('no-numbers')
pool.reject! { |c| c.type == Type::UPPER } if params.key?('no-upper')
pool.reject! { |c| c.type == Type::LOWER } if params.key?('no-lower')
max_symbols = Integer(params['max-symbols']) if params.key?('max-symbols')
pw = generate(length, pool, max_symbols || length, params.key?('unique-chars')).chars.shuffle
puts pw.join
