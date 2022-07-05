require_relative './spec_helper'
require 'ostruct'

describe JavascriptQueryHook do
  let(:hook) { JavascriptQueryHook.new(nil) }
  let(:file) { hook.compile(request) }
  let(:result) {
    hook.run!(file)
  }

  describe 'expressions' do
    context 'integral query' do
      let(:request) { struct(query: '5') }
      it { expect(result[0]).to eq "=> 5\n" }
    end

    context 'with semicolon' do
      let(:request) { struct(query: '"hello".toString();') }
      it { expect(result[0]).to eq "=> \"hello\"\n" }
    end

    context 'string query' do
      let(:request) { struct(query: '"hello"') }
      it { expect(result[0]).to eq "=> \"hello\"\n" }
    end

    context 'array query' do
      let(:request) { struct(query: '[1,2, 3]') }
      it { expect(result[0]).to eq "=> [1,2,3]\n" }
    end

    context 'array with message query' do
      let(:request) { struct(query: '[1,2, 3].includes(2)') }
      it { expect(result[0]).to eq "=> true\n" }
    end

    context 'null query' do
      let(:request) { struct(query: 'null') }
      it { expect(result[0]).to eq "=> null\n" }
    end

    context 'undefined query' do
      let(:request) { struct(query: 'undefined') }
      it { expect(result[0]).to eq "=> undefined\n" }
    end

    context 'object query' do
      let(:request) { struct(query: '{x: 4}') }
      it { expect(result[0]).to eq "=> {x:4}\n" }
    end

    context 'function query' do
      let(:request) { struct(query: '(function () {})') }
      it { expect(result[0]).to eq "=> <function>\n" }
    end

    context 'string query' do
      let(:request) { struct(query: '"hello"') }
      it { expect(result[0]).to eq "=> \"hello\"\n" }
    end

    context 'with plus' do
      let(:request) { struct(query: '4+5') }
      it { expect(result[0]).to eq "=> 9\n" }
    end
  end

  describe 'declarations' do
    context 'with let' do
      let(:request) { struct(query: 'let x = 3') }
      it { expect(result[0]).to eq "=> undefined\n" }
    end

    context 'with let and accessing' do
      let(:request) { struct(query: 'foo', cookie: ['let foo = 2']) }
      it { expect(result[0]).to eq "=> 2\n" }
    end

    context 'with var' do
      let(:request) { struct(query: 'var x = 3;') }
      it { expect(result[0]).to eq "=> undefined\n" }
    end

    context 'with let and assignment' do
      let(:request) { struct(query: 'foo', cookie: ['let foo = 2', 'foo = 56']) }
      it { expect(result[0]).to eq "=> 56\n" }
    end

    context 'with multiple let' do
      describe 'declaring' do
        let(:request) { struct(query: 'let foo = 5', cookie: ['let foo = 2']) }
        it { expect(result[0]).to include "Identifier 'foo' has already been declared" }
        it { expect(result[1]).to eq :errored }
      end

      describe 'accessing' do
        let(:request) { struct(query: 'foo', cookie: ['let foo = 2', 'let foo = 5']) }
        it { expect(result[0]).to eq "=> 2\n" }
      end
    end

    context 'with const' do
      let(:request) { struct(query: 'foo', cookie: ['const foo = 9']) }
      it { expect(result[0]).to eq "=> 9\n" }
    end

    context 'with const and reassignment' do
      describe 'declaring' do
        let(:request) { struct(query: 'foo = 0', cookie: ['const foo = 9']) }
        it { expect(result[0]).to include "Assignment to constant variable" }
        it { expect(result[1]).to eq :errored }
      end

      describe 'accessing' do
        let(:request) { struct(query: 'foo', cookie: ['const foo = 9', 'foo = 0']) }
        it { expect(result[0]).to eq "=> 9\n" }
      end
    end

    context 'with multiple const' do
      describe 'declaring' do
        let(:request) { struct(query: 'const foo = 5', cookie: ['const foo = 9']) }
        it { expect(result[0]).to include "Identifier 'foo' has already been declared" }
        it { expect(result[1]).to eq :errored }
      end

      describe 'accessing' do
        let(:request) { struct(query: 'foo', cookie: ['const foo = 9', 'const foo = 5']) }
        it { expect(result[0]).to eq "=> 9\n" }
      end
    end

    context 'with conflicting names' do
      describe 'declaring' do
        let(:request) { struct(query: 'const foo = 4', cookie: ['var foo = 2']) }
        it { expect(result[0]).to include "Identifier 'foo' has already been declared" }
        it { expect(result[1]).to eq :errored }
      end

      describe 'accessing' do
        let(:request) { struct(query: 'foo', cookie: ['var foo = 2', 'const foo = 4']) }
        it { expect(result[0]).to eq "=> 2\n" }
      end
    end
  end

  context 'query and content' do
    context 'no cookie' do
      let(:request) { struct(query: 'x', content: 'var x=2*2') }
      it { expect(result[0]).to eq "=> 4\n" }
    end

    context 'with cookie' do
      let(:request) { struct(query: 'x', cookie: ['x++', 'x++'], content: 'var x = 4') }
      it { expect(result[0]).to eq "=> 6\n" }
    end

    context 'with failing cookie' do
      let(:request) { struct(query: 'x', cookie: ['throw new Error("ups")', 'x++'], content: 'var x = 4') }
      it { expect(result[0]).to eq "=> 5\n" }
    end
  end

  context 'query and extra' do
    context 'with variable' do
      let(:request) { struct(query: 'y', extra: 'var y=64+2') }
      it { expect(result[0]).to eq "=> 66\n" }
    end

    context 'with expression ' do
      let(:request) { struct(query: 'x + 1', extra: 'let x = 4') }
      it { expect(result[0]).to eq "=> 5\n" }
    end
  end

  context 'query with syntax errors' do
    context 'with invalid token' do
      let(:request) { struct(query: '!') }
      it { expect(result[0]).to eq %q{!;
                               ^

SyntaxError: Unexpected token ;} }
      it { expect(result[1]).to eq :errored }
    end

    context 'with unclosed curly braces' do
      let(:request) { struct(query: 'function () {') }
      it { expect(result[0]).to eq %q`});
 ^

SyntaxError: Unexpected token )` }
      it { expect(result[1]).to eq :errored }
    end
  end

  context 'query with unknown reference' do
    let(:request) { struct(query: 'someFunction(23)') }
    it { expect(result[0]).to include 'ReferenceError' }
    it { expect(result[0]).to_not include '__mumuki_query_result__' }
    it { expect(result[1]).to eq :errored }
  end

  context 'console log query with cookie' do
    let(:request) { struct(query: 'console.log("foo")', cookie: ['console.log("bar")']) }
    it { expect(result[0]).to include 'foo' }
    it { expect(result[0]).to_not include 'bar' }
    it { expect(result[1]).to eq :passed }
  end
end
