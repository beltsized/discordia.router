-- containers
local router = {client = {}, attr = {}} -- router class
local base = 'https://discord.com/api/v10' -- discord api base url
local json = require('json') -- json utils
local http = require('coro-http') -- http client

-- info setter
function router:set(client, attr)
    -- add client to router
    router.client = client
    -- add attributes to router
    router.attr = attr
end

-- cmd uploader
function router:upload(cmds)
    -- get router attributes
    local attr = self.attr

    -- make request to discord api
    local res = http.request(
        'PUT', ('%s/applications/%s/commands'):format(base, attr.app),
        {{'Content-Type', 'application/json'}, {'Authorization', ('Bot %s'):format(attr.token)}},
        json.encode(cmds)
    )

    -- return the code and reason
    return res.code, res.reason
end

-- event injector
function router:inject(cb)
    -- get router client
    local client = self.client

    -- remove all raw listeners to allow callback changing
    client:removeAllListeners('raw')
    -- listen to raw event data with the client
    client:on('raw', function(pkg)
        -- decode the payload
        local data = json.decode(pkg)

        -- check if the event is from an interaction
        if data.t == 'INTERACTION_CREATE' then
            -- run the given callback and pass the interaction data
            cb(data.d)
        end
    end)
end

-- interaction responder
function router:reply(i, payload)
    -- get router attributes
    local attr = self.attr
    -- get interaction token
    local token = i.token
    -- get interaction id
    local id = i.id
    -- make request to discord api
    local res = http.request(
        'POST', ('%s/interactions/%s/%s/callback'):format(base, id, token),
        {{'Content-Type', 'application/json'}, {'Authorization', ('Bot %s'):format(attr.token)}},
        json.encode(payload)
    )

    -- return the code and reason
    return res.code, res.reason
end

-- return the router class
return router
