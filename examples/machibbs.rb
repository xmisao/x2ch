# coding:utf-8
require 'x2ch'
include X2CH

bbs = Bbs.load
thread = bbs['まちＢＢＳ']['神奈川'].threads.first
p thread

thread.each{|post|
  p post
}
