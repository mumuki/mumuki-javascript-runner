class QueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.js'
  end

  def compile_file_content(r)
    "#{r.extra}\n#{r.content}\nconsole.log('=> ' + (#{r.query}))"
  end

  def command_line(filename)
    "node #{filename}"
  end
end