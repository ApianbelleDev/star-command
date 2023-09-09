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

end

function love.draw()
	
	love.graphics.setCanvas(canvas)
	love.graphics.clear();

	-- draw to the canvas
	love.graphics.print("160x144");
	love.graphics.draw(ship.image, ship.x, ship.y);

	-- go back to drawing on screen
	love.graphics.setCanvas()

	-- render canvas on screen
	love.graphics.draw(canvas, 0, 0, 0, screenScale)
	
end
