-- libraries for router file
local http = require('coro-http') -- http client
local json = require('json') -- json utils

-- libraries for this file
local router = require('example/router') -- the router
local attr = require('example/attr') -- client attributes
local cmds = require('example/cmds') -- cmd list
local lib = require('discordia') -- discord library
local client = lib.Client {logLevel = 0} -- the client

client:once('ready', function()
    -- set data for the router
    router:set(client, attr)
    -- inject into the client
    router:inject(function(i) -- callback for interaction event
        -- reply to the interaction
        router:reply(i, {
            type = 4,
            data = {content = 'test'}
        })
    end)

    -- upload our app cmds to discord
    router:upload(cmds)
end)

-- login to discord
client:run(('Bot %s'):format(attr.token))
