require "colorize"

# This should be used to make code more readable.
# ```
# lightswitch = ON
# ```
ON = true

# This should be used to make code more readable.
# ```
# lightswitch = OFF
# ```
OFF = false

# This is a multiline comment.
# You can comment out code with it. No matter what code.
# ```
# m {
#   # code you don't want to run
# }
# ```
macro m
  {% if false %}
    {{yield}}
  {% end %}
end

module Melon
  extend self

  class Error < Exception
  end

  VERSION = "1.0.0"

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
    when "\u007f", "\b"
      :backspace
    when "\r", "\n"
      :enter
    when "\t"
      :tab
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
    when "\u{3}"
      exit
    else
      key
    end
  end

  # Prints the options in which the user can select one using the arrow keys and W, S and confirm using the enter key.
  # ```
  # Melon.selection({"Play", "Options", "Exit"})
  # ```
  # ```text
  # >Play
  # Options
  # Exit
  # ```
  def selection(options : Array | Tuple)
    selected = 0
    options_size = options.size - 1
    print "\n"*options.size
    loop do
      Cursor.move_up options.size
      options.each_with_index do |option, index|
        puts(if selected == index
          ">#{option}"
        else
          "#{option} "
        end)
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
end

module Screen
  extend self

  # Returns the width of the screen in cells.
  def width
    `tput cols`.to_i
  end

  # Returns the height of the screen in cells.
  def height
    `tput lines`.to_i
  end

  # Clears the screen and delete all saved lines in the scrollback buffer.
  def clear
    print "\e[3J"
  end

  # Clears the current cells in the line, the cursor is in.
  def clear_line
    print "\e[2K"
  end

  # Scrolls *lines* lines up.
  def scroll_up(lines)
    print "\e[#{lines}S"
  end

  # Scrolls *lines* lines down.
  def scroll_down(lines)
    print "\e[#{lines}T"
  end
end

module Cursor
  extend self

  # Shows or hides the cursor.
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
  def architecture : Symbol
    {% if flag?(:bits64) %}
      :bits64
    {% elsif flag?(:bits32) %}
      :bits32
    {% elsif flag?(:arm) %}
      :arm
    {% else %}
      :unknown
    {% end %}
  end

  # Returns the username of the current user.
  def username : String
    {% if flag?(:win32) %}
      hostname = begin
        `whoami`.split('\\')[1]
      rescue
        ""
      end
    {% else %}
      hostname = `whoami`
    {% end %}

    raise Melon::Error.new "Could not get hostname" if hostname.empty?

    hostname
  end
end

class String
  # Returns a new string with all occurrences of *other* removed.
  def -(char : Char) : String
    self.delete(char)
  end

  # Counts the occurrences of *other* in this string.
  def /(other : Char) : Int32
    self.count(other)
  end

  # Returns `true` if this string is a palindrome.
  def palindrome? : Bool
    self[0..-(self.size/2 + 1)] == self[self.size/2..-1].reverse
  end

  # Returns `true` if this String is a valid E-Mail.
  # But it doesn't checks if this E-Mail exists.
  def email? : Bool
    /[^@\s]+@([^@\s]+\.)+[^@\s]+/ === self
  end

  # Returns the password strength of this string.
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

  # Converts this string to binary.
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

  # Converts this string to cow speech.
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
  # Makes a new `String` by adding str to itself times times.
  def *(times : Int)
    self.to_s*other
  end

  # Returns `true` if this char is a vowel.
  def vowel? : Bool
    "aeiou".includes? self.downcase
  end
end