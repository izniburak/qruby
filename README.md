# qruby

```
                   _           
                  | |          
   __ _ _ __ _   _| |__  _   _ 
  / _` | '__| | | | '_ \| | | |
 | (_| | |  | |_| | |_) | |_| |
  \__, |_|   \__,_|_.__/ \__, |
     | |                  __/ |
     |_|                 |___/                                             
```

[![Build Status](https://travis-ci.org/izniburak/qruby.svg?branch=master)](https://travis-ci.org/izniburak/qruby)

sql query builder library for Ruby


## Installation

```
gem install qruby
```


## Usage


```ruby
require "qruby"
builder = QRuby::Builder.new

p builder.table("test").where("id", 17).or_where("language", "ruby").get

# Output:
# "SELECT * FROM test WHERE id = '17' OR language = 'ruby' LIMIT 1"


p builder.table('test').select('id, title, status').order_by('id', 'desc').limit(10).get_all
# Output:
# "SELECT id, title, status FROM test ORDER BY id DESC LIMIT 10"
```


## Docs

Documentation Page: [qruby Docs](https://github.com/izniburak/qruby/blob/master/DOCS.md)


## Contributing

1. Fork it ( https://github.com/izniburak/qruby/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [izniburak](https://github.com/izniburak) İzni Burak Demirtaş - creator, maintainer
