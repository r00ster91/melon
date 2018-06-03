# Melon

[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://r00ster91.github.io/melon/)

A toolbox with useful methods and other stuff.

It adds the following modules:
- **Melon**  Has read_keypress_raw, read_keypress, selection
- **Screen** Methods for getting the screen width, height, clearing the screen etc.
- **Cursor** Methods for setting the cursor position, making the cursor invisible etc.

And extends the following modules/structs/classes:
- **System** Adds operating_system, architecture, username
- **String** Various methods like email?, palindrome?, to_binary and more
- **Char** Adds vowel?, *

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  melon:
    github: r00ster91/melon
```

## Usage

```Crystal
require "melon"

"hello".to_binary # => ["01101000", "01100101", "01101100", "01101100", "01101111"]
"A_very_good_password567182".password_strength # => 5
"kayak".palindrome? # => true
"melon@melon.com".email? # => true

loop do
  case Melon.read_keypress
  when "w", :up
    Cursor.move_up
  when "s", :down
    Cursor.move_down
  when "a", :left
    Cursor.move_right
  when "d", :right
    Cursor.move_left
  when :enter, :space
    break
  end
end

# Here we comment out code that we don't want to run:
m {
  io = IO::Memory.new

  ("Hello world" / 'l').times do
    io << (rand(50..175).chr.vowel? ? '1' : '0')
  end

  puts io
}
```

[Visit the docs](https://r00ster91.github.io/melon/) for more information about what you can do with Melon.

## Contributing

1. [Fork it](https://github.com/r00ster91/melon/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [r00ster91](https://github.com/r00ster91) - creator and maintainer
