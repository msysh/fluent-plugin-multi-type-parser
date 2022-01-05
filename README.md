# fluent-plugin-multi-type-parser

[Fluentd](http://fluentd.org/) filter plugin to parse multi format message.

## Installation

```
fluent-gem install fluent-plugin-multi-type-parser
```

### If using `td-agent`

```
td-agent-gem install fluent-plugin-multi-type-parser
```

### Offline install

For example you cannot access the Gem repositories, you can install by store the file.

You store the file [filter_multi_type_parser.rb](./lib/fluent/plugin/filter_multi_type_parser.rb) in `/etc/fluent/plugin` (if using td-agent, `/etc/td-agent/plugin`). Plugin will be loaded automatically by fluentd/td-agent.

see also : "Plugin Management" - https://docs.fluentd.org/deployment/plugin-management

## Example Configuration

This plugin is a parser filter plugin.

```
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
```

## Copyright

* Copyright(c) 2017-2022 msysh
* License
  * Apache License, Version 2.0
