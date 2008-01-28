require 'rubygems'
require 'win32console'
@io = Win32::Console::ANSI::IO.new()
until $stdin.eof? do
line = $stdin.gets
@io.puts line
end
@io.flush