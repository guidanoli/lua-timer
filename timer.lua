local timer = {}

function timer:time_1(testf)
	local start = os.clock()
	testf()
	return os.clock() - start
end

function timer:time_n(testf, n, progress_cb)
	local min, max, mean, var = math.huge, -math.huge, 0, 0
	for i = 1, n do
		local t = self:time_1(testf)
		local newmean = (t + (i - 1) * mean) / i
		var = var + (t - mean) * (t - newmean)
		mean = newmean
		min = math.min(min, t)
		max = math.max(max, t)
		if progress_cb then progress_cb(i / n) end
	end
	return {
		min = min,
		max = max,
		mean = mean,
		stddev = math.sqrt(var / n)
	}
end

function timer:time_n_pbar(testf, n)
	local last
	local progress_cb = function(p)
		local curr = math.floor(p * 100)
		if curr ~= last then
			local pbar = string.rep("=", math.floor(73 * p))
			local s = string.format("\r[%-73s] %3d%%", pbar, curr)
			io.stdout:write(s)
			io.stdout:flush()
			last = curr
		end
	end
	local stats = self:time_n(testf, n, progress_cb)
	io.stdout:write(string.format("\r%80s\r", "")) -- clear line
	io.stdout:flush()
	return stats
end

function timer:_has_option(opt)
	for i, v in ipairs(arg) do
		if v == opt then
			return true
		end
	end
	return false
end

function timer:_get_option(opt)
	for i, v in ipairs(arg) do
		if v == opt then
			return arg[i+1]
		end
	end
end

function timer:_concat_args()
	local i = 0
	local s = ""
	while arg[i] ~= nil do
		s = arg[i] .. " " .. s
		i = i - 1
	end
	return s
end

function timer:_sorted_pairs(t)
	local keys = {}
	for key in pairs(t) do table.insert(keys, key) end
	table.sort(keys)
	local i = 0 -- iterator variable
	local iter = function() -- iterator function
		i = i + 1
		local key = keys[i]
		if key == nil then return nil
		else return key, t[key]
		end
	end
	return iter
end


if type(arg) == "table" and arg[0]:find("timer%.lua$") then
	if timer:_has_option('-h') then
		io.stderr:write("Usage: " .. timer:_concat_args() .. "[<args>]\n\n")
		io.stderr:write("Arguments:\n")
		io.stderr:write(" -h    print usage information and exit\n")
		io.stderr:write(" -n #  number of loops, default: 1000000\n")
		io.stderr:write(" -q    don't print progress bar\n")
		os.exit(1)
	end
	local n = tonumber(timer:_get_option("-n") or 1000000)
	local load_cb = function() return io.stdin:read() end
	print("-- setup")
	assert(load(load_cb), "setup code is invalid")()
	print("-- test (" .. n .. " times)")
	local testf = assert(load(load_cb), "test code is invalid")
	local stats = timer:_has_option("-q") and timer:time_n(testf, n) or timer:time_n_pbar(testf, n)
	for k, v in timer:_sorted_pairs(stats) do
		print(string.format("-- %-10s %g", k, v))
	end
end

return timer
