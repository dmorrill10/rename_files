require "rename_files/version"

require 'shellwords'
require 'zaru'

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
end
