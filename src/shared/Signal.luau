--[[
	Signal.luau
	Implementação leve de sinais (padrão Roblox) usada no servidor e no cliente.
]]

local Signal = {}
Signal.__index = Signal

export type Callback = (...any) -> ()

function Signal.new(name: string?)
	local self = setmetatable({}, Signal)
	self._name = name or "Signal"
	self._handlers = {}
	self._yielding = {}
	return self
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "Signal:Connect espera uma função")
	local handle = {
		_callback = callback,
		_connected = true,
		_signal = self,
	}
	table.insert(self._handlers, handle)

	function handle:Disconnect()
		if not self._connected then
			return
		end
		self._connected = false
		local signal = self._signal
		for index, other in ipairs(signal._handlers) do
			if other == self then
				table.remove(signal._handlers, index)
				break
			end
		end
	end

	function handle:Destroy()
		self:Disconnect()
	end

	return handle
end

function Signal:Once(callback)
	local connection
	connection = self:Connect(function(...)
		if connection then
			connection:Disconnect()
		end
		callback(...)
	end)
	return connection
end

function Signal:Fire(...)
	for _, handle in ipairs(table.clone(self._handlers)) do
		if handle._connected then
			local ok, err = pcall(handle._callback, ...)
			if not ok then
				warn(("[%s] erro em handler: %s"):format(self._name, tostring(err)))
			end
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:DisconnectAll()
	for _, handle in ipairs(self._handlers) do
		handle._connected = false
	end
	table.clear(self._handlers)
end

function Signal:GetHandlerCount()
	return #self._handlers
end

return Signal
