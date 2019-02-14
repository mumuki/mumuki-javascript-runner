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
    if ['var', 'let', 'const'].any? { |type| query.start_with? "#{type} " }
      "#{query}\nconsole.log('=> undefined')"
    else
      "var __mumuki_query_result__ = #{query};\nconsole.log('=> ' + mumukiConsolePrettyPrint(__mumuki_query_result__))"
    end
  end

  def compile_cookie(cookie)
    return if cookie.blank?

    compile_sentences(cookie).join "\n"
  end

  def command_line(filename)
    "node #{filename}"
  end

  private

  def compile_sentences(cookie)
    sentences = cookie.map do |query|
      var_matches = query.match var_regexp
      var_assign_matches = query.match var_assign_regexp
      const_assign_matches = query.match const_assign_regexp

      if const_assign_matches
        declaration_with_assignment 'const', const_assign_matches[1], query.gsub(const_assign_regexp, '')
      elsif var_matches
        name = var_matches[1]

        if var_assign_matches
          declaration_with_assignment 'var', var_assign_matches[1], query.gsub(var_assign_regexp, '')
        else
          "var #{name}"
        end
      else
        "try { #{query} } catch (e) {}"
      end
    end

    sentences.select.with_index do |line, index|
      next line if !line.match(var_regexp) && !line.match(var_assign_regexp) && !line.match(const_assign_regexp)

      name = (line.match(var_assign_regexp) || line.match(var_regexp) || line.match(const_assign_regexp))[1]
      sentences.slice(0, index).none? { |previousLine| is_declaration? previousLine, name }
    end
  end

  def declaration_with_assignment(type, name, expression)
    "#{type} #{name} = (function() { try { return #{expression} } catch(e) { return undefined } })()"
  end

  def is_declaration?(line, name)
    is_var_declaration?(line, name) || is_const_declaration?(line, name)
  end

  def is_var_declaration?(line, name)
    var_matches = line.match var_regexp
    var_assign_matches = line.match var_assign_regexp

    (var_matches && var_matches[1] == name) || (var_assign_matches && var_assign_matches[1] == name)
  end

  def is_const_declaration?(line, name)
    const_assign_matches = line.match const_assign_regexp
    const_assign_matches && const_assign_matches[1] == name
  end

  def var_regexp
    /^ *(?:var|let) ([a-zA-Z_$][a-zA-Z_$0-9]*)/
  end

  def var_assign_regexp
    /^ *(?:var|let) ([a-zA-Z_$][a-zA-Z_$0-9]*) *=/
  end

  def const_assign_regexp
    /^ *const ([a-zA-Z_$][a-zA-Z_$0-9]*) *=/
  end
end
