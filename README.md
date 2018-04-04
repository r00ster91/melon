# Melon

A toolbox with useful methods and other stuff.

[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://r00ster91.github.io/melon/)

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

"kayak".palindrome? # => true
"hello".to_binary # => ["01101000", "01100101", "01101100", "01101100", "01101111"]
"aVeryVeryGoodPassword567182".password_strength # => 5
'e' * 5 # => eeeee

loop do
  case Melon.read_keypress
  when "w", :up
    Melon::Cursor.move_up
  when "s", :down
    Melon::Cursor.move_down
  when "a", :left
    Melon::Cursor.move_right
  when "d", :right
    Melon::Cursor.move_left
  when :enter, :space
    break
  end
end
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
