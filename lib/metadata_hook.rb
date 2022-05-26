class JavascriptMetadataHook < Mumukit::Hook
  XCE_INSTRUCTIONS = {
    '*': {
      'en': File.read("xce/en/README.md"),
      'es-ar': File.read("xce/es-ar/README.md"),
      'es-cl': File.read("xce/es-cl/README.md")
    }
  }

  def metadata
    {language: {
        name: 'javascript',
        icon: {type: 'devicon', name: 'javascript'},
        version: '4.2.4',
        extension: 'js',
        ace_mode: 'javascript'
    },
     test_framework: {
         name: 'mocha',
         version: '2.4.5',
         test_extension: '.js',
         template: <<js
describe("{{ test_template_group_description }}", function() {
  it("{{ test_template_sample_description }}", function() {
    assert(true)
  })
})
js
     },
     external_editor_instructions: XCE_INSTRUCTIONS
    }
  end
end
