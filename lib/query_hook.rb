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

console.log('=> ' + mumukiConsolePrettyPrint(#{r.query}))
javascript
  end

  def compile_cookie(cookie)
    return if cookie.blank?
    cookie.map { |query| "try { #{query} } catch (e) {}" }
  end

  def command_line(filename)
    "node #{filename}"
  end
end