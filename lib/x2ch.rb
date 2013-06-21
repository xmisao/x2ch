# encoding: utf-8

require 'open-uri'
require 'kconv'

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
		attr_accessor :url, :name, :num

		def initialize(url, dat, name, num)
			@url, @dat, @name, @num = url, dat, name, num
		end

		def posts
			Dat.parse(Dat.download(@url + "dat/" + @dat))
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
		def self.download(url)
			open(url){|f| f.read}.toutf8
		end
	end

	class BbsMenu
		IGNORE_CATEGORIES = ['特別企画', 'チャット', 'ツール類']
		IGNORE_BOARDS = ['2chプロジェクト', 'いろいろランク']

		def self.download
			Agent.download("http://menu.2ch.net/bbsmenu.html")
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

				b = l.match(/<A HREF=(http:\/\/.*(?:\.2ch\.net|\.bbspink\.com).+\/)>(.+)<\/A>/).to_a
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
				m = l.match(/^(\d+\.dat)<>(.+)\((\d+)\)$/).to_a
				if m[0]
					threads << Thread.new(url, m[1], m[2], m[3].to_i)
				end
			}
			threads
		end
	end

	class Dat
		def self.download(url)
			Agent.download(url)
		end
		
		def self.parse(dat)
			posts = []
			dat.each_line{|l|
				m = l.match(/^(.+?)<>(.*?)<>(.*?)<>(.+)<>.*$/).to_a
				if m[0]
					posts << Post.new(m[1], m[2], m[3], m[4])
				end
			}
			posts
		end
	end
end
