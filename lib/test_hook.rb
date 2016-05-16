class TestHook < Mumukit::Templates::FileHook
  isolated true
  structured true

  def compile_file_content(request)
<<javascript
'use strict';

var assert = require('assert');

#{request.extra}
#{request.content}
#{request.test}
javascript
  end

  def tempfile_extension
    '.js'
  end

  def command_line(filename)
    "#{mocha_command} #{filename} -R json"
  end

  def to_structured_result(result)
    transform(super['tests'])
  end

  def transform(examples)
    examples.map { |e| [e['fullTitle'], e['err'].present? ? :failed : :passed, parse_out(e['err'])] }
  end

  def parse_out(exception)
    exception.present? ? exception['message'] : ''
  end
end
