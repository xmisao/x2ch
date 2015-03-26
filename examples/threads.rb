# encoding: utf-8

require 'x2ch'
include X2CH

bbs = Bbs.load
bbs['趣味']['アクアリウム'].each{|thread|
  puts thread.name + '(' + thread.num.to_s + ')'
}
