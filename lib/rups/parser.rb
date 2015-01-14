require 'parslet'

module Rups
  class Parser < Parslet::Parser
    # Helpers
    def spaced(char)
      match['[:space:]'].repeat >> str(char) >> match['[:space:]'].repeat
    end

    def captured(rule)
      send(rule).as(rule)
    end

    # Basic Atoms
    rule(:identifier) { match['a-zA-Z_'] >> match['[:alnum:]'].repeat }
    rule(:namespace) { identifier >> (str('.') >> identifier).repeat }
    rule(:keyword) { str(':') >> (namespace >> str('/')).maybe >> identifier }
    rule(:string) { str('"') >>
                    ((str('\\') | str('"').absent?) >> any).repeat >>
                    str('"') }
    rule(:number) { match['[:digit:]'].repeat >>
                    (str('.') >> match['[:digit:]'].repeat).maybe }

    # Program Elements
    rule(:program) { form.repeat(1) }
    rule(:list) { spaced('(') >>
                  form.as(:car) >>
                  (match['[:space:]'].repeat(1) >> form).repeat.as(:cdr) >>
                  spaced(')') }
    rule(:map) { str('{') >>
                 (spaced(:form).as(:key) >> (spaced(:form).as(:value))).repeat >>
                 str('}') }
    rule(:vec) { str('[') >> spaced(:form).repeat >> str(']') }
    rule(:form) { captured(:identifier) |
                  captured(:namespace) |
                  captured(:keyword) |
                  captured(:string) |
                  list }
    root(:program)
  end
end

# Rups::Parser.new.parse('( foo)')
