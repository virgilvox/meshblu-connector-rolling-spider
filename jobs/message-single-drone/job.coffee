http = require 'http'

class MessageSingleDrone
  constructor: ({@connector}) ->
    throw new Error 'MessageSingleDrone requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.command is required') unless data?.command?

    @connector.messageSpecific data.command, data.memberId, data.steps
    
    callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MessageSingleDrone
