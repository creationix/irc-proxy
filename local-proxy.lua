local connect = require 'websocket-client'
local split = require 'coro-split'
local server = require('coro-net').createServer({
  port = "6667",
  host = "127.0.0.1",
}, function (read, write)
  local url = 'wss://proxy.creationix.com/tcp/creationix.com/6667'
  local iread, iwrite = assert(connect(url))
  split(function ()
    for chunk in read do
      iwrite {payload=chunk}
    end
    iwrite()
  end, function ()
    for message in iread do
      write(message.payload)
    end
    write()
  end)
end)
p(server:getsockname())
