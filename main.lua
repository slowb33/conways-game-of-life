local grid = {}

local gridWidth, gridHeight = love.graphics.getDimensions()
local camScale = 1

local windowWidth, windowHeight = love.graphics.getDimensions()
gridWidth = gridWidth / 2
gridHeight = gridHeight / 2
local states = {
	DEAD = 0,
	LIVE = 1,
}

--[[
	Only modify below if you know what you are doing!
--]]

math.randomseed(os.clock())

function genGrid()
	for x = 1, gridWidth do
		grid[x] = {}
		for y = 1, gridHeight do
			grid[x][y] = {x = x, y = y, state = math.random(0,1)}
		end
	end
end

function getCell(x, y)
	local finalx = x
	local finaly = y
	if x < 1 then
		finalx = gridWidth
	end
	if y < 1 then
		finaly = gridHeight
	end
	if x > gridWidth then
		finalx = 1
	end
	if y > gridHeight then
		finaly = 1
	end
	if grid[finalx][finaly] then
		return grid[finalx][finaly]
	end
end

function countNeighbors(cell)
	local count = -cell.state
	for x = -1, 1 do
		for y = -1, 1 do
			local grab = getCell(cell.x + x, cell.y + y)
			if grab.state == states.LIVE then
				count = count + 1
			end
		end
	end
	return count
end

genGrid()

function love.update()
	if love.keyboard.isDown("t") then
		grid = {}
		genGrid()
	end
	if love.keyboard.isDown("i") then
		camScale = camScale - .1
	end
	if love.keyboard.isDown("o") then
		camScale = camScale + .1
	end
	local changes = {}
	for x = 1, #grid do
		for y = 1, #grid[x] do
			local count = countNeighbors(grid[x][y])
			local cell = getCell(x, y)
			if cell.state == states.DEAD then
				if count == 3 then
					changes[#changes+1] = {x = x, y = y, state = states.LIVE}
				end
			elseif count > 3 or count < 2 then
				changes[#changes+1] = {x = x, y = y, state = states.DEAD}
			end
		end
	end
	for i = 1, #changes do
		if grid[changes[i].x] and grid[changes[i].y] then
			grid[changes[i].x][changes[i].y].state = changes[i].state
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.scale(camScale)
	for x = 1, #grid do
		for y = 1, #grid[x] do
			local cell = getCell(x, y)
			if cell.state == states.LIVE then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle("fill", x, y, 1, 1)
			end
		end
	end
end