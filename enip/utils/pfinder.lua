
return function(types, base_pn)
	return function(code, appendix)
		for k, v in pairs(types) do
			if v == code then
				local p_name = base_pn..'.'..string.lower(k)
				p_name = appendix and p_name..'.'..appendix or p_name
				local r, p = pcall(require, p_name)
				if not r then
					return nil, p
				end
				return p
			end
		end
		return nil, "No package found:"..code
	end
end
