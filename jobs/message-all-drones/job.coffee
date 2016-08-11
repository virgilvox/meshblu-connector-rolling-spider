http = require 'http'

class MessageAllDrones
  constructor: ({@connector}) ->
    throw new Error 'MessageAllDrones requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.command is required') unless data?.command?

    @connector.messageAll data.command, data.steps

    callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MessageAllDrones
