os       = require("os")
Promise  = require("bluebird")
Sidekick = require("../../lib/sidekick")

describe "Sidekick", ->

  beforeAll ->
    @sidekick = @subject = new Sidekick()
    @hostname_spy = 
      spyOn(os, "hostname").and.returnValue("hostname")

  describe "containerKey", ->

    beforeEach ->
      @subject = @subject.containerKey("container")

    it "generates a container key", ->
      expect(@subject).toEqual([
        ""
        "instances", "hostname"
        "container", "container"
        "image"
      ].join("/"))

  describe "setEtcd", ->

    beforeEach ->
      @subject = @subject.setEtcd()

    it "sets containerKey values in etcd", (done) ->
      @subject.map((response) ->
        value = response[0]
        expect(value).toEqual(
          jasmine.objectContaining(
            action: "set"
            node: jasmine.objectContaining(ttl: 20)
          )
        )
        value
      ).then((values) ->
        expect(values.length).toBeGreaterThan(0)
      ).finally(done)

  describe "setEtcd", ->

    beforeEach ->
      jasmine.clock().install()
      @spy     = spyOn(@subject, "setEtcd")
      @subject = @subject.start()

    afterEach ->
      jasmine.clock().uninstall()

    it "calls setEtcd every 10 seconds", ->
      expect(@spy.calls.count()).toEqual(1)
      jasmine.clock().tick(9999)
      expect(@spy.calls.count()).toEqual(1)
      jasmine.clock().tick(10000)
      expect(@spy.calls.count()).toEqual(2)

  describe "watchEtcd", ->

    beforeEach ->
      @spy = spy: ->
      spyOn(@spy, 'spy')
      @hostname_spy.and.returnValue("hostname2")
      @subject = @subject.watchEtcd(@spy.spy)

    it "calls change event when etcd changes", (done) ->
      expect(
        @spy.spy.calls.count()
      ).toEqual(0)

      @sidekick.setEtcd().settle(=>
        expect(
          @spy.spy.calls.count()
        ).toEqual(1)
        
        expect(
          @spy.spy.calls.argsFor(0)[0]
        ).toEqual(
          jasmine.objectContaining(
            action: 'set'
            node:
              jasmine.objectContaining(
                key:   @sidekick.containerKey("etcd")
                value: jasmine.any(String)
                ttl:   20
              )
          )
        )
      ).finally done