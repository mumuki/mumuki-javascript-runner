class JavascriptTryHook < Mumukit::Templates::TryHook
  isolated true
  attr_reader :query_hook

  def initialize(config = nil)
    super config
    @query_hook = JavascriptQueryHook.new
  end

  def compile_file_content(r)
    <<js
#{@query_hook.compile_file_header(r)}
console.log("#{query_separator}");
#{@query_hook.compile_query(r.query, '')}
console.log("#{goal_separator}");
#{@query_hook.compile_query(r.goal.with_indifferent_access[:query] || 'null', '', '__mumuki_goal_query_result__')}
js
  end

  delegate :tempfile_extension, to: :query_hook
  delegate :command_line, to: :query_hook

  def query_separator
    '!!!MUMUKI-QUERY-START!!!'
  end

  def goal_separator
    '!!!MUMUKI-GOAL-START!!!'
  end

  def to_structured_results(_file, result, status)
    /#{query_separator}
?(.*)
#{goal_separator}
?(.*)
/m =~ result

    {
        query: to_query_result($1, status),
        goal: $2,
        status: status
    }
  end

  def to_query_result(result, status)
    { result: result, status: status }
  end
end