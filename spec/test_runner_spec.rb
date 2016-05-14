require_relative './spec_helper'


class File
  def unlink
  end
end


describe 'running' do
  let(:runner) { TestHook.new('mocha_command' => 'mocha') }
  let(:file) { File.new('spec/data/sample.js') }
  let(:file_multi) { File.new('spec/data/sample_multi.js') }
  let(:file_failed) { File.new('spec/data/sample_failed.js') }

  describe '#run_test_command' do
    it { expect(runner.command_line(file.path)).to include('mocha spec/data/sample.js') }
  end

  describe '#run!' do
    context 'on simple passed file' do
      let(:results) { runner.run!(file) }

      it { expect(results[0]).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:results) { runner.run!(file_failed) }

      it { expect(results[0]).to(
          eq([['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end

    context 'on multi file' do
      let(:results) { runner.run!(file_multi) }

      it { expect(results[0]).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is is something that will fail', :failed, "\nexpected: 3\n     got: true\n\n(compared using ==)\n"]])) }
    end
  end
end
