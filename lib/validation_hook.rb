class JavascriptValidationHook < Mumukit::Hook
  def validate!(request)
    matches = request_matches?(request) do |it|
      it =~ /\W*(require|process|os|fs|eval|cluster|v8|vm|tty|tls|root|global|crypto|stream|events)\W*/
    end
    raise Mumukit::RequestValidationError, "You can not use #{$1} here" if matches
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
