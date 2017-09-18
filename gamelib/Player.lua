local Player = {}

function Player:IsOnCell(X, Y)
	if getPlayerX() == X and getPlayerY() == Y then
		return true
	end
	return false
end

function Player:UseMount()
	-- body
end

return Player