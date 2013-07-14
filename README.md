# x2ch

- [https://rubygems.org/gems/x2c](https://rubygems.org/gems/x2ch)
- [https://github.com/xmisao/x2ch](https://github.com/xmisao/x2ch)

## Description

x2chは2chのダウンローダとパーサを備えたライブラリです。
このライブラリを使うとRubyで簡単に2chにアクセスできます。

## Install

    gem install x2ch

## Examples

2chのカテゴリーと板一覧を取得する。
なおサーバからのダウンロードはgzipに対応しています。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs.each{|category|
        puts '- ' + category.name
        category.each{|board|
            puts ' - ' + board.name 
        }
    }

カテゴリー「趣味」の「アクアリウム」板のスレッド一覧を取得する。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs['趣味']['アクアリウム'].each{|thread|
        puts thread.name + '(' + thread.num.to_s + ')'
    }

アクアリウム板の最初のスレッドの投稿を取得する。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs['趣味']['アクアリウム'].threads.first.each{|post|
        puts "#{post.name} <> #{post.mail} <> #{post.metadata} <> #{post.body}"
    }

posts等の返却値はX2CH::Responseモジュールにより拡張されているため、レスポンスの情報を取得できます。
これによりLast-Modifiedに基づいて、If-Modified-Sinceによる更新確認が行えます。

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

## Author

- [xmisao](http://www.xmisao.com/)

## License

This library is distributed under the MIT license.
