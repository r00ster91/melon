require "colorize"

module Melon
  extend self

  VERSION = "1.0.0"

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
  def read_keypress_raw : String
    STDIN.raw do |io|
      buffer = Bytes.new(3)
      String.new(buffer[0, io.read(buffer)])
    end
  end

  # Same as `read_keypress_raw` except that this method returns the key more compact.
  # - "\t" becomes :tab
  # - " " becomes :space
  # - "\e" becomes :escape
  # etc.
  def read_keypress : String | Symbol
    case key = read_keypress_raw
    when "\r", "\n"
      :enter
    when "\t"
      :tab
    when " "
      :space
    when "\e"
      :escape
    when "\e[A"
      :up
    when "\e[B"
      :down
    when "\e[C"
      :right
    when "\e[D"
      :left
    else
      key.downcase
    end
  end

  # Raised when an invalid type has been specified at `selection`.
  # ```
  # Melon.selection(["Play", "Settings", "Quit"], 4) # raises InvalidSelectionType
  # ```
  class InvalidSelectionType < Exception
  end

  def selection(options : Array(String), type = 1)
    if type != 1 || type != 2
      raise(InvalidSelectionType.new(
        "Selection type #{type} is invalid. Choose either 1 or 2"
      ))
    end
    selected = 0
    options_size = options.size - 1
    putted = false
    loop do
      if !putted
        options.size.times { puts }
        putted = true
      end
      Cursor.move_up options.size
      options.each_with_index do |option, index|
        puts(
          if selected == index
            if type == 1
              ">#{option}"
            elsif type == 2
              option.colorize(:white)
            end
          else
            if type == 1
              "#{option} "
            elsif type == 2
              option.colorize(:dark_gray)
            end
          end
        )
      end
      loop do
        case Melon.read_keypress
        when :up, "w"
          if selected == 0
            selected = options_size
          else
            selected -= 1
          end
        when :down, "s"
          if selected == options_size
            selected = 0
          else
            selected += 1
          end
        when :enter
          return selected
        else
          next
        end
        break
      end
    end
  end

  # This module provides methods to control the terminal screen.
  module Screen
    extend self

    # Clears the whole screen.
    def clear
      print "\e[2J\e[3J"
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

    def set_position(x, y)
      print "\e[#{y};#{x}H"
    end
  end
end

module System
  extend self

  # Returns the operating system of the computer.
  def operating_system : Symbol
    {% if flag?(:linux) %}
      :linux
    {% elsif flag?(:macos) %}
      :macos
    {% elsif flag?(:openbsd) %}
      :openbsd
    {% elsif flag?(:freebsd) %}
      :freebsd
    {% elsif flag?(:darwin) %}
      :darwin
    {% elsif flag?(:win32) %}
      :win32
    {% else %}
      :unknown
    {% end %}
  end

  # Returns the architecture of the computer.
  def architecture : Int32 | Symbol
    {% if flag?(:x86_64) || flag?(:amd64) %}
      :64bit
    {% elsif flag?(:i686) || flag?(:i586) || flag?(:i486) || flag?(:i386) %}
      :32bit
    {% elsif flag?(:arm) %}
      :arm
    {% else %}
      :unknown
    {% end %}
  end

  # Returns the username of the current user.
  def username : String
    `whoami`
  end
end

struct Char
  # Makes a new `String` by adding this Char to itself *times* times.
  def *(times : Int)
    self.to_s*other
  end
end

class String
  # Returns a new `String` with all occurrences of *other* removed.
  def -(other : String) : String
    self.delete(other)
  end

  # Counts the occurrences of *other* in this String.
  def /(other : String) : Int
    self.count(other)
  end

  # Returns `true` if this String is a palindrome.
  def palindrome? : Bool
    self[0..-(self.size/2 + 1)] == self[self.size/2..-1].reverse
  end

  # Returns `true` if this String is a valid username.
  def username? : Bool
    /[A-Za-z0-9_]/.match(self) != nil
  end

  # Returns `true` if this String is a valid E-Mail.
  # But it doesn't checks if this E-Mail exists.
  def email? : Bool
    /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match(self) != nil
  end

  # Returns the password strength of this String.
  # - 5 = very good
  # - 4 = good
  # - 3 = acceptable
  # - 2 = bad
  # - 1 = not acceptable
  def password_strength : Int32
    strength = 0

    return 1 if self.size < 4
    if /\d/.match self
      strength += 1
    end
    if /[A-Z]/.match self
      strength += 1
    end
    if /[a-z]/.match self
      strength += 1
    end
    if self.size >= 8
      strength += 1
    end
    if self.size >= 16
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
          io << ((byte & 128) == 0 ? 0 : 1)
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

p "hello cow".to_cow_speech 