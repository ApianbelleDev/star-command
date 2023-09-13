local gameWidth, gameHeight
local screenScale

function love.load()
	gameWidth = 160
	gameHeight = 144

	-- setup tables for objects
	game   = {}
	UI     = {}
	ship   = {}
	bullet = {}
	comet  = {}

	game.isPaused   = false
	game.gameOver   = false
	game.text       = "nothing" -- debug text
	game.state      = "TITLE"
	game.score      = 0
	game.highScore  = 0
	game.menuTimer  = 180
	game.startTimer = 180

	UI.font      = love.graphics.setNewFont("res/fonts/monobit.ttf", 16)
	UI.bg        = love.graphics.newImage("res/Graphics/default/bg.png")
	UI.title     = love.graphics.newImage("res/Graphics/default/UI/Title/title.png")
	UI.startText = love.graphics.newImage("res/Graphics/default/UI/Title/press_start.png")
	UI.scoreText = love.graphics.newImage("res/Graphics/default/UI/Title/score.png")
	
	
	ship.x     = 80 - 160
	ship.y     = 144 - 16
	ship.w     = 32
	ship.h     = 16
	ship.speed = 60

	ship.image = love.graphics.newImage("res/Graphics/default/ship.png")

	-- store bullet off screen
	bullet.x      = -100
	bullet.y      = -100
	bullet.w      = 4
	bullet.h      = bullet.w
	bullet.speed  = 70
	bullet.isShot = false

	bullet.image  = love.graphics.newImage("res/Graphics/default/bullet.png")

	
	comet.x = love.math.random(1, gameWidth - 16)
	comet.y = -200
	comet.gameWidth = 0
	comet.gameHeight = 0
	comet.w = 16
	comet.h = comet.w
	comet.speed = 30
	comet.spawnTimer = 60 
	comet.isMoving = false

	comet.image    = love.graphics.newImage("res/Graphics/default/comet.png")

	-- override default filter so game when scaled up doesn't look blurry
	love.graphics.setDefaultFilter("nearest", nil, 0)

	screenScale = 4
	-- create canvas to draw to that will be scaled later
	canvas = love.graphics.newCanvas(gameWidth, gameHeight)

	-- override default screen res
	love.window.setMode(gameWidth * 4, gameHeight * 4)
end

function reset()
	comet.isMoving = false
	comet.x = love.math.random(0, gameWidth - comet.w)
	comet.y = -200
	comet.spawnTimer = 60
	bullet.x = -100
	bullet.y = -100
	ship.x = 80 - 16
	ship.y = 144-16
	game.menuTimer = 180
	game.startTimer = 180
	game.score = 0	
end

function calculateHighScore()
	if game.score > game.highScore then
		game.highScore = game.score
		return game.highScore
	end
end

function love.keypressed(key)
	if game.state == "TITLE" then
		reset()
		if key == "return" then
			game.state = "GAMEPLAY"
		end
	elseif game.state == "GAMEPLAY" then
		if key == "return" then
			game.isPaused = not game.isPaused
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
			-- decrement timers when the round begins
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
					comet.x = love.math.random(1, gameWidth - 16)
					comet.y = -200
					comet.spawnTimer = 60
					game.score = game. score + 100
					resetBullet()
				end	
				-- comet logic
				if comet.spawnTimer == 0 then
					comet.y = 0
					comet.isMoving = true
				end
				if comet.isMoving then
					comet.y = comet.y + comet.speed * dt
					game.scoreTimer = 40
				end
						
				-- destroy comet if it hits the ground, and trigger game over
				if comet.y >= gameHeight then
					game.gameOver = true
					calculateHighScore()
				
				end
			end
		end
		
	end
	
	if game.gameOver then
		game.menuTimer = game.menuTimer - 1
		game.state = "GAME OVER"
	end

	-- game over logic
	if game.state == "GAME OVER" then
		if game.menuTimer <= 0 or love.keyboard.isDown("return") then
			game.gameOver = false
			game.state = "TITLE"
		end
	end
end

function love.draw()
	
	love.graphics.setCanvas(canvas)

		if game.state == "TITLE" then
			love.graphics.clear()
			love.graphics.draw(UI.bg, 0, 0)
			-- love.graphics.print(game.highScore, gameWidth / 2, 0)
			love.graphics.draw(UI.title, 16, 16)
			love.graphics.draw(UI.startText, 50, 100)
		elseif game.state == "GAMEPLAY" then
			love.graphics.clear()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(UI.bg, 0, 0)
			love.graphics.draw(ship.image, math.floor(ship.x), math.floor(ship.y))
			love.graphics.draw(bullet.image, math.floor(bullet.x), math.floor(bullet.y))
			love.graphics.draw(comet.image, math.floor(comet.x), math.floor(comet.y))
			love.graphics.draw(UI.scoreText, gameWidth / 2 - 20, 0)
			love.graphics.print(game.score, gameWidth / 2 + 30 - 20, -1)
			if game.startTimer > 0 then
				love.graphics.print("GET READY", gameWidth / 2 - 20, gameHeight / 2 - 16)
			end
			if game.isPaused then
				love.graphics.print("PAUSE", gameWidth / 2 - 10, gameWidth / 2 - 16)
			end
		elseif game.state == "GAME OVER" then
			love.graphics.print("GAME OVER", gameWidth / 2 - 20, gameHeight / 2 - 16)
		end

	love.graphics.setCanvas()
	-- render canvas on screen
	love.graphics.draw(canvas, 0, 0, 0, screenScale)	
end
