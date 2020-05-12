Ball = class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = 'white'

    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:collide(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return 0
    end

    if self.y > box.y + box.height or self.y + self.height < box.y then
        return 0
    end

    if self.y > box.y + box.height / 4 and (self.x <= box.x + box.width or self.x + self.width >= box.x) then 
        return 2
    elseif self.y < box.y + box.height / 4 and (self.x <= box.x + box.width or self.x + self.width >= box.x) then 
        return 3
    end

    return 1
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50) * 1.5
    self.color = 'white'
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:wrap(ball)
    if ball.y <= 0 and ball.y + ball.height >= 0 then
        self.width = ball.width
        self.x = ball.x
        self.height = ball.height
        self.y = VIRTUAL_HEIGHT - self.height
        self.dx = ball.dx
        self.dy = ball.dy
        return self
    elseif ball.y <= VIRTUAL_HEIGHT and ball.y + ball.height >= VIRTUAL_HEIGHT then
        self.width = ball.width
        self.height = ball.height
        self.y = 0
        self.x = ball.x
        self.dx = ball.dx
        self.dy = ball.dy
        return self
    else
        return ball
    end
end