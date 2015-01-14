require 'rups/parser'

RSpec::Matchers.define :parse do |expected|
  match do |actual|
    begin
      actual.parse(expected)
      true
    rescue Parslet::ParseFailed
      false
    end
  end
end

describe Rups::Parser do
  context 'basic elements' do
    { identifier: 'foo',
      namespace: 'foo.bar',
      keyword: ':foo.bar/baz',
      string: '"foo\\"bar\\nbaz"',
      number: '3.14' }.each do |elem, str|
      it("parses #{elem}") do
        expect(subject.send(elem)).to parse(str)
      end
    end
  end

  context 'lists' do
    { '(foo)' => {car: {identifier: 'foo'}, cdr: []},
      '(:foo "bar")' => {car: {keyword: ':foo'},
                         cdr: [{string: '"bar"'}]},
      '(foo (bar (baz)))' => {car: {identifier: 'foo'},
                              cdr: [{car: {identifier: 'bar'},
                                     cdr: [{car: {identifier: 'baz'},
                                            cdr: []}]}]},
      '((foo.bar baz) "quxx" 3.14)' => # The dreaded LEFT RECURSION! ...broken, for now
        [{list: [{namespace: 'foo.bar'}, {identifier: 'baz'}]},
         {string: '"quxx"'},
         {number: '3.14'}] }.each do |str, res|
      it("parses #{str} as a list") do
        expect(subject.list.parse(str)).to eq(res)
      end
    end
  end
end
