require_relative '../lib/javascript_runner'

def format(result)
  Mumukit::ContentType::Markdown.code result
end
