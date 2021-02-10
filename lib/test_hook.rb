class JavascriptTestHook < Mumukit::Templates::FileHook
  isolated true
  structured true, separator: '!!!JAVASCRIPT-MUMUKI-OUTPUT!!!'
  line_number_offset 3, include_extra: true

  def compile_file_content(request)
<<javascript
'use strict';
let assert = require('assert');
#{request.extra}
#{request.content}
describe('', function() {
  after(function() {
    console.log("!!!JAVASCRIPT-MUMUKI-OUTPUT!!!");
  });
  #{request.test}
})

javascript
  end

  def tempfile_extension
    '.js'
  end

  def command_line(filename)
    "mocha #{filename} -R json"
  end

  def to_structured_result(result)
    transform(super['tests'])
  end

  def post_process_unstructured_result(file, result, status)
    if status.errored?
      [content_type.code(result.gsub(/(SyntaxError: .*\n)(.|\n)*/) { $1 }), status]
    else
      super
    end
  end

  def transform(examples)
    examples.map { |e| [e['fullTitle'], e['err'].present? ? :failed : :passed, parse_out(e['err'])] }
  end

  def parse_out(exception)
    exception.present? ? content_type.code(exception['message']) : ''
  end
end
