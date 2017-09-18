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

return Table