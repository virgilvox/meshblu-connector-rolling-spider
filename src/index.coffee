{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-rolling-spider:index')
Drone = require('rolling-spider')

class Connector extends EventEmitter
  spider = {}

  constructor: ->
    @options = {}

  ACTIVE = false
  STEPS = 2

  cooldown: () =>
    ACTIVE = false
    setTimeout ->
      ACTIVE = true
    , STEPS * 12

  messageAll: (command, steps) =>

    if ACTIVE
      if command == 'disconnect'
        @disconnectDrone()
      else if command == 'takeOff'
        spider.flatTrim()
        spider.takeOff()
      else if command == 'land'
        spider.land()
      else if command == 'connect'
        @restartDrone(@options.drones[0])
      else
        STEPS = STEPS || steps
        spider[command] steps: STEPS
        @cooldown()
        STEPS = 2
    else if !ACTIVE
      if command == 'connect'
        @connectDrone(@options.drones[0])

  messageSpecific: (command, memberId, steps) =>
    if ACTIVE
      if command == 'disconnect'
        spider.release()
      else if command == 'takeOff'
        spider.at(memberId).flatTrim()
        spider.at(memberId).takeOff()
      else if command == 'land'
        spider.land()
      else if command == 'connect'
        @restartDrone(@options.drones)
      else
        STEPS = STEPS || steps
        spider.at(memberId)[command] steps: STEPS
        @cooldown()
        STEPS = 2
    else if !ACTIVE
      if command == 'connect'
        @connectSwarm(@options.drones)

  onConfig: (device) =>
    { @options } = device

  restartDrone: (droneOptions) =>
    spider.disconnect() ->
      console.log 'disconnected drone'
      @connectDrone(droneOptions)

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

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector
