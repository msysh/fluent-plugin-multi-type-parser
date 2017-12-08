# fluent-plugin-multi-type-parser

[Fluentd](http://fluentd.org/) filter plugin to do something.

**for v1.0(v0.14) / td-agent3 only!**

## Configuration

This plugin is a parser filter plugin.

    <filter raw.syslog.**>
      @type multi_type_parser
      key_name message

      <parsers>
        <parse>
          @type nginx
        </parse>
        <parse>
          @type apache2
        </parse>
        <parse>
          @type none
        </parse>
      </parsers>
    </filter>

## Installation

### RubyGems

```
$ gem install fluent-plugin-multi-type-parser
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-multi-type-parser"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-format-config filter multi-type-parser
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2017- msysh
* License
  * Apache License, Version 2.0
