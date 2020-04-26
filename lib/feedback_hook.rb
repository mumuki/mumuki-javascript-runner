class JavascriptFeedbackHook < Mumukit::Hook
  def run!(request, results)
    content = request.content
    test_results = test_failure_messages results

    JavascriptExplainer.new.explain(content, test_results)
  end

  def test_failure_messages(results)
    structured_test_results = results.test_results[0]
    if structured_test_results.is_a? Array
      structured_test_results.select { |it| it[1].failed? }.map { |it| it[2] }.join("\n")
    else
      ''
    end
  end

  class JavascriptExplainer < Mumukit::Explainer
    def explain_is_not_defined(_, test_results)
      (/([a-zA-Z0-9_]+) is not defined/.match test_results).try do |it|
        {identifier: it[1]}
      end
    end
  end
end
