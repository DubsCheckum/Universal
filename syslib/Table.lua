local Table = {}

function Table:Contains(tab, val)
	if tab[1] ~= "" then
	    for i=1, #tab, 1 do
		    if tab[i] == val then
			    return true
		    end
	    end
    end
    return false
end

function Table:Dump(o)
    if type(o) == 'table' then
    	local s = '{ '
    	for k,v in pairs(o) do
        	if type(k) ~= 'number' then k = '"'..k..'"' end
        	s = s..'['..k..'] = '..self:Dump(v)..','
        end
        return s..'} '
    else
        return tostring(o)
    end
end

return Table