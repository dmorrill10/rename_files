require 'test_helper'

describe RenameFiles do
  it 'has a version number' do
    (!!::RenameFiles::VERSION).must_equal true
  end
  it 'does not add the prefix when already present' do
    RenameFiles.new_file_name('match.file.log', prefix: 'match').must_equal 'match.file.log'
  end
  it 'does not add the postfix when already present' do
    RenameFiles.new_file_name('match.file.log', postfix: 'log').must_equal 'match.file.log'
  end
  it 'adds the prefix when not present' do
    RenameFiles.new_file_name('file.log', prefix: 'match.').must_equal 'match.file.log'
  end
  it 'adds the postfix when not present' do
    RenameFiles.new_file_name('match.file', postfix: '.log').must_equal 'match.file.log'
  end
end
