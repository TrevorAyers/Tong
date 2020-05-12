Ai = class{}

function Ai:init(x, y, width, height, delay, color)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.score = 0
    self.maxDelay = delay
    self.color = color

    self.dy = 0
    self.state = 'waiting'
    self.target = 0
    self.remainingDelay = self.maxDelay
end

function Ai:update(dt)
    if self.remainingDelay > 0 then
        self.remainingDelay = self.remainingDelay - dt
    else
        self.y = self.y + self.dy * dt
    end
end

function Ai:changeTarget(y)
    if self.state == 'responding' then
        if y >= 0 and y <= VIRTUAL_HEIGHT then
            self.target = y
        elseif y < 0 then
            self.target = 0
        elseif y > VIRTUAL_HEIGHT then
            self.target = VIRTUAL_HEIGHT 
        end
    else
        self.target = VIRTUAL_HEIGHT / 2 - self.height / 2
    end
end

function Ai:setDirection()
    if self.target >= self.y and self.target <= self.y + self.height then
        self.dy = 0
    elseif self.target < self.y then
        self.dy = - 3 * PADDLE_SPEED / 4
    elseif self.target > self.y + self.height then
        self.dy = 3 * PADDLE_SPEED / 4
    end
end
