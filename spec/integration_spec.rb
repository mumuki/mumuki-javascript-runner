require 'active_support/all'
require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'prevents malicious net related code' do
    response = bridge.run_tests!(test: 'let http = require("http"); describe("foo", () => it("bar", (done) => foo(http, done)))',
                                 extra: '',
                                 expectations: [],
                                 content: <<-javascript
function foo(http, done) {
  http.get("http://google.com", (res) => done(res)).on('error', (e) => done(e))
}
javascript
    )
    expect(response[:test_results][0][:result]).to include('getaddrinfo EAI_AGAIN google.com:80')
    expect(response[:status]).to eq(:failed)
  end

  it 'prevents calls to node require' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", (done) => foo(http, done)))',
                                 extra: '',
                                 expectations: [],
                                 content: 'require("something");')
    expect(response[:status]).to eq :aborted
    expect(response[:result]).to eq 'You can not use require here'
  end

  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 3)))',
                                 extra: '',
                                 content: 'let aVariable = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is ok but has part of blacklisted words' do
    response = bridge.run_tests!(test: 'describe("foos", () => it("bar", () => assert.equal(aVariable, 3)))',
                                 extra: 'let flos = 75;',
                                 content: 'let aVariable = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foos bar', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is ok with warnings' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(x, 3)))',
                                 extra: '',
                                 content: 'let x = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed_with_warnings,
                           feedback: '',
                           expectation_results: [{binding: 'x', inspection: 'HasTooShortIdentifiers', result: :failed}],
                           result: '')
  end

  it 'answers a valid hash when submission is ok with JS-specific warnings' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(something, 3)))',
                                 extra: '',
                                 content: 'var something = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed_with_warnings,
                           feedback: '',
                           expectation_results: [{binding: '*', inspection: 'JavaScript#UsesVarInsteadOfLet', result: :failed}],
                           result: '')
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 3)))',
                   extra: '',
                   content: 'let aVariable = 2',
                   expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [
                               {title: 'foo bar', status: :failed, result: format('2 == 3')}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission timeouts' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", function (done) { this.timeout(5000); setTimeout(() => { assert.equal(x, 3); done() }, 5000) }))',
                   extra: '',
                   content: 'let x = 2',
                   expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :aborted,
                           feedback: '',
                           expectation_results: [{binding: 'x', inspection: 'HasTooShortIdentifiers', result: :failed}],
                           result: 'Execution time limit of 4s exceeded. Is your program performing an infinite loop or recursion?')
  end


  it 'answers a valid hash when submission has compilation errors' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(x, 3)))',
                   extra: '',
                   content: 'let x = ).',
                   expectations: [])

    expect(response[:status]).to eq :errored
    expect(response[:response_type]).to eq(:unstructured)
    expect(response[:test_results]).to be_empty
    expect(response[:result]).to include('SyntaxError: Unexpected token )')

  end

  it 'answers a valid hash when given a known locale' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 4)))',
                                 extra: '',
                                 content: 'let aVariable = 3',
                                 expectations: [],
                                 locale: 'pt')

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :failed, result: format('3 == 4')}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission fails with `is not defined`' do
    response = bridge.run_tests!(
        test: %q{
          describe("average", () => {
            it("works with 3 elements", () => {
              assert.equal(average([1, 2, 3]), 3);
            });
            it("works with 2 elements", () => {
              assert.equal(average([1, 3]), 3);
            });
          });
        },
        extra: '',
        content: 'function average(list) {  return  sum(list) / list.length }',
        expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [
                             {result: format('sum is not defined'), status: :failed, title: 'average works with 3 elements'},
                             {result: format('sum is not defined'), status: :failed, title: 'average works with 2 elements'}],
                           status: :failed,
                           feedback: '* it looks like you are using `sum` but it is not defined. Perhaps you have misspelled it or you need to define it',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission passes and has non-ascii chars' do
    response = bridge.run_tests!(
      test: %q{
      describe("", function() {
        let gustavo = {
          nombre: "Gustavo Girot",
          librosLeidos: ["Fundación", "Yo, Robot", "El resplandor", "Socorro"],
          anioSuscripcion: 2010
        };

        it("el resumenLector de gustavo nos provee su información", function() {
          assert.equal(resumenLector(gustavo), "Gustavo Girot se suscribió hace 10 años")
        })
      })
    },
    extra: '',
    content: %q{
    function resumenLector(quien) {
      return quien.nombre + " se suscribió hace " + (2020 - quien.anioSuscripcion)  + " años";
    }},
    expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{result: "", status: :passed, title: "el resumenLector de gustavo nos provee su información"}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a properly formatted hash when result includes quotation marks' do
    response = bridge.run_tests!(
      test: %q{
      describe("", function() {
        let juan = {
          nombre: "juan arrever",
          librosLeidos: ["El conde de Montecristo", "La palabra", "Mi planta de naranja lima"],
          anioSuscripcion: 1992
        };

        let elena = {
          nombre: "elena chalver",
          librosLeidos: ["Rabia", "Vida de Bob Marley"],
          anioSuscripcion: 1987
        };

        let gustavo = {
          nombre: "gustavo girot",
          librosLeidos: ["Fundación", "Yo, Robot", "El resplandor", "Socorro"],
          anioSuscripcion: 2010
        };

        it("el resumenSuscripcion de gustavo nos provee su información", function() {
          assert.equal(resumenSuscripcion(gustavo), "gustavo girot se suscribio hace 10 años y leyo 4 libros")
        })

        it("el resumenSuscripcion de juan nos provee su información", function() {
          assert.equal(resumenSuscripcion(juan), "juan arrever se suscribio hace 28 años y leyo 3 libros")
        })

        it("el resumenSuscripcion de elena nos provee su información", function() {
          assert.equal(resumenSuscripcion(elena), "elena chalver se suscribio hace 33 años y leyo 2 libros")
        })
      })
    },
      extra: 'function longitud(unStringOLista) { return unStringOLista.length;}',
      content: %q{
      function resumenSuscripcion(registro) {
        return registro.nombre + " " + "se suscribio hace " + ( 2020 - registro.anioSuscripcion) + " " + "años" + " " + "y leyo " + " " + longitud(registro.librosLeidos) + " " + "libros";
      }},
      expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'el resumenSuscripcion de gustavo nos provee su información',
                                           status: :failed,
                                           result: format("'gustavo girot se suscribio hace 10 años y leyo  4 libros' == 'gustavo girot se suscribio hace 10 años y leyo 4 libros'")},
                                          {title: 'el resumenSuscripcion de juan nos provee su información',
                                           status: :failed,
                                           result: format("'juan arrever se suscribio hace 28 años y leyo  3 libros' == 'juan arrever se suscribio hace 28 años y leyo 3 libros'")},
                                          {title: 'el resumenSuscripcion de elena nos provee su información',
                                           status: :failed,
                                           result: format("'elena chalver se suscribio hace 33 años y leyo  2 libros' == 'elena chalver se suscribio hace 33 años y leyo 2 libros'")}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


end
