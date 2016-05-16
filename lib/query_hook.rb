class QueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.js'
  end


  def compile_file_content(r)
    "function mumukiConsolePrettyPrint(e) {
        if (e instanceof Function) return '<function>';
        return JSON.stringify(e);
     }
#{r.extra}\n#{r.content}\nconsole.log('=> ' + mumukiConsolePrettyPrint(#{r.query}))"
  end
  def command_line(filename)
    "node #{filename}"
  end
end