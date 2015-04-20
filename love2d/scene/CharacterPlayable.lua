------------------------
-- Playable Character --
------------------------

require "scene/Character"
require "scene/Triskelrang"

CharacterPlayable = Character:new()

function CharacterPlayable:new(o)
  o = o or Character:new()
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function() return "Player" end
  self.triskelrangs = {}
  return o
end

function CharacterPlayable:config()
  self.life = 100
  self.w, self.h = 25, 43
  
  -- A-B-A-C pattern -- 
  local walkMapping = {}
  walkMapping[0] = 0
  walkMapping[1] = 1
  walkMapping[2] = 0
  walkMapping[3] = 2
  self.walkStateNb = 3
  
  self:loadSprite("images/druid.png", 4, walkMapping) -- 4 directions --  
end

function CharacterPlayable:mapDirection(horizontal, vertical)  
  if      vertical == 1    then return 0 -- Down
  elseif  vertical == -1   then return 2 -- Top
  elseif  horizontal == 1  then return 3 -- Right
  elseif  horizontal == -1 then return 1 -- Left
  end
end

function CharacterPlayable:updateState(dt)
  self.walkTime = self.walkTime + dt
  
  if self.walkTime > 0.25 then
    self.walkTime = self.walkTime - 0.25
    self:nextWalkState()
  end
end

function Character:onMove(x1, y1, x2, y2) 
  for key, triskelrang in ipairs(self.triskelrangs) do
    local newCenter = {
      x = triskelrang.circleCenter.x + (x2 - x1), 
      y = triskelrang.circleCenter.y + (y2 - y1)
    }
    local newRadius = math.sqrt(math.pow(triskelrang.x - newCenter.x, 2) + math.pow(triskelrang.y - newCenter.y, 2))
    local angle = math.atan2((triskelrang.y - newCenter.y), (triskelrang.x - newCenter.x))
    
    triskelrang.circleSpeed = triskelrang.circleSpeed * (triskelrang.circleRadius / newRadius) 
    triskelrang.circleRadius = newRadius
    triskelrang.circlePosition = angle
    triskelrang.circleCenter = newCenter
  end
end


function CharacterPlayable:throw(hand, mouse)
  local triskelrang = Triskelrang:new()
  
  triskelrang.hand = hand
  triskelrang.x = self.x + (self.w/2) -- + (self.horizontal * self.w)
  triskelrang.y = self.y + (self.h/2) -- + (self.vertical * self.h)
  
  -- Custom physic --
  
  -- triskelrang.speedx = triskelrang.speedx * self.horizontal
  -- triskelrang.speedy = triskelrang.speedy * self.vertical
  
  local distance, direction = 100, {x = 0, y = 0}
  local start = 0
  
  if mouse == nil then
    direction.x = distance * self.horizontal
    direction.y = distance * self.vertical
    local angle = math.atan2(direction.x, direction.y)
    start = angle - math.pi
  else 
    local angle = math.atan2((mouse.y - self.y), (mouse.x - self.x))
    direction.x = distance * math.cos(angle)
    direction.y = distance * math.sin(angle)
    start = angle - math.pi
  end
  
  triskelrang.circlePosition = start
  triskelrang.circleCenter = { x = direction.x + self.x + triskelrang.radius, y = direction.y + self.y + triskelrang.radius }
  triskelrang.circleSpeed = math.pi/100
  
  table.insert(self.triskelrangs,triskelrang)
  
  -- Box2D Physic --
  
  triskelrang:loadPhysic(self.world)
  --local forceCoef, force = 100, {x = 0, y = 0}
  
  --if mouse == nil then
  --  force.x = forceCoef * self.horizontal
  --  force.y = forceCoef * self.vertical
  --else 
  --  local angle = math.atan2((mouse.y - self.y), (mouse.x - self.x))
  --  force.x = forceCoef * math.cos(angle)
  --  force.y = forceCoef * math.sin(angle)
  --end
  
  --triskelrang.body:applyLinearImpulse(force.x, force.y)
  
  return triskelrang
end
