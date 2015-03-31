# encoding:utf-8

require 'x2ch'
include X2CH

bbs = Bbs.load
res = bbs['趣味']['アクアリウム'].threads.first.posts
puts res.status
puts res.last_modified
puts res.content_encoding
puts res.body_size

begin
  res = bbs['趣味']['アクアリウム'].threads.first.posts(res.last_modified.httpdate)
  puts res.status
  puts res.last_modified
  puts res.content_encoding
  puts res.body_size
rescue DownloadError => e
  puts e.message
end
