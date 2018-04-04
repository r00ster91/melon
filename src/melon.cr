require "colorize"

module Melon
	extend self

  VERSION = "0.9.8"

	class WIP < Exception
		def initialize
		  super "Sorry but this method is work in progress"
		end
	end
	# For things that are work in progress.
	def wip
		raise Melon::WIP.new
	end

	# This is some kind of a multiline comment.
	# You can comment out code with it.
	# ```
	# m {
	#   # code you don't want to run
	# }
	# ```
	def m
		yield if false
	end

	# Prints each char of *string* with a delay to STDOUT.
	def printd(string : String, delay : Number = 0.05)
		string.each_char do |char|
			print char
			sleep delay
		end
	end

  # Waits until a key has been pressed and returns it.
  def read_keypress : String
    STDIN.raw do |io|
      buffer = Bytes.new(3)
      String.new(buffer[0, io.read(buffer)])
    end
  end

  # This module provides methods to control the terminal screen.
	module Screen
		extend self

		# Clears the whole screen.
	  def clear
	    print "\e[3J"
	  end
	  # Clears the current line, the cursor is in.
	  def clear_line
	    print "\e[2K"
	  end

	  # Scrolls *lines* up.
	  def scroll_up(lines)
	  	print "\e[#{lines}S"
	  end
	  # Scrolls *lines* down.
	  def scroll_down(lines)
	  	print "\e[#{lines}T"
	  end
	end

	# This module provides methods to control the terminal cursor.
	module Cursor
		extend self

		# Shows or hides the cursor.
		# ```
		# Cursor.visible = false # The cursor is invisible now.
		# ```
	  def visible=(visible : Bool)
	  	print (visible ? "\e[?25h" : "\e[?25l")
	  end

	  def move_up(cells = 1)
	  	print "\e[#{cells}A"
	  end
	  def move_down(cells = 1)
	  	print "\e[#{cells}B"
	  end
	  def move_right(cells = 1)
	  	print "\e[#{cells}D"
	  end
	  def move_left(cells = 1)
	  	print "\e[#{cells}C"
	  end

	  def set_position(row, column)
	  	print "\e[#{row};#{column}H"
	  end
	end

	def selection(options, type = 1)
  	selected = 0
  	options_size = options.size-1
  	putted = false
  	loop do
  		if !putted
	  		options.size.times {puts}
	  		putted = true
	  	end
	  	Cursor.move_up options.size
	  	options.each_with_index do |option, index|
	  		puts(
	  			if selected==index
	  				if type==1
		  				">#{option}"
		  			elsif type==2
		  				option.colorize(:white)
		  			end
	  			else
	  				if type==1
		  				"#{option} "
		  			elsif type==2
		  				option.colorize(:dark_gray)
		  			end
	  			end
	  		)
	  	end

	  	loop do
		  	case Console.read_keypress
		    when "\e[A", "w", "W"
		      if selected==0
		      	selected = options_size
		      else
		      	selected -= 1
		      end
		    when "\e[B", "s", "S"
		      if selected==options_size
		      	selected = 0
		      else
		      	selected += 1
		      end
		    when "\r"
		    	return selected
		    else
		    	next
				end
				break
			end
		end
  end
end

module System
	extend self

	# Returns the operating system of the computer.
	def os : Symbol
		{% if flag?(:win32) %}
			:win32
		{% elsif flag?(:macos) %}
			:macos
		{% elsif flag?(:openbsd) %}
			:openbsd
		{% elsif flag?(:freebsd) %}
			:freebsd
		{% elsif flag?(:darwin) %}
			:darwin
		{% elsif flag?(:linux) %}
			:linux
		{% else %}
			:unknown
		{% end %}
	end

	# Returns the architecture of the computer.
	def architecture : Int32 | Symbol
		{% if flag?(:x86_64) %}
			64
		{% elsif flag?(:i686) %}
			32
		{% else %}
			:unknown
		{% end %}
	end
end

struct Char
	def *(other : Int)
		self.to_s*other
	end
end

class String
	# Returns a new String with all occurrences of *other* removed.
	def -(other : String) : String
		self.delete(other)
	end

	# Counts the occurrences of *other* in this String.
	def /(other : String) : Int
		self.count(other)
	end

	# Returns `true` if this String is a palindrome.
	def palindrome? : Bool
		self[0..-(self.size/2+1)]==self[self.size/2..-1].reverse
	end

	# Returns `true` if this String is a valid username.
	def username? : Bool
		/[A-Za-z0-9_]/.match(self)!=nil
	end

	# Returns `true` if this String is a valid E-Mail.
	# But it doesn't checks if this E-Mail exists.
	def email? : Bool
		/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match(self)!=nil
	end

	# Returns the password strength of this String.
	# - 5 = very good
	# - 4 = good
	# - 3 = acceptable
	# - 2 = bad
	# - 1 = not acceptable
	def password_strength : Int32
		strength = 0

		return 1 if self.size<4
		if /\d/.match self
			strength += 1
		end
		if /[A-Z]/.match self
			strength += 1
		end
		if /[a-z]/.match self
			strength += 1
		end
		if self.size>=8
			strength += 1
		end
		if self.size>=16
			strength += 1
		end

		strength
	end

	# Converts this String to binary.
	def to_binary : Array(String)
		binary = [] of String
		self.bytes.each do |byte|
			binary << (String.build do |io|
				8.times do
					io << ((byte&128)==0 ? 0 : 1)
					byte <<= 1
				end
			end)
		end
		binary
	end

	# Converts this String to cow speech.
	# This method allows you to communicate with cows.
	def to_cow_speech : String
		String.build do |io|
			self.squeeze.strip(' ').split(' ').each_with_index do |word, index|
				io << (word[0].uppercase? ? 'M' : 'm')
				word.lchop.chars.each do |char|
					io << (char.uppercase? ? 'O' : 'o')
				end
				io << ' '
			end
		end
	end
end

struct Char
	# Returns `true` if this Char is a vowel.
	def vowel? : Bool
		"aeiou".includes? self.downcase
	end
end