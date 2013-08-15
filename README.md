# Ruby::Atdd

TL;DR: Like Cucumber, but with less features, but also easier to use, and you can use it for stress testing.

A lightweight ATDD alternative to Cucumber for acceptance testing, that can also be used for load testing.

Acceptance Tests treat your service (a website, an API, a CLI, etc.) as a blackbox, and encapsolute how a real user would use your service.

Acceptance Tests can be used for regression testing your service, but can also be used for Load/Stress Testing.

Ruby-ATDD's goal is to make it easy to test your service as well as stress test it.

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-atdd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-atdd

## Usage

### During development

```bash
rerun_test path/to/your/acceptance/test.rb
```

## Why

If you don't know why this is valuable, read http://www.growing-object-oriented-software.com/.

## Roadmap

[] Add tests (yes, I usually write tests first.)
[] Use for load testing, making improvements as needed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
Copyright (c) 2013 Greg Edwards (greglearns)

MIT License
