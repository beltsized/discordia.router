local router = {client = {}, attr = {}}
local http = require('coro-http')
local json = require('json')
local base = 'https://discord.com/api/v10'

function router:set(client, attr)
    router.client = client
    router.attr = attr
end

function router:upload(cmds)
    local attr = self.attr

    local res = http.request(
        'PUT', ('%s/applications/%s/commands'):format(base, attr.app),
        {{'Content-Type', 'application/json'}, {'Authorization', ('Bot %s'):format(attr.token)}},
        json.encode(cmds)
    )

    return res.code, res.reason
end

function router:inject(cb)
    local client = self.client

    client:removeAllListeners('raw')
    client:on('raw', function(pkg)
        local data = json.decode(pkg)

        if data.t == 'INTERACTION_CREATE' then
            cb(data.d)
        end
    end)
end

function router:reply(i, payload)
    local attr = self.attr
    local token = i.token
    local id = i.id

    local res = http.request(
        'POST', ('%s/interactions/%s/%s/callback'):format(base, id, token),
        {{'Content-Type', 'application/json'}, {'Authorization', ('Bot %s'):format(attr.token)}},
        json.encode(payload)
    )

    return res.code, res.reason
end

return router
