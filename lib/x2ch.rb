# encoding: utf-8

require 'open-uri'
require 'kconv'
require 'zlib'

module X2CH
  class Bbs
    attr_accessor :categories

    def initialize()
      @categories = []
    end

    def [](cname)
      @categories.each{|c|
        return c if c.name == cname
      }
      nil
    end

    def push(category)
      @categories << category
    end

    def each(&blk)
      @categories.each{|c|
        yield c
      }
    end

    def self.load()
      BbsMenu.parse(BbsMenu.download)
    end
  end

  class Category
    attr_accessor :name, :boards

    def initialize(name)
      @name = name
      @boards = []
    end

    def [](bname)
      @boards.each{|b|
        return b if b.name == bname
      }
      nil
    end

    def push(board)
      @boards << board
    end

    def each(&blk)
      @boards.each{|b|
        yield b
      }
    end
  end

  class Board
    attr_accessor :url, :name

    def initialize(url, name)
      @url, @name = url, name
    end

    def threads()
      Subject.parse(@url, Subject.download(@url + '/subject.txt'))
    end

    def each(&blk)
      threads.each{|t|
        yield t
      }
    end
  end

  class Thread
    attr_accessor :url, :dat, :name, :num

    def initialize(url, dat, name, num)
      @url, @dat, @name, @num = url, dat, name, num
    end

    def posts(if_modified_since = nil, range = nil)
      if @url.match(/machi.to/)
        part = @url.match(/^(http:\/\/.+?)\/(.+?)\//).to_a
        res = Dat.download(part[1] + "/bbs/offlaw.cgi/" + part[2] + '/' + @dat.sub('.cgi', ''), if_modified_since, range)
      else
        res = Dat.download(@url + "dat/" + @dat, if_modified_since, range)
      end
      ArrayResponse.new(Dat.parse(res), res.status, res.last_modified, res.content_encoding, res.body_size)
    end

    def each(&blk)
      posts.each{|p|
        yield p
      }
    end
  end

  class Post
    attr_accessor :name, :mail, :metadata, :body

    def initialize(name, mail, metadata, body)
      @name, @mail, @metadata, @body = name, mail, metadata, body
    end
  end

  class Agent
    def self.download(url, if_modified_since = nil, range = nil)
      header = {"User-Agent" => "Monazilla/1.00 (x2ch/0.9.1)", "Accept-Encoding" => 'gzip'}
      if if_modified_since
        header["If-Modified-Since"] = if_modified_since
      end
      if range
        header["Range"] = range
      end
      begin
        res = open(url, header){|f|
          body = nil
          if f.content_encoding.index('gzip')
            body = Zlib::GzipReader.new(f).read.toutf8
          else
            body = f.read.toutf8
          end
          [body, f.status, f.last_modified, f.content_encoding, body.size]
        }
      rescue OpenURI::HTTPError => e
        raise DownloadError.new(e.message)
      end
      StringResponse.new(res[0], res[1], res[2], res[3], res[4])
    end
  end

  class DownloadError < StandardError ; end

  module Response
    attr_accessor :status, :last_modified, :content_encoding, :body_size

    def initialize(obj, status, last_modified, content_encoding, body_size)
      @status, @last_modified, @content_encoding, @body_size = status, last_modified, content_encoding, body_size
      super(obj)
    end
  end

  class StringResponse < String
    include Response
  end

  class ArrayResponse < Array
    include Response
  end

  class BbsMenu
    IGNORE_CATEGORIES = ['特別企画', 'チャット', 'ツール類']
    IGNORE_BOARDS = ['2chプロジェクト', 'いろいろランク']

    def self.download
      Agent.download("http://menu.2ch.sc/bbsmenu.html")
    end

    def self.parse(html)
      bbs = Bbs.new
      category = nil
      html.each_line{|l|
        cname = l.match(/<BR><BR><B>(.+?)<\/B><BR>/).to_a[1]
        if cname
          if IGNORE_CATEGORIES.include?(cname)
            category = nil
          else
            category = Category.new(cname)
            bbs.push(category)
          end

          next
        end

        next unless category

        b = l.match(/<A HREF=(http:\/\/.*(?:\.2ch\.sc|\.bbspink\.com|\.machi\.to)[^\s]*).*>(.+)<\/A>/).to_a
        if b[0]
          next if IGNORE_BOARDS.include?(b[2])

          board = Board.new(b[1], b[2])
          category.push(board)
        end
      }
      bbs
    end
  end

  class Subject
    def self.download(url)
      Agent.download(url)
    end

    def self.parse(url, subject)
      threads = []
      subject.each_line{|l|
        m = l.match(/^(\d+\.(?:dat|cgi))(?:<>|,)(.+)\((\d+)\)$/).to_a
        if m[0]
          threads << Thread.new(url, m[1], m[2], m[3].to_i)
        end
      }
      threads
    end
  end

  class Dat
    def self.download(url, if_modified_since = nil, range = nil)
      Agent.download(url, if_modified_since, range)
    end

    def self.parse(dat)
      posts = []
      dat.each_line{|l|
        m = l.match(/^(\d+)<>(.+?)<>(.*?)<>(.*?)<>(.+)<>.*$/).to_a
        if m[0]
          posts << Post.new(m[2], m[3], m[4], m[5])
        else
          m = l.match(/^(.+?)<>(.*?)<>(.*?)<>(.+)<>.*$/).to_a
          if m[0]
            posts << Post.new(m[1], m[2], m[3], m[4])
          end
        end
      }
      posts
    end
  end
end
