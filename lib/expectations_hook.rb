class JavascriptExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include_smells true


  def run!(spec)
    super(spec) + run_eslint(spec[:request][:content])
  end

  def run_eslint(content)
    lines = content.lines
    out, status = Open3.capture2("eslint --format json --stdin", stdin_data: content)
    result = JSON.parse(out)[0]

    if result["fatalErrorCount"] == 0
      result["messages"].map do |it|
        {
          expectation: {
            binding: lines[it["line"] - 1],
            inspection: it["ruleId"]
          },
          result: false
        }
      end
    else
      []
    end

  end

  def language
    'JavaScript'
  end

  def default_smell_exceptions
    %w(UsesCut UsesFail UsesUnificationOperator HasRedundantReduction HasRedundantParameter)
  end
end
