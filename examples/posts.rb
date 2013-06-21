# encoding: utf-8

require 'x2ch'
include X2CH

bbs = Bbs.load
bbs['趣味']['アクアリウム'].threads.first.each{|post|
    puts "#{post.name} <> #{post.mail} <> #{post.metadata} <> #{post.body}"
}
