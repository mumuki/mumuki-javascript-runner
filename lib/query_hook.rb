class JavascriptQueryHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.js'
  end


  def compile_file_content(r)
<<javascript
'use strict';

function mumukiConsolePrettyPrint(e) {
    if (e instanceof Function) return '<function>';
    const json = JSON.stringify(e);
    return json && json.replace(/"(\\w+)"\s*:/g, '$1:');
 }

#{r.extra}

#{r.content}

#{compile_cookie(r.cookie)}

#{compile_query(r.query)}
javascript
  end

  def compile_query(query)
    if query.start_with?('var ') || query.start_with?('let ')
      "#{query}\nconsole.log('=> undefined')"
    else
      "var __mumuki_query_result__ = #{query};\nconsole.log('=> ' + mumukiConsolePrettyPrint(__mumuki_query_result__))"
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
