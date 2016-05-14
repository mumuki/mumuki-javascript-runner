const _true = true;

describe('_true', () => {
  it('is true', () => _true.should.be.eql(true));
  it('is net _false', () => _true.should.not.be.eql(false));
  it('is is something that will fail', () => _true.should.be.eql(3));
});
