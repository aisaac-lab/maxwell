# Maxwell

```ruby
m = Maxwell.new(proxy: {
  url: '',
  user: '',
  pass: '',
})
res = m.get('https://api.ipify.org?format=json')
res.body
```

## Installation

```ruby
gem 'maxwell', github: 'aisaac-lab/maxwell'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install maxwell

## Develop
```
export URL=
export USER=
export PASS=

bundle exec rspec
```