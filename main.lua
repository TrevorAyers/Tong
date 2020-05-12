--Set scale of game window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--Set zoomed values for our push function to scale the window
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--Set speed (in Pixels / Second)
PADDLE_SPEED = 200

push = require 'push'
class = require 'class'

require 'Paddle'
require 'Ball'
require 'Autopaddle'

--[[
    Runs when game starts up, only once; used to initialize game
]]
function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Pong')
    love.graphics.setDefaultFilter('nearest','nearest')
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })  
    
    smallFont = love.graphics.newFont('font.TTF',8)
    scoreFont = love.graphics.newFont('font.TTF', 32)
    victoryFont = love.graphics.newFont('font.TTF', 24)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav','static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav','static'),
        ['edge_hit'] = love.audio.newSource('edge_hit.wav','static')
    }

    PADDLE_HEIGHT = 20
    SCORE_LIMIT = 10

    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPlayer = 0
    numPlayers = 0

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    if servingPlayer == 1 then
        ball.dx = -100
    else
        ball.dx = 100
    end

    gameState = 'playerSelect'
    fpsState = false

    tipbonus = 1.25

end

function love.resize(w, h)
    push:resize(w, h)
end

--dt is a function measuring the amount of time that has elapsed since the last frame.
--By scaling movement/update values by dt, we create consistent experiences independent of frame rate.
function love.update(dt)
    if gameState ~= 'playerSelect' then
        player1:update(dt)
        player2:update(dt)
        
        if numPlayers == 1 then
            if ball.dx > 0 then
                player2.state = 'responding'
            else 
                player2.state = 'waiting'
            end

            if ball.dy >= 0 then
                player2:changeTarget(ball.y + (player2.x - (ball.x + ball.width)) / ball.dx * ball.dy)
            else 
                player2:changeTarget(ball.y + ball.height + (player2.x - (ball.x + ball.width)) / ball.dx * ball.dy)
            end
            player2:setDirection()
        else
            if love.keyboard.isDown('up') then
                player2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                player2.dy = PADDLE_SPEED
            else
                player2.dy = 0
            end
        end

        --Check for input
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if gameState == 'play' then
            
            ball:update(dt)
            
            p1Collide = ball:collide(player1)
            p2Collide = ball:collide(player2)

            if p1Collide ~= 0 then
                --deflect ball to right
                if p1Collide == 2 then
                    ball.dy =  tipbonus * math.abs(ball.dy)
                elseif p1Collide == 3 then
                    ball.dy =  - tipbonus * math.abs(ball.dy)
                end
                ball.color = player1.color
                ball.dx = -ball.dx * 1.1
                ball.x = player1.x + player1.width
                sounds['paddle_hit']:play()
                
                if numPlayers == 1 then
                    player2.remainingDelay = player2.maxDelay
                end
            end

            if p2Collide ~= 0 then
                --deflect ball to right
                if p2Collide == 2 then
                    ball.dy =  tipbonus * math.abs(ball.dy)
                elseif p2Collide == 3 then
                    ball.dy =  - tipbonus * math.abs(ball.dy)
                end
                ball.color = player2.color
                ball.dx = -ball.dx * 1.1
                ball.x = player2.x - ball.width
                sounds['paddle_hit']:play()
                
                if numPlayers == 1 then
                    player2.remainingDelay = player2.maxDelay
                end
            end

            if ball.color == 'green' then
                ball = ball:wrap(ball)
            else
                if ball.y <= 0 then
                    --Deflect ball off ceiling
                    ball.dy = -ball.dy
                    ball.y = 0
                    sounds['edge_hit']:play()

                    if numPlayers == 1 then
                        player2.remainingDelay = player2.maxDelay
                    end
                end
                if ball.y >= VIRTUAL_HEIGHT - ball.height then
                    --Deflect ball off floor
                    ball.dy = -ball.dy
                    ball.y = VIRTUAL_HEIGHT - ball.height
                    sounds['edge_hit']:play()
                    
                    if numPlayers == 1 then
                        player2.remainingDelay = player2.maxDelay
                    end
                end
            end

            if ball.x <= 0 then
                player2.score = player2.score + 1
                if player1.score <= player2.score - 2 then
                    player1.color = 'green'
                else
                    player1.color = 'white'
                end
                ball:reset()

                sounds['point_scored']:play()

                if player2.score >= SCORE_LIMIT then
                    winningPlayer = 2
                    gameState = 'victory'
                else
                    ball.dx = -100
                    servingPlayer = 1
                    gameState = 'serve'
                end
            elseif ball.x >= VIRTUAL_WIDTH - ball.width then
                player1.score = player1.score + 1
                if player2.score <= player1.score - 2 then
                    player2.color = 'green'
                else
                    player2.color = 'white'
                end
                ball:reset()

                sounds['point_scored']:play()

                if player1.score >= SCORE_LIMIT then
                    winningPlayer = 1
                    gameState = 'victory'
                else 
                    ball.dx = 100
                    servingPlayer = 2
                    gameState = 'serve'
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif gameState == 'playerSelect' then
        if key == '1' then
            player1 = Paddle(5, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, 5, PADDLE_HEIGHT, 'white')
            player2 = Ai(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, 5, PADDLE_HEIGHT, 0.25, 'white')
            numPlayers = 1
            gameState = 'start'
        elseif key == '2' then
            player1 = Paddle(5, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, 5, PADDLE_HEIGHT, 'white')
            player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, 5, PADDLE_HEIGHT, 'white')
            numPlayers = 2
            gameState = 'start'
        end
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            player1.score = 0
            player2.score = 0
            gameState = 'playerSelect'
        elseif gameState == 'serve' then 
            gameState = 'play'
        end
    elseif key == 'tab' then
        if fpsState then
            fpsState = false
        else 
            fpsState = true
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    displayHeader()

    --Render Ball
    renderRectangle(ball)
    --Render paddles
    if gameState ~= 'playerSelect' then
        renderRectangle(player1)
        renderRectangle(player2)
        displayScore()
    end
    
    if fpsState then
        displayFPS()
    end

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function renderRectangle(square)
    if square.color == 'red' then
        love.graphics.setColor(1, 0, 0, 1)
    elseif square.color == 'green' then
        love.graphics.setColor(0, 1, 0, 1)
    elseif square.color == 'blue' then
        love.graphics.setColor(0, 0, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.rectangle('fill', square.x, square.y, square.width, square.height)
    love.graphics.setColor(1, 1, 1, 1)
end


function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2.score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayHeader()
    if gameState == 'playerSelect' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Tong', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press 1 or 2 to Select the Number of Players!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Tong', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player '.. tostring(servingPlayer).."'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player '.. tostring(winningPlayer).." has won", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to play again!', 0, 42, VIRTUAL_WIDTH, 'center')
    end
end