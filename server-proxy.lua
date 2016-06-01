local connect = require('coro-net').connect
local split = require 'coro-split'
local resource = require 'resource'
local tlsOpts = {ca = resource.load("ca.pem")}

require 'weblit-websocket'
require('weblit-app')

  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))

  .websocket({
    path = "/:protocol/:host/:port"
  }, function (req, read, write)
    p(req.socket:getpeername(), req.params)
    local iread, iwrite = assert(connect{
      host = req.params.host,
      port = tonumber(req.params.port),
      tls = req.params.protocol == 'tls' and tlsOpts
    })
    split(function ()
      for message in read do
        if message.opcode == 2 then
          iwrite(message.payload)
        end
      end
      iwrite()
    end, function ()
      for chunk in iread do
        write{payload=chunk}
      end
      write()
    end)
    print(".")
  end)

  .start()
