# Melon

A toolbox with useful methods and other stuff.

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

loop do
	case Melon.read_keypress
	when "w"
		Melon::Cursor.move_up
	when "s"
		Melon::Cursor.move_down
	when "a"
		Melon::Cursor.move_right
	when "d"
		Melon::Cursor.move_left
	when " "
		break
	end
end
```

## Contributing

1. Fork it (https://github.com/r00ster91/melon/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [r00ster91](https://github.com/r00ster91) - creator, maintainer
