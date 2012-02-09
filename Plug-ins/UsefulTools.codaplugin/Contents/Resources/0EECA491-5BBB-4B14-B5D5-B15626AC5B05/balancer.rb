#!/usr/bin/env ruby

selected = ENV["CODA_SELECTED_TEXT"]
LINE_ENDING = ENV['CODA_LINE_ENDING']

max_position = -1
selected.each_line do |line|
	b = line.match(/^([^=]+)(\=.*)$/)
	if !b.nil?
		max_position = [max_position, ((b[1].rstrip.length) + 1)].max
	end
end

first = true
selected.each_line do |line|
	print LINE_ENDING if !first
	first = false
	
	b = line.match(/^([^=]+)(\=.*)$/)
	if !b.nil?
		spaces = " " * (max_position - b[1].rstrip.length)
		print "#{b[1].rstrip}#{spaces}#{b[2]}"
	else
		print line
	end
end