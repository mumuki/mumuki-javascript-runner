class JavascriptQueryHook < Mumukit::Templates::FileHook
  isolated true

  VAR_REGEXP = /^ *(?:var|let) +([a-zA-Z_$][a-zA-Z_$0-9]*)/
  VAR_ASSIGN_REGEXP = /^ *(?:var|let) +([a-zA-Z_$][a-zA-Z_$0-9]*) *=/
  CONST_ASSIGN_REGEXP = /^ *const +([a-zA-Z_$][a-zA-Z_$0-9]*) *=/

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
    if ['var', 'let', 'const'].any? { |type| query.start_with? "#{type} " }
      "#{query}\nconsole.log('=> undefined')"
    else
      "var __mumuki_query_result__ = #{query};\nconsole.log('=> ' + mumukiConsolePrettyPrint(__mumuki_query_result__))"
    end
  end

  def compile_cookie(cookie)
    return if cookie.blank?

    compile_statements(cookie).join "\n"
  end

  def command_line(filename)
    "node #{filename}"
  end

  private

  def compile_statements(cookie)
    reject_duplicated_statements wrap_statements(cookie)
  end

  def wrap_statements(cookie)
    cookie.map do |query|
      case query
      when CONST_ASSIGN_REGEXP
        declaration_with_assignment 'const', $1, query.gsub(CONST_ASSIGN_REGEXP, '')
      when VAR_ASSIGN_REGEXP
        declaration_with_assignment 'var', $1, query.gsub(VAR_ASSIGN_REGEXP, '')
      when VAR_REGEXP
        "var #{$1}"
      else
        "try { #{query} } catch (e) {}"
      end
    end
  end

  def reject_duplicated_statements(sentences)
    sentences.select.with_index do |line, index|
      next line if !line.match(VAR_ASSIGN_REGEXP) && !line.match(VAR_REGEXP) && !line.match(CONST_ASSIGN_REGEXP)
      name = $1
      sentences.slice(0, index).none? { |previous_line| declaration? previous_line, name }
    end
  end

  def declaration_with_assignment(type, name, expression)
    "#{type} #{name} = (function() { try { return #{expression} } catch(e) { return undefined } })()"
  end

  def declaration?(line, name)
    var_declaration?(line, name) || const_declaration?(line, name)
  end

  def var_declaration?(line, name)
    (line.match(VAR_REGEXP) && $1 == name) || (line.match(VAR_ASSIGN_REGEXP) && $1 == name)
  end

  def const_declaration?(line, name)
    line.match(CONST_ASSIGN_REGEXP) && $1 == name
  end
end
