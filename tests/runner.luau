-- Mini framework de teste compartilhado pelos arquivos *.test.lua
local T = {}

local lines = {}
local passed, failed = 0, 0

function T.check(condition, message)
	if condition then
		passed += 1
		table.insert(lines, "  [ok] " .. message)
	else
		failed += 1
		table.insert(lines, "  [FALHOU] " .. message)
	end
end

function T.equal(actual, expected, message)
	T.check(actual == expected, ("%s (esperado %s, obtido %s)"):format(message, tostring(expected), tostring(actual)))
end

function T.report()
	table.insert(lines, ("  -> %d ok, %d falhas"):format(passed, failed))
	return table.concat(lines, "\n"), failed
end

return T
