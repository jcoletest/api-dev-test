'use strict'

const expect = require('chai').expect
const sinon = require('sinon')
const rootDir = '../../..'
const rootBoot = require(`${rootDir}/server/boot/root.js`)

describe('Root Boot Script', function () {
  it('should return the server status via loopback router', function () {
    let server = {
      use: sinon.stub(),
      loopback: {
        Router: sinon.stub().returns({
          get: sinon.stub(),
        }),
        status: sinon.stub(),
      },
    }
    rootBoot(server)
    expect(server.use.called).to.be.true
  })
})
