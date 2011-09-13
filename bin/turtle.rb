require 'lib/turtle.rb'

puts ARGV[0]
input = File.open(ARGV[0]).read
puts Parser.parse input