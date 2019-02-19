require_relative './spec_helper'
require 'ostruct'

describe JavascriptTryHook do
  let(:hook) { JavascriptTryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  let(:goal) { { kind: 'query_outputs', query: '"goal :)"', output: '"goal :)"' } }

  context 'with a dummy goal' do
    let(:request) { struct query: '"asd"', goal: goal }
    it { expect(result[2][:result]).to eq '"asd"' }
    it { expect(result[1]).to eq :passed }
  end

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', value: '"something"' } }

    context 'and query that matches' do
      let(:request) { struct query: '"something"', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '"somethingElse"', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regexp: /console\.log(.*)/ } }

    context 'and query that matches' do
      let(:request) { struct query: 'console.log("hola")', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'var a = 2', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_outputs goal' do
    let(:goal) { { kind: 'last_query_outputs', output: '3' } }

    context 'and query with said output' do
      let(:request) { struct query: '1 + 2', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with a different output' do
      let(:request) { struct query: '5', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_fails goal' do
    let(:goal) { { kind: 'query_fails', query: 'asd' } }

    context 'and query that makes said query pass' do
      let(:request) { struct query: 'let asd = 2;', goal: goal }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :passed }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'asd' } }

    context 'and query that makes said query pass' do
      let(:request) { struct query: 'let asd = 2;', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'nd query that does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'asd', output: '55' } }

    context 'and query that generates said output' do
      let(:request) { struct query: 'let asd = 55;', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not generate said output' do
      let(:request) { struct query: 'let asd = 28', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'and query that passes' do
      let(:request) { struct query: '123', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that fails' do
      let(:request) { struct query: 'asdasd', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end
end