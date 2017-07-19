class JavascriptExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include_smells true

  def language
    'JavaScript'
  end

  def default_smell_exceptions
    %w(UsesCut UsesFail UsesUnificationOperator HasRedundantReduction HasRedundantParameter)
  end
end
