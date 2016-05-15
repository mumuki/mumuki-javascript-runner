class TestHook < Mumukit::Templates::FileHook
  mashup
  isolated true
  structured true

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
    examples.map { |e| [e['fullTitle'], e['status'], parse_out(e['err'])] }
  end

  def parse_out(exception)
    exception ? exception['message'] : ''
  end
end
