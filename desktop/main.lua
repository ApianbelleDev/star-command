local sx, sy
local screenScale

function love.load()
	sx = 160
	sy = 144

	-- setup tables for objects
	game   = {}
	ship   = {}
	bullet = {}
	comet  = {}

	game.isPaused   = false
	game.gameOver   = false
	game.altPalette = false
	game.text = "nothing" -- debug text
	game.state = "TITLE"
	game.cur = 0
	game.score = 0
	game.font = love.graphics.setNewFont("res/fonts/monobit.ttf", 16)
	game.menuTimer = 180
	game.startTimer = 180

	game.bg    = love.graphics.newImage("res/bg.png")
	game.bg_dmg = love.graphics.newImage("res/bg_dmg.png")
	game.title = love.graphics.newImage("res/title.png")
	game.title_dmg = love.graphics.newImage("res/title_dmg.png")
	
	ship.x = 80 - 16
	ship.y = 144 - 16
	ship.w = 32
	ship.h = 16
	ship.speed = 60

	ship.image    = love.graphics.newImage("res/ship.png")
	ship.image_dmg = love.graphics.newImage("res/ship_dmg.png")

	-- store bullet off screen
	bullet.x = -100
	bullet.y = -100
	bullet.w = 4
	bullet.h = bullet.w
	bullet.speed = 70
	bullet.isShot = false

	bullet.image     = love.graphics.newImage("res/bullet.png")
	bullet.image_dmg = love.graphics.newImage("res/bullet_dmg.png")

	
	comet.x = love.math.random(1, sx - 16)
	comet.y = -200
	comet.sx = 0
	comet.sy = 0
	comet.w = 16
	comet.h = comet.w
	comet.speed = 30
	comet.spawnTimer = 60
	comet.isDestroyed = false
	comet.isMoving = false

	comet.image    = love.graphics.newImage("res/comet.png")
	comet.image_dmg = love.graphics.newImage("res/comet_dmg.png")

	
	
	-- override default filter so game when scaled up doesn't look blurry
	love.graphics.setDefaultFilter("nearest", nil, 0)

	screenScale = 4.0
	-- create canvas to draw to that will be scaled later
	canvas = love.graphics.newCanvas(sx, sy)

	-- override default screen res
	love.window.setMode(sx * 4, sy * 4)
end

function love.keypressed( key )
		if key == "return" and game.state == "TITLE" then
			--menu options
			if game.cur == 0 then
				game.state = "GAMEPLAY"
			elseif game.cur == 1 then
				game.state = "SETTINGS" 
			elseif game.cur == 2 then
				love.window.close()
			end
			if key == "up" then
			game.cur = game.cur - 1
			elseif key == "down" then
			game.cur = game.cur + 1
		end
		elseif key == "return" and game.state == "GAMEPLAY" then
			--pausing logic
			if not game.isPaused then
				game.isPaused = true
			elseif game.isPaused then
				game.isPaused = false
			end
		elseif key == "return" or menuTimer == 0 and game.state == "GAME OVER" then
			game.state = "TITLE"
		end

		-- cursor wrapping
		if game.cur > 2 then
			game.cur = 0;
		elseif game.cur < 0 then
			game.cur = 2
		end

		-- switch between alternate palette and normal palette
		if key == "rshift" then
			if not game.altPalette then
				game.altPalette = true
			elseif game.altPalette then
				game.altPalette = false
			end
		end
end

function resetBullet()
	bullet.isShot = false
	bullet.x = -100
	bullet.y = -100
end

function love.update(dt)
	if game.state == "GAMEPLAY" then
		
		if not game.isPaused then
			-- decrement timers, and initialize score to 0 when the round beginsbl
			game.startTimer = game.startTimer - 1
			if game.startTimer <= 0 then
				comet.spawnTimer = comet.spawnTimer - 1
				
				-- ship left/right movement and shooting
				if love.keyboard.isDown("left") then
					ship.x = ship.x - ship.speed * dt
				end
					
				if love.keyboard.isDown("right") then
					ship.x = ship.x + ship.speed * dt
				end
				-- stop ship if it hits screen bounds
				if ship.x <= 0 then
					ship.x = 0	
				end
				
				if ship.x >= 160 - 32 then
					ship.x = 160 - 32
				end

				-- shoot bullet *only* if bullet count is equal to 1 to prevent 
				if love.keyboard.isDown("x") or love.keyboard.isDown("c") then
					if not bullet.isShot then
						bullet.x = ship.x + 16
						bullet.y = ship.y
						bullet.isShot = true
					end
				end

				if bullet.isShot == true then
					bullet.y = bullet.y - bullet.speed * dt
					if bullet.y <= 0 then
						resetBullet()
					end
				end
				
				-- bullet to comet collision
				if bullet.y >= comet.y and bullet.y <= comet.y + comet.h and bullet.x >= comet.x and bullet.x <= comet.x + comet.w then	
					comet.isMoving = false
					comet.x = love.math.random(1, sx - 16)
					comet.y = -200
					comet.spawnTimer = 60
					comet.isDestroyed = true
					resetBullet()
				end	
				-- comet logic
				if comet.spawnTimer == 0 then
					comet.y = 0
					comet.isMoving = true
				end
				if comet.isMoving then
					comet.isDestroyed = false
					comet.y = comet.y + comet.speed * dt
					game.scoreTimer = 40
				end
						
				-- destroy comet if it hits the ground, and trigger game over
				if comet.y >= sy then
					game.gameOver = true
				
				end
			end
		end
		
	end
	
	if game.gameOver == true then
				game.menuTimer = game.menuTimer - 1
				game.state = "GAME OVER"
			end
			if game.state == "GAME OVER" then
				if game.menuTimer <= 0 then
					game.state = "TITLE"
				end
			end
