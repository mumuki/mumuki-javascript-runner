require_relative './spec_helper'
require 'ostruct'

describe JavascriptQueryHook do
  let(:hook) { JavascriptQueryHook.new(nil) }
  let(:file) { hook.compile(request) }
  let(:result) {
    hook.run!(file)
  }

  context 'integral query' do
    let(:request) { struct(query: '5') }
    it { expect(result[0]).to eq "=> 5\n" }
  end

  context 'query with let' do
    let(:request) { struct(query: 'x + 1', extra: 'let x = 4') }
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

  context 'query with var' do
    let(:request) { struct(query: 'var x = 3;') }
    it { expect(result[0]).to eq "=> undefined\n" }
  end

  context 'query with let' do
    let(:request) { struct(query: 'let x = 3') }
    it { expect(result[0]).to eq "=> undefined\n" }
  end

  context 'query with plus' do
    let(:request) { struct(query: '4+5') }
    it { expect(result[0]).to eq "=> 9\n" }
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
    let(:request) { struct(query: 'y', extra: 'var y=64+2') }
    it { expect(result[0]).to eq "=> 66\n" }
  end
end
