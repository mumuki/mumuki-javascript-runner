require_relative './spec_helper'

describe 'running' do

  let(:runner) { JavascriptTestHook.new('mocha_command' => 'mocha') }

  let(:file) { runner.compile(OpenStruct.new(content: content, test: test, extra: extra)) }
  let(:raw_results) { runner.run!(file) }
  let(:results) { raw_results[0] }
  let(:status) { raw_results[1] }

  let(:extra) { '' }

  let(:content) do
    <<javascript
  const _true = true;
javascript
  end

  describe '#run!' do
    context 'on simple passed file' do
      let(:test) do
        <<javascript
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
javascript
      end

      it { expect(results).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:test) do
        <<javascript
  describe('_true', () => {
    it('is is something that will fail', () => assert.equal(_true, 3));
  });
javascript
      end

      it { expect(results).to(
          eq([['_true is is something that will fail', :failed, format('true == 3')]])) }
    end

    context 'on simple errored file' do
      context 'wrong return token' do
        let(:content) do
          <<javascript
function helloWorld() {
  reurn 4 + 5
}
javascript
        end

        let(:test) do
        <<javascript
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
javascript
        end

        it { expect(status).to eq :errored }
        it { expect(results).to eq(
        <<EOF
solution.js:2
  reurn 4 + 5
        ^

SyntaxError: Unexpected number
EOF
        ) }
      end

      context 'missing open brace' do
        let(:content) do
          <<javascript
function helloWorld()
  return 4 + 5
}
javascript
        end

        let(:test) do
        <<javascript
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
javascript
        end

        it { expect(status).to eq :errored }
        it { expect(results).to eq(
        <<EOF
solution.js:2
  return 4 + 5
  ^^^^^^

SyntaxError: Unexpected token return
EOF
        ) }
      end

      context 'wrong function token' do
        let(:content) do
          <<javascript
funcion helloWorld() {
  return 4 + 5
}
javascript
        end

        let(:test) do
        <<javascript
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
javascript
        end

        it { expect(status).to eq :errored }
        it { expect(results).to eq(
        <<EOF
solution.js:1
funcion helloWorld() {
        ^^^^^^^^^^

SyntaxError: Unexpected identifier
EOF
        ) }
      end

      context 'missing close brace' do
        let(:content) do
          <<javascript
function helloWorld() {
  return 4 + 5

javascript
        end

        let(:test) do
        <<javascript
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
javascript
        end

        it { expect(status).to eq :errored }
        it { expect(results).to eq(
        <<EOF
solution.js:16
});
 ^

SyntaxError: Unexpected token )
EOF
        ) }
      end


    end

    context 'on multi file' do
      let(:test) do
        <<javascript
  describe('_true', function() {
    it('is true', function() {
      assert.equal(_true, true)
    });
    it('is not _false', function() {
      assert.notEqual(_true, false)
    });
    it('is is something that will fail', function() {
      assert.equal(_true, 3)
    });
  });
javascript
end

      it { expect(results).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is is something that will fail', :failed, format('true == 3')]])) }
    end

    context 'when content contains a logging operation' do
      let(:content) do
<<javascript
function a(){
  console.log('An output.')
  return 3
}
javascript
      end

      let(:test) do
<<javascript
describe('a()', function() {
  it('returns 3', function() {
    assert.equal(3, a())
  });
});
javascript
      end

      it { expect(results).to(
          eq([['a() returns 3', :passed, '']])) }
    end
  end
end
