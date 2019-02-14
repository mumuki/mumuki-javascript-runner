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
    if ['var', 'let', 'const'].any? { |type| is_declaration?(query, type) }
      "#{query}\nconsole.log('=> undefined')"
    else
      "var __mumuki_query_result__ = #{query};\nconsole.log('=> ' + mumukiConsolePrettyPrint(__mumuki_query_result__))"
    end
  end

  def compile_cookie(cookie)
    return if cookie.blank?

    declarations = compile_declarations cookie
    sentences = compile_sentences cookie

    declarations.concat(sentences).join("\n")
  end

  def compile_declarations(cookie)
    cookie
        .map { |query| query.match(let_regexp) }.compact
        .map {|match| "let #{match[1]};" }.uniq
  end

  def compile_sentences(cookie)
    cookie.map do |query|
      query = query.gsub('let ', '') if is_declaration? query, 'let'
      const_matches = query.match const_regexp

      if const_matches
        "const #{const_matches[1]} = (function() { try { return #{query.gsub(const_regexp, '')} } catch(e) { return undefined } })()"
      else
        "try { #{query} } catch (e) {}"
      end
    end
  end

  def command_line(filename)
    "node #{filename}"
  end

  private

  def is_declaration?(query, type)
    query.start_with? "#{type} "
  end

  def let_regexp
    /^let ([a-zA-Z_$][a-zA-Z_$0-9]*)/
  end

  def const_regexp
    /^const ([a-zA-Z_$][a-zA-Z_$0-9]*) *=/
  end
end
