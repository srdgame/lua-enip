
return function(types, base_pn)
	return function(code)
		for k, v in pairs(types) do
			if v == code then
				local r, p = pcall(require, base_pn..'.'..string.lower(k))
				if not r then
					return nil, p
				end
				return p
			end
		end
		return nil, "No package found:"..code
	end
end
