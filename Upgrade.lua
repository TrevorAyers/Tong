Upgrade = class{}

function Upgrade:init(spawnTimer)
    self.spawnTime = spawnTimer
    self.state = 'inactive'
    self.timer = math.random(self.spawnTime, self.spawnTime + 5)
    self.displayTime = 1
    self.hideTime = 1

    self.x = math.random(VIRTUAL_WIDTH / 4, 3 * VIRTUAL_WIDTH / 4)
    self.y = math.random(VIRTUAL_HEIGHT / 4, 3 * VIRTUAL_HEIGHT / 4)
    self.width = 10
    self.height = 10

    self.power = math.random(3)
    if self.power == 1 then
        self.mainColor = 'blue'
    elseif self.power == 2 then
        self.mainColor = 'green'
    elseif self.power == 3 then
        self.mainColor = 'red'
    end

    self.secColor = self.mainColor
end

function Upgrade:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
    else
        if self.state ~= 'display' then
            self.state = 'display'
            self.timer = self.displayTime
        else
            self.state = 'hide'
            self.timer = self.hideTime
        end
    end
end

function Upgrade:reset()
    self.state = 'inactive'
    self.timer = math.random(self.spawnTime, self.spawnTime + 5)
    
    self.x = math.random(VIRTUAL_WIDTH / 4, 3 * VIRTUAL_WIDTH / 4)
    self.y = math.random(VIRTUAL_HEIGHT / 4, 3 * VIRTUAL_HEIGHT / 4)

    self.power = math.random(4)
    if self.power == 1 then
        self.mainColor = 'blue'
    elseif self.power == 2 then
        self.mainColor = 'green'
    elseif self.power == 3 then
        self.mainColor = 'red'
    else
        self.mainColor = 'white'
    end
end
