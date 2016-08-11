{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-rolling-spider:index')
Drone = require('rolling-spider')

class Connector extends EventEmitter
  constructor: ->
    ACTIVE = false
    STEPS = 2
    spider = {}

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  droneCommand: (command, memberId, specific, callback) =>
    if ACTIVE
      if command == 'disconnect'
        @disconnectDrone() unless @options.swarm == true
        spider.release()
      else if command == 'takeOff'
        if @options.swarm == true && specific == true
          spider.at(memberId).flatTrim()
          spider.at(memberId).takeOff()
          @cooldown()
        else
          spider.flatTrim()
          spider.takeOff()
          @cooldown()
      else if command == 'land'
        spider.land()
      else
        STEPS = STEPS || payload.steps
        spider[command] steps: STEPS unless @options.swarm == true && specific == true
        spider.at(memberId)[command] steps: STEPS
        @cooldown()
        STEPS = 2
    else if !ACTIVE
      if command == 'connect'
        @connectDrone(@options.drones[0]) unless @options.swarm == true
        @connectSwarm(@options.drones)
    callback null

  connectDrone: (droneOptions={}) =>
    spider =  new Drone(droneOptions)

    spider.connect ->
      spider.setup ->
        console.log 'Configured for Rolling Spider! ', spider.name
        spider.flatTrim()
        spider.startPing()
        spider.flatTrim()

        setTimeout (->
          console.log 'ready for flight'
          ACTIVE = true
        ), 1000

  connectSwarm: (members=[]) =>
    spider = new Drone.Swarm({membership: members, timeout: 10});

    spider.assemble()

    spider.on 'assembled', ->
     spider.flatTrim()
     spider.flatTrim()
     setTimeout (->
       console.log 'ready for flight'
       ACTIVE = true
     ), 1000

  disconnectDrone: () =>
    spider.disconnect() ->
      console.log 'disconnected drone'

    ACTIVE = false

  cooldown: () =>
    ACTIVE = false
    setTimeout ->
      ACTIVE = true
    , STEPS * 12

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector
