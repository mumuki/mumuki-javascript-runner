class QueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.js'
  end


  def compile_file_content(r)
<<javascript
function mumukiConsolePrettyPrint(e) {
    if (e instanceof Function) return '<function>';
    return JSON.stringify(e);
 }

#{r.extra}

#{r.content}

#{compile_cookie(r.cookie)}

#{compile_query(r.query)}
javascript
  end

  def compile_query(query)
    if query.start_with? 'var '
      "#{query}\nconsole.log('=> undefined')"
    else
      "console.log('=> ' + mumukiConsolePrettyPrint(#{query}))"
    end
  end

  def compile_cookie(cookie)
    return if cookie.blank?
    cookie.map { |query| "try { #{query} } catch (e) {}" }.join("\n")
  end

  def command_line(filename)
    "node #{filename}"
  end
end