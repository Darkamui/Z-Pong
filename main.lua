-- Basic Lua/Love2D requires
push = require 'push'
Class = require 'class'

-- require of created classes
require 'Paddle'
require 'Ball'

-- Physical resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Simulated resolution
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Paddle mouvement speed along Y axis
PADDLE_SPEED = 200

-- Run once 
function love.load()

    -- Default appearance filter 
    love.graphics.setDefaultFilter('nearest','nearest')
    -- Window title
    love.window.setTitle('PongPong')

    -- Generate a new randomseed based on os time to regenerate random values each execution
    math.randomseed(os.time())

    -- Font implementation
    smallFont = love.graphics.newFont('font.ttf',8)
    mediumFont = love.graphics.newFont('font.ttf',16)
    largeFont = love.graphics.newFont('font.ttf',32)
    love.graphics.setFont(smallFont)

    -- Sounds array
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.mp3','static'),
        ['score'] = love.audio.newSource('sounds/score.mp3','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.mp3','static'),
        ['bg'] = love.audio.newSource('sounds/bg.mp3','static')
    }

    -- Set screen based on physical and virtual resolution
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    -- Set players initial paddle location
    player1 = Paddle(10,30,5,40)
    player2 = Paddle(VIRTUAL_WIDTH - 10,VIRTUAL_HEIGHT - 30,5,40)

    -- Set ball initial location
    ball = Ball(VIRTUAL_WIDTH / 2-2,VIRTUAL_HEIGHT / 2-2,4,4)

    -- Player information
    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    winningPlayer = 1

    -- Set state to start and play background sound
    gameState='start'

    sounds['bg']:play()

end

-- Allows resize of the windows while keeping virtual dimensions
function love.resize(w,h)
    push:resize(w,h)
end

-- Runs every dt (delta time/delta frame)
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then 
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gameState == 'play' then 
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x -4

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            
            sounds['paddle_hit']:play()
            
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            
            sounds['wall_hit']:play()
        end

        -- Simple AI implementation
        if ball.x < 30 then
            player1.y = ball.y
            player1.dy = -PADDLE_SPEED
        else 
            player1.dy = 0
        end

        if ball.x < 0 then 
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

    end

    -- if love.keyboard.isDown('w') then
    --     player1.dy = -PADDLE_SPEED
    -- elseif love.keyboard.isDown('s') then 
    --     player1.dy = PADDLE_SPEED
    -- else
    --     player1.dy = 0
    -- end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then 
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end
    
    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()

    elseif key == 'space' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:start()

    love.graphics.clear(40/255,45/255,52/255,255/255)

    if gameState == 'start' then 
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to PongPong!',0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Space to Begin!',0,20,VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then 
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player' .. tostring(servingPlayer) .. "'s serve!",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Space to Serve!',0,20,VIRTUAL_WIDTH,'center')
   end

   displayScore()

   player1:render()
   player2:render()
   ball:render()

   displayFPS()

   push:finish()
end

function displayScore()
    love.graphics.setFont(largeFont)
    love.graphics.print(tostring(player1Score),VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score),VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end



function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255/255,0,255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),10,10)
    love.graphics.print('Ball axis: ' .. tostring(ball.dx),10,0)
    love.graphics.setColor(255,255,255,255)
end

