#
# Copyright 2017- msysh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/time'
require 'fluent/config/error'
require 'fluent/plugin/filter'

module Fluent
  module Plugin
    class MultiTypeParserFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter('multi_type_parser', self)

      config_param :key_name, :string
      config_param :reserve_data, :bool, default: false
      config_param :reserve_time, :bool, default: false
      config_param :inject_key_prefix, :string, default: nil
      config_param :replace_invalid_sequence, :bool, default: false
      config_param :hash_value_field, :string, default: nil
      config_param :emit_invalid_record_to_error, :bool, default: true

      config_section :parsers, param_name: :section_parsers, multi: true do
        config_section :parse, param_name: :section_parse, multi: true do
          config_param :@type, :string, default: nil
        end
      end

      def initialize
        super
        @parsers = []
      end

      def configure(conf)
        super

        parsers_config = nil
        conf.elements.each do | e |
          next unless ['parsers'].include?(e.name)
          parsers_config = e.elements
        end

        unless !parsers_config.nil? && parsers_config.length > 0
          raise Fluent::ConfigError, "section <parse> is required."
        end

        parsers_config.each do | p |
          next unless ['parse'].include?(p.name)
          next unless p.has_key?('@type')

          parser = Fluent::Plugin.new_parser(p['@type'], parent: self)
          parser.configure(p)
          @parsers << parser
        end
      end

      FAILED_RESULT = [nil, nil].freeze # reduce allocation cost
      REPLACE_CHAR = '?'.freeze

      def filter_with_time(tag, time, record)

        raw_value = record[@key_name]
        if raw_value.nil?
          if @emit_invalid_record_to_error
            router.emit_error_event(tag, time, record, ArgumentError.new("#{@key_name} does not exist"))
          end
          if @reserve_data
            return time, handle_parsed(tag, record, time, {})
          end
        end

        @parsers.each do | parser |
          begin
            t, r = parse_record(parser, tag, time, raw_value)

            unless t.nil? || r.nil?
              return t, r
            end
          rescue => e
            log.warn("parse failed #{e.message}") #unless @suppress_parse_error_log
          end
        end
      end

      private

      def parse_record(parser, tag, time, record)

        begin
          parser.parse(record) do |t, values|
            if values
              t = if @reserve_time
                    time
                  else
                    t.nil? ? time : t
                  end
              r = handle_parsed(tag, record, t, values)
              return t, r
            else
              if @emit_invalid_record_to_error
                router.emit_error_event(tag, time, record, Fluent::Plugin::Parser::ParserError.new("pattern not match with data '#{raw_value}'"))
              end
              if @reserve_data
                t = time
                r = handle_parsed(tag, record, time, {})
                return t, r
              else
                return FAILED_RESULT
              end
            end
          end
        rescue Fluent::Plugin::Parser::ParserError => e
          if @emit_invalid_record_to_error
            raise e
          else
            return FAILED_RESULT
          end
        rescue ArgumentError => e
          raise unless @replace_invalid_sequence
          raise unless e.message.index("invalid byte sequence in") == 0

          raw_value = raw_value.scrub(REPLACE_CHAR)
          retry
        rescue => e
          if @emit_invalid_record_to_error
            raise Fluent::Plugin::Parser::ParserError, "parse failed #{e.message}"
          else
            return FAILED_RESULT
          end
        end
      end

      def handle_parsed(tag, record, t, values)
        if values && @inject_key_prefix
          values = Hash[values.map { |k, v| [@inject_key_prefix + k, v] }]
        end
        r = @hash_value_field ? {@hash_value_field => values} : values
        if @reserve_data
          r = r ? record.merge(r) : record
        end
        r
      end
    end
  end
end
