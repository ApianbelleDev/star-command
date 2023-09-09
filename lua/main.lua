local sx, sy
local screenScale

function love.load()

	-- setup tables for objects
	ship = {}
	ship.image = love.graphics.newImage("res/ship.png", nil)
	ship.x = 80 - 16
	ship.y = 144 - 16

	bullet = {}
	-- bullet.image = love.graphics.newImage("res/bullet.png", nil)

	-- store bullet off screen
	bullet.x = -100
	bullet.y = -100
	bullet.isShot = false
	bullet.count = 1

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

	-- bullet logic
	if bullet.isShot == true then
		bullet.y = bullet.y - 1
	end
	
	if love.keyboard.isDown("x") or love.keyboard.isDown("c") then
		if bullet.count == 1 then
			bullet.x = ship.x + 16
			bullet.y = ship.y
			bullet.count = 0
			bullet.isShot = true
		end
	end

	-- destroy bullet if it reaches the top of the screen
	if bullet.y == 0 then
		bullet.isShot = false
		bullet.count = 1
		bullet.x = -100
		bullet.y = -100
	end

end

function love.draw()
	
	love.graphics.setCanvas(canvas)
	love.graphics.clear();

	-- draw to the canvas
	love.graphics.draw(ship.image, ship.x, ship.y);
	love.graphics.rectangle("fill", bullet.x, bullet.y, 4, 4);

	-- go back to drawing on screen
	love.graphics.setCanvas()
	love.graphics.print("ship x = "..tostring(ship.x));
	love.graphics.print("bulletCount = "..tostring(bullet.count), 0, 16);
	love.graphics.print("isShot = "..tostring(bullet.isShot), 0, 32);

	-- render canvas on screen
	love.graphics.draw(canvas, 0, 0, 0, screenScale)	
end
