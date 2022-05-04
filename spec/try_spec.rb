require_relative './spec_helper'
require 'ostruct'

describe JavascriptTryHook do
  let(:hook) { JavascriptTryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  let(:goal) { { kind: 'query_outputs', query: '"goal :)"', output: '"goal :)"' } }
  let(:request) { struct query: query, goal: goal }

  context 'with a dummy goal' do
    let(:query) { '"asd"' }
    it { expect(result[2][:result]).to eq '"asd"' }
    it { expect(result[1]).to eq :passed }
  end

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', value: '"something"' } }

    context 'and query that matches' do
      let(:query) { '"something"' }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:query) { '"somethingElse"' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regexp: /console\.log(.*)/ } }

    context 'and query that matches' do
      let(:query) { 'console.log("hola")' }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:query) { 'var a = 2' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_outputs goal' do
    let(:goal) { { kind: 'last_query_outputs', output: '3' } }

    context 'and query with said output' do
      let(:query) { '1 + 2' }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with a different output' do
      let(:query) { '5' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_fails goal' do
    let(:goal) { { kind: 'query_fails', query: 'asd' } }

    context 'and query that makes said query pass' do
      let(:query) { 'let asd = 2;' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not make said query pass' do
      let(:query) { '' }
      it { expect(result[1]).to eq :passed }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'asd' } }

    context 'and query that makes said query pass' do
      let(:query) { 'let asd = 2;' }
      it { expect(result[1]).to eq :passed }
    end

    context 'nd query that does not make said query pass' do
      let(:query) { '' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'asd', output: '55' } }

    context 'and query that generates said output' do
      let(:query) { 'let asd = 55;' }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not generate said output' do
      let(:query) { 'let asd = 28' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'and query that passes' do
      let(:query) { '123' }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that fails' do
      let(:query) { 'asdasd' }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'when query errors result is not blank' do
    let(:goal) { { kind: 'last_query_fails' } }
    let(:query) { 'foo()' }

    it { expect(result[2][:result]).to include 'ReferenceError: foo is not defined' }
  end
end
