require_relative './spec_helper'

describe JavascriptValidationHook do
  let(:hook) { JavascriptValidationHook.new }

  it { expect { hook.validate! struct(content: 'require("fs")') }.to raise_error('require() is disabled') }

  it { expect { hook.validate! struct(query: 'require("fs")') }.to raise_error('require() is disabled') }
  it { expect { hook.validate! struct(query: '(require("fs"))') }.to raise_error('require() is disabled') }
  it { expect { hook.validate! struct(query: ' require  ( "fs"  )') }.to raise_error('require() is disabled') }
  it { expect(hook.validate! struct(query: 'isRequired("fs")')).to be nil }
  it { expect(hook.validate! struct(query: '(isRequired("fs"))')).to be nil }

  it { expect { hook.validate! struct(query: 'process.argv') }.to raise_error('process object is disabled') }
  it { expect { hook.validate! struct(query: 'process') }.to raise_error('process object is disabled') }
  it { expect { hook.validate! struct(query: '(process)') }.to raise_error('process object is disabled') }
  it { expect(hook.validate! struct(query: 'aProcess')).to be nil }


end
