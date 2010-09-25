require 'nil/http'
require 'nil/console'

class CPUEntry
	attr_reader :name, :score, :price
	
	def initialize(name, score, price)
		@name = name
		@score = score
		@price = price
	end
	
	def getRatio
		return @score.to_f / @price
	end
	
	def <=>(other)
		return other.getRatio <=> getRatio
	end
end

class CPUBenchmark
	attr_reader :cpus
	
	def initialize(url)
		@cpus = []
		data = loadData(url)
		processData(data)
	end
	
	def loadData(url)
		data = Nil.httpDownload(url)
		if data == nil
			raise "Unable to retrieve data from #{url}"
		end
		return data
	end
	
	def processData(data)
		pattern = /<a href="cpu\.php\?cpu=.+?">(.+?)<\/a>.+?<img .+?>([,\d]+?)<\/td>[\s\S]+?<a href="cpu\.php\?cpu=.+?">(.+?)<\/a>/
		data.scan(pattern) do |match|
			name = match[0]
			score = match[1].gsub(',', '').to_i
			price = match[2]
			if price == 'NA'
				price = nil
			else
				['$', '*', ','].each { |x| price = price.gsub(x, '') }
				price = price.to_f
			end
			next if price == nil
			@cpus << CPUEntry.new(name, score, price)
		end
	end
	
	def visualiseResults
		cpus = @cpus.sort
		counter = 1
		rows = []
		cpus.each do |cpu|
			ratio = sprintf('%.2f', cpu.getRatio)
			row = ["#{counter}.", cpu.name, "#{cpu.score} points / $#{cpu.price}", "#{ratio} points/USD"]
			rows << row
			counter += 1
		end
		Nil.printTable(rows)
	end
end

benchmark = CPUBenchmark.new('http://www.cpubenchmark.net/high_end_cpus.html')
benchmark.visualiseResults