end

function love.draw()
	
	love.graphics.setCanvas(canvas)

		if game.state == "TITLE" then
			if not game.altPalette then
				love.graphics.clear()
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.draw(game.title, 0, 0)
			elseif game.altPalette then
				love.graphics.clear()
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.draw(game.title_dmg, 0, 0)
			end
		end
		if game.state == "GAMEPLAY" then
		
			if not game.altPalette then
				love.graphics.clear()
				love.graphics.setColor(1, 1, 1, 1)
				--love.graphics.draw(game.bg, 0, 0)
				love.graphics.draw(ship.image, math.floor(ship.x), math.floor(ship.y))
				love.graphics.draw(bullet.image, math.floor(bullet.x), math.floor(bullet.y))
				love.graphics.draw(comet.image, math.floor(comet.x), math.floor(comet.y))
				if game.startTimer > 0 then
					love.graphics.print("GET READY", sx / 2 - 20, sy / 2 - 16)
				end
			elseif game.altPalette then
				love.graphics.clear()
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.draw(game.bg_dmg, 0, 0)
				love.graphics.draw(ship.image_dmg, math.floor(ship.x), math.floor(ship.y))
				love.graphics.draw(bullet.image_dmg, math.floor(bullet.x), math.floor(bullet.y))
				love.graphics.draw(comet.image_dmg, math.floor(comet.x), math.floor(comet.y))if game.gameOver == true then
							game.menuTimer = game.menuTimer - 1
							game.state = "GAME OVER"
						end
						if game.state == "GAME OVER" then
							if game.menuTimer <= 0 then
								game.state = "TITLE"
							end
						end
				if game.startTimer > 0 then
					love.graphics.setColor(32/255, 70/255, 49/255, 1)
					love.graphics.print("GET READY", sx / 2 - 20, sy / 2 - 16)
				end
			end
		end
		
		if game.state == "OPTIONS" then
		end	
		if game.state == "GAME OVER" then
			if not game.altPalette then
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.print("GAME OVER", sx / 2 - 20, sy / 2 - 16)
			elseif game.altPalette then
				love.graphics.clear()
				love.graphics.setBackgroundColor(215/255, 232/255, 148/255, 1)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.setColor(32/255, 70/255, 49/255, 1)
				love.graphics.print("GAME OVER", sx / 2 - 20, sy / 2 - 16)
			end
		end

	love.graphics.setCanvas()
	-- go back to drawing on screen
	
	-- DEBUG TEXT
	love.graphics.print("ship x = "..tostring(ship.x))
	love.graphics.print("bulletCount = "..tostring(bullet.count), 0, 16)
	love.graphics.print("isShot = "..tostring(bullet.isShot), 0, 32)
	love.graphics.print("isPaused = "..tostring(game.isPaused), 0, 48)
	love.graphics.print("comet x = "..tostring(comet.x), 0, 64)
	love.graphics.print("comet y = "..tostring(comet.y), 0, 80)
	love.graphics.print("cometSpawnTimer"..tostring(comet.spawnTimer), 0, 96)
	love.graphics.print("comet.isMoving = "..tostring(comet.isMoving), 0, 112)
	love.graphics.print("gameOver = "..tostring(game.gameOver), 0, 128);
	love.graphics.print("altPalette = "..tostring(game.altPalette), 0, 144)
	love.graphics.print("menuTimer = " ..tostring(game.menuTimer), 0, 160)
	print("startTimer  "..tostring(game.startTimer))
	-- render canvas on screen
	love.graphics.draw(canvas, 0, 0, 0, screenScale)	
	love.graphics.draw(canvas, 0, 0, 0, screenScale)
end
