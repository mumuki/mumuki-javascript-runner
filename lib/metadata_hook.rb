class JavascriptMetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'javascript',
        icon: {type: 'devicon', name: 'javascript'},
        version: '4.2.4',
        extension: 'js',
        ace_mode: 'javascript_badge'
    },
     test_framework: {
         name: 'mocha',
         version: '2.4.5',
         test_extension: '.js'
     }}
  end
end