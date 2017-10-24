--#ENDPOINT GET /v1/dashboard
-- luacheck: globals request response (magic variables from Murano)

local function injectDatasources(datasources)
	local ret = Keystore.get{key='serialNumbers'}
	if ret.value == nil then
		return datasources
	end
	
	for _, sn in ipairs(ret.value) do

		name = sn .. ' All Raw Timeseries Data'
		idx, _ = table.find(datasources, 'name', name)
		if idx == nil then
			local ads = {
				name = sn .. ' Timeseries',
				type = 'JSON',
				settings = {
					method = 'GET',
					refresh = 10,
					url = '/v1/data/' .. sn,
					use_thingproxy = false
				}
			}
			datasources[#datasources + 1] = ads
		end
	end

	return datasources
end

local got = Keystore.get{key='dashboard.0'}
if got.code ~= nil then
	response.code = got.code
	response.message = got
elseif got.value == nil then
	response.message = {
		allow_edit = true,
		columns = 3,
		datasources = injectDatasources({}),
		version = 1
	}
else
	local ex, err = from_json(got.value)
	if ex ~= nil then

		ex.datasources = injectDatasources(ex.datasources)

		response.message = ex
	else
		response.code = 500
		response.message = err
	end
end

-- vim: set ai sw=2 ts=2 :
