Ball = Class{}

-- Ball Constructor
function Ball:init(x,y,width,height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Delta Velocity of Y and X axis 
    self.dy = 0
    self.dx = 0
end

-- Retrun true or false if rectangles overlap
function Ball:collides(paddle)
    -- Check if edges are touch on either side horizontally
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- Check if bottom or top edge touch
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end

-- Reset ball in initial position
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2-2
    self.y = VIRTUAL_HEIGHT / 2-2
    -- No mouvement
    self.dx = 0
    self.dy = 0
end

-- Move ball each dt along y and x axis
function Ball:update(dt) 
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Draw the ball using filled rectangle paramtered function 
function Ball:render()
    love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
end