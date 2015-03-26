# encoding: utf-8

require 'x2ch'
include X2CH

bbs = Bbs.load
bbs.each{|category|
  puts '- ' + category.name
  category.each{|board|
    puts ' - ' + board.name
  }
}
