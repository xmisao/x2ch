# x2ch

- [https://rubygems.org/gems/x2c](https://rubygems.org/gems/x2ch)
- [https://github.com/xmisao/x2ch](https://github.com/xmisao/x2ch)

## 概要

x2chは2chのダウンローダとパーサを備えたライブラリです。
このライブラリを使うとRubyで簡単に2chにアクセスできます。

## 使用例

2chのカテゴリーと板一覧を取得する。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs.each{|categorty|
    	puts '+- ' + category.name
    	category.each{|board|
    		puts '    +- ' + board.name	
    	}
    }

カテゴリー「趣味」の「アクアリウム」板のスレッド一覧を取得する。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs['趣味']['アクアリウム'].each{|thread|
    	puts thread.name + thread.num
    }

アクアリウム板の最初のスレッドの投稿を取得する。

    require 'x2ch'
    include X2CH
    
    bbs = Bbs.load
    bbs['趣味']['アクアリウム'].threads.first.each{|post|
    	puts "#{post.name} <> #{post.mail} <> #{post.metadata} <> #{post.body}"
    }

## 作者

- [xmisao](http://www.xmisao.com/)

## license

This library is distributed under the MIT license.
