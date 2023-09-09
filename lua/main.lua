local sx, sy
local screenScale

function love.load()

	-- setup tables for objects
	ship = {}
	ship.image = love.graphics.newImage("res/ship.png", nil)
	ship.x = 80 - 16
	ship.y = 144 - 16

	-- override default filter so game when scaled up doesn't look blurry
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

	sx = 160;
	sy = 144;

	screenScale = 4.0;
	-- create canvas to draw to that will be scaled later
	canvas = love.graphics.newCanvas(sx, sy)

	-- override default screen res
	love.window.setMode(sx * 4, sy * 4)
end

function love.update()
	-- ship left/right movement
	if love.keyboard.isDown("left") then
		ship.x = ship.x - 1
	end

	if love.keyboard.isDown("right") then
		ship.x = ship.x + 1
	end
	
	-- stop ship if it hits screen bounds
	if ship.x <= 0 then
		ship.x = 0	
	end

	if ship.x >= 160 - 32 then
		ship.x = 160 - 32
	end
end

function love.draw()
	
	love.graphics.setCanvas(canvas)
	love.graphics.clear();

	-- draw to the canvas
	love.graphics.print("x = "..tostring(ship.x));
	love.graphics.draw(ship.image, ship.x, ship.y);

	-- go back to drawing on screen
	love.graphics.setCanvas()

	-- render canvas on screen
	love.graphics.draw(canvas, 0, 0, 0, screenScale)
	
end
