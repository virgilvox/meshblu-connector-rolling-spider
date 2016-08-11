http = require 'http'

class MessageAllDrones
  constructor: ({@connector}) ->
    throw new Error 'MessageAllDrones requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.command is required') unless data?.command?

    @connector.droneCommand data.command, "", false, (done) =>
      metadata =
        code: 200
        status: http.STATUS_CODES[200]

      callback null, {metadata}

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MessageAllDrones
