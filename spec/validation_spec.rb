require_relative './spec_helper'

describe JavascriptValidationHook do
  let(:hook) { JavascriptValidationHook.new }

  it { expect { hook.validate! struct(content: 'require("fs")') }.to raise_error('You can not use require here') }

  it { expect { hook.validate! struct(query: 'require("fs")') }.to raise_error('You can not use require here') }
  it { expect { hook.validate! struct(query: '(require("fs"))') }.to raise_error('You can not use require here') }
  it { expect { hook.validate! struct(query: ' require  ( "fs"  )') }.to raise_error('You can not use require here') }
  it { expect(hook.validate! struct(query: 'isRequired("something")')).to be nil }
  it { expect(hook.validate! struct(query: '(isRequired("something"))')).to be nil }

  it { expect { hook.validate! struct(query: 'eval("x")') }.to raise_error('You can not use eval here') }

  it { expect { hook.validate! struct(query: 'process.argv') }.to raise_error('You can not use process here') }
  it { expect { hook.validate! struct(query: ' process.argv ') }.to raise_error('You can not use process here') }
  it { expect { hook.validate! struct(query: 'process') }.to raise_error('You can not use process here') }
  it { expect { hook.validate! struct(query: '(process)') }.to raise_error('You can not use process here') }
  it { expect(hook.validate! struct(query: 'aProcess')).to be nil }

  it { expect(hook.validate! struct(extra: 'var pesoPromedioPersonaEnKilogramos = 75;')).to be nil }

end
