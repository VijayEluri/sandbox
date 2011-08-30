#!/usr/bin/env ruby

# ruby verspy.rb -s /path/to/jboss-seam-src/src/main -p org.jboss.seam stacktrace.log

require 'optparse'

Version = "0.1"

option_hash = {}
OptionParser.new { |opt|
  opt.on('-s source path', '--sourcepath') { |v| option_hash[:s] = v }
  opt.on('-p target package name', '--packagename') { |v| option_hash[:p] = v }
  opt.parse!(ARGV)
}

opt_source_path = option_hash[:s]
opt_package_name = option_hash[:p]

raise if opt_source_path.nil? or opt_package_name.nil?

STACKTRACE_RE = /\s+at\s(#{opt_package_name}[^\(]+)\(([\w\.]+):(\d+)\)\s*$/

lines_done = []

ARGF.each do |line|
  if line.match(STACKTRACE_RE) and not lines_done.include?(line) then
    lines_done << line
    class_method_name = $1
    source = $2
    source_linenum = $3.to_i
    class_name = class_method_name[0...class_method_name.rindex('.')]
    method_name = class_method_name[class_method_name.rindex('.')+1..-1]
    package_name = class_name[0...class_name.rindex('.')]
    source_file = "#{opt_source_path}/#{package_name.gsub(/\./, '/')}/#{source}"

#    puts "#{class_name} #{method_name} #{source} #{source_linenum}"
#    puts "#{package_name}"
#    puts source_file

    open(source_file) do |f|
      body = f.readlines
      target_line = body[source_linenum-1]
      unless target_line =~ /#{method_name}/ then
        puts "== Suspicias line"
        puts line
        puts "#{source_linenum-1}: #{body[source_linenum-2]}"
        puts "#{source_linenum}: #{body[source_linenum-1]}"
        puts "#{source_linenum+1}: #{body[source_linenum]}"
      end
    end
  end
end
