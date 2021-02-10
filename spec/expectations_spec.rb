require_relative 'spec_helper'

describe JavascriptExpectationsHook do
  def req(expectations, content)
    struct expectations: expectations, content: content
  end

  def compile_and_run(request)
    runner.run!(runner.compile(request))
  end

  let(:runner) { JavascriptExpectationsHook.new }
  let(:result) { compile_and_run(req(expectations, code)) }

  describe 'HasTooShortIdentifiers' do
    let(:code) { "function f(x) { retun g(x); }" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'f', inspection: 'HasTooShortIdentifiers'}, result: false}] }
  end

  describe 'HasWrongCaseIdentifiers' do
    let(:code) { "function a_function_with_bad_case() { return 3 }" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'a_function_with_bad_case', inspection: 'HasWrongCaseIdentifiers'}, result: false}] }
  end

  describe 'HasRedundantIf' do
    let(:code) { "function foo(x) { if (x) { return true; } else { return false; } }" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'foo', inspection: 'HasRedundantIf'}, result: false}] }
  end

  describe 'DeclaresProcedure' do
    let(:code) { "function foo(x, y) { }\nlet bar = 4;" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresProcedure:foo'},
      {binding: '*', inspection: 'DeclaresProcedure:bar'},
      {binding: '*', inspection: 'DeclaresProcedure:foobaz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end


  describe 'DeclaresFunction' do
    let(:code) { "function foo(x, y) { return x + y; }\nlet bar = 4;" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresFunction:foo'},
      {binding: '*', inspection: 'DeclaresFunction:bar'},
      {binding: '*', inspection: 'DeclaresFunction:foobaz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end

  describe 'DeclaresVariable' do
    let(:code) { "function foo(x, y) { }\nlet bar = 4;" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresVariable:foo'},
      {binding: '*', inspection: 'DeclaresVariable:bar'},
      {binding: '*', inspection: 'DeclaresVariable:foobaz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: false},
        {expectation: expectations[1], result: true},
        {expectation: expectations[2], result: false}] }
  end

  describe 'Declares' do
    let(:code) { "function foo(x, y) { }\nlet bar = 4;" }
    let(:expectations) { [
      {binding: '*', inspection: 'Declares:foo'},
      {binding: '*', inspection: 'Declares:bar'},
      {binding: '*', inspection: 'Declares:foobaz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: true},
        {expectation: expectations[2], result: false}] }
  end

end
