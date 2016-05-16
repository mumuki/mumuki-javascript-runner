'use strict';

var assert = require('assert');

const _true = true;

describe('_true', function() {
  it('is true', function() {
    assert.equal(_true, true)
  });
  it('is not _false', function() {
    assert.notEqual(_true, false)
  });
  it('is is something that will fail', function() {
    assert.equal(_true, 3)
  });
});
