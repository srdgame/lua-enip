local session = require 'cip.session'
local base = require 'enip.client.base'
local enip_conn_path = require 'enip.conn_path'

local client = base:subclass('enip.client.connected')

function client:send_rr_data(cip, response)
end

function client:send_unit_data(cip, response)
end

return client
