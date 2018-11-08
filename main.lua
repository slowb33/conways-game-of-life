local cells = {}

local gridSize = 500

local scale = 1
local camx, camy = 0, 0

function newCell(x, y, state)
  local new = {
    x = x, y = y, state = state,
  }
  function new:setState(set)
    self.state = set
  end
  cells[x][y] = new
  return new
end

function genGrid()
  for x = 1, gridSize do
    cells[x] = {}
    for y = 1, gridSize do
      newCell(x, y, math.random(0,1))
    end
  end
end

function getCell(x, y)
  local new_x, new_y = x, y
  if x > gridSize then
    new_x = 1
  elseif x < 1 then
    new_x = gridSize
  end
  if y > gridSize then
    new_y = 1
  elseif y < 1 then
    new_y = gridSize
  end
  if cells[new_x] and cells[new_x][new_y] then
    return cells[new_x][new_y]
  end
end

function countNeighbors(cell)
  local count = -cell.state
  for x = -1, 1 do
    for y = -1, 1 do
      count = count + getCell(cell.x + x, cell.y + y).state
    end
  end
  return count
end

function applyChanges(changes)
  for i = 1, #changes do
    changes[i].cell:setState(changes[i].set)
  end
end

genGrid()

function isDown(list)
  for i,v in pairs(list) do
    if v.func(v.arg) then
      v.run()
    end
  end
end

function love.update()
  isDown({
    {func = love.keyboard.isDown, arg = "w", run = function()
      camy = camy + 1
    end};
    {func = love.keyboard.isDown, arg = "a", run = function()
      camx = camx + 1
    end};
    {func = love.keyboard.isDown, arg = "s", run = function()
      camy = camy - 1
    end};
    {func = love.keyboard.isDown, arg = "d", run = function()
      camx = camx - 1
    end};
    {func = love.keyboard.isDown, arg = "i", run = function()
      scale = scale + .1
    end};
    {func = love.keyboard.isDown, arg = "o", run = function()
      scale = scale - .1
    end};
    {func = love.keyboard.isDown, arg = "r", run = function()
      scale = 1
      camx = 0
      camy = 0
    end};
    {func = love.keyboard.isDown, arg = "t", run = function()
      cells = {}
      genGrid()
    end};
  })
  local changes = {}
  for x = 1, #cells do
    for y = 1, #cells[x] do
      local cell = getCell(x, y)
      local count = countNeighbors(cell)
      if cell.state == 1 and (count > 3 or count < 2) then
        changes[#changes + 1] = {cell = cell, set = 0}
      elseif cell.state == 0 and count == 3 then
        changes[#changes + 1] = {cell = cell, set = 1}
      end
    end
  end
  applyChanges(changes)
end

function love.draw()
  local live_cells = 0
  love.graphics.setColor(1,1,1)
  love.graphics.scale(scale)
  love.graphics.translate(camx, camy)
  love.graphics.translate(0, 50)
  for x = 1, #cells do
    for y = 1, #cells[x] do
      if cells[x][y].state == 1 then
        love.graphics.rectangle("fill", x, y, 1, 1)
        live_cells = live_cells + 1
      end
    end
  end
  love.graphics.printf("Living Cells: "..live_cells, -500, -50, 500, "center", 0, 3, 3)
end
