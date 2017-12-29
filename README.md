# fluent-plugin-multi-type-parser

[Fluentd](http://fluentd.org/) filter plugin to parse multi format message.

**for v1.0(v0.14) / td-agent3 only!**

## Configuration

This plugin is a parser filter plugin.

    <filter raw.syslog.**>
      @type multi_type_parser
      key_name message

      <parsers>
        <parse>
          @type regexp
          expression /.../
        </parse>
        <parse>
          @type regexp
          expression /.../
        </parse>
        <parse>
          @type custom_parser
          custom_parser_param  foo
          custom_parser_param2 bar
        </parse>
        <parse>
          @type none
        </parse>
      </parsers>
    </filter>

## Copyright

* Copyright(c) 2017- msysh
* License
  * Apache License, Version 2.0
