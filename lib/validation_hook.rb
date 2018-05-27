class JavascriptValidationHook < Mumukit::Hook
  def validate!(request)
    raise Mumukit::RequestValidationError, 'require() is disabled' if uses_require?(request)
    raise Mumukit::RequestValidationError, 'process object is disabled' if uses_process?(request)
  end

  def uses_require?(request)
    request_matches?(request) { |it| it =~ /\W*require\s*\(/ }
  end

  def uses_process?(request)
    request_matches?(request) { |it| it =~ /\W*process\W*/ }
  end


  private

  def request_matches?(request, &block)
    [
        request.content,
        request.extra,
        request.query
    ].compact.any?(&block)
  end
end
