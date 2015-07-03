#!/usr/bin/env ruby

require 'shellwords'
require 'zaru'
require 'optparse'

module RenameFiles
  def self.new_file_name(f, prefix: '', postfix: '')
    if prefix && !prefix.empty? && !f.match(/^#{prefix}/)
      f = prefix + f
    end
    if postfix && !postfix.empty? && !f.match(/#{postfix}$/)
      f << postfix
    end
    Zaru.sanitize!(f).shellescape
  end
  def self.rename(file_names, pattern: '.*', prefix: '', postfix: '', execute: false)
    file_names.each do |f|
      next if f.match(/^\.*$/) || !f.match(/#{pattern}/)
      if File.exist?(f)
        new_file_name_realized = new_file_name(
          if block_given? then yield(f) else f end,
          prefix: prefix,
          postfix: postfix
        )
        next if new_file_name_realized == f.shellescape

        command = "mv -- #{f.shellescape} #{new_file_name_realized}"
        puts command
        if execute
          system command
        end
      else
        STDERR.puts "WARNING: \"#{f}\" does not exist"
      end
    end
  end

  class Cli
    attr_reader :options, :file_names
    def initialize
      @options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #{__FILE__} [files] [options]"

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("-x", "--execute", "Actually rename files instead of only showing the commands. Defaults to false (no execution).") do |n|
          @options[:execute] = !!n
        end
        opts.on("-m", "--matches [PATTERN]", "Regular expression pattern to limit which files are renamed.") do |n|
          @options[:pattern] = n.to_s
        end
        opts.on("-d", "--directory [DIR]", "Directory in which to rename all files.") do |n|
          @options[:directory] = n.to_s
        end
        opts.on("-p", "--prefix [STRING]", "String that must be at the start of all file names. It will be prepended if necessary.") do |n|
          @options[:prefix] = n.to_s
        end
        opts.on("-a", "--postfix [STRING]", "String that must be at the end of all file names. It will be appended if necessary") do |d|
          @options[:postfix] = d.to_s
        end
      end.parse!

      @file_names = if File.directory? @options[:directory].to_s
        d = Dir.new(@options[:directory])
        Dir.chdir d.path
        d
      else
        ARGV
      end
    end

    def go
      if block_given?
        RenameFiles.rename @file_names, pattern: @options[:pattern], prefix: @options[:prefix], postfix: @options[:postfix], execute: @options[:execute] do |f|
          yield f
        end
      else
        RenameFiles.rename @file_names, pattern: @options[:pattern], prefix: @options[:prefix], postfix: @options[:postfix], execute: @options[:execute]
      end
    end
  end
end

# For manual testing
if $0 == __FILE__
  cli = RenameFiles::Cli.new

  if cli.options[:execute]
    puts "Executing Commands\n================"
  else
    puts "Only Showing Commands\n==============="
  end

  cli.go do |file_name|
    file_name.gsub('"', '').gsub(/\s+/, '_').gsub(':', '_')
  end
end
