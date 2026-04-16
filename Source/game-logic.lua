-- Game Logic Module for Circular Brick Breaker
-- This module exposes testable game logic functions

local GameLogic = {}

-- Normalize angle to 0-360 range
function GameLogic.normalizeAngle(a)
  while a < 0 do a = a + 360 end
  while a >= 360 do a = a - 360 end
  return a
end

-- Check if angle is between startAngle and endAngle (handles wraparound)
function GameLogic.isAngleBetween(angle, startAngle, endAngle)
  angle = GameLogic.normalizeAngle(angle)
  startAngle = GameLogic.normalizeAngle(startAngle)
  endAngle = GameLogic.normalizeAngle(endAngle)

  if startAngle <= endAngle then
    return angle >= startAngle and angle <= endAngle
  else
    return angle >= startAngle or angle <= endAngle
  end
end

-- Calculate distance from center point
function GameLogic.distanceFromPoint(x, y, centerX, centerY)
  local dx = x - centerX
  local dy = y - centerY
  return math.sqrt(dx * dx + dy * dy), dx, dy
end

-- Convert Cartesian coordinates to angle in degrees
function GameLogic.pointToAngle(x, y, centerX, centerY)
  local dx = x - centerX
  local dy = y - centerY
  local angle = math.atan(dy, dx) * 180 / math.pi
  if angle < 0 then angle = angle + 360 end
  return angle
end

-- Map crank position to paddle angle (crank down = 6 o'clock)
function GameLogic.crankToPaddleAngle(crankPos)
  return (crankPos + 270) % 360
end

-- Calculate paddle arc range given paddle center angle
function GameLogic.getPaddleRange(paddleAngle, paddleLength, paddleRadius)
  local paddleHalfArc = paddleLength / paddleRadius * 180 / math.pi
  local startAngle = GameLogic.normalizeAngle(paddleAngle - paddleHalfArc)
  local endAngle = GameLogic.normalizeAngle(paddleAngle + paddleHalfArc)
  return startAngle, endAngle
end

-- Check if ball hits paddle
function GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius)
  local startAngle, endAngle = GameLogic.getPaddleRange(paddleAngle, paddleLength, paddleRadius)
  return GameLogic.isAngleBetween(ballAngle, startAngle, endAngle)
end

-- Reflect velocity vector across a normal vector
function GameLogic.reflectVelocity(vx, vy, nx, ny)
  local dot = vx * nx + vy * ny
  local newVx = vx - 2 * dot * nx
  local newVy = vy - 2 * dot * ny
  return newVx, newVy
end

-- Calculate hit offset from paddle center (normalized to -180 to 180)
function GameLogic.calculateHitOffset(ballAngle, paddleAngle)
  local offset = ballAngle - paddleAngle
  if offset > 180 then offset = offset - 360 end
  if offset < -180 then offset = offset + 360 end
  return offset
end

-- Normalize velocity to a specific speed
function GameLogic.normalizeSpeed(vx, vy, targetSpeed)
  local currentSpeed = math.sqrt(vx * vx + vy * vy)
  if currentSpeed == 0 then return 0, 0 end
  return vx / currentSpeed * targetSpeed, vy / currentSpeed * targetSpeed
end

-- Calculate ball reflection off curved paddle
function GameLogic.calculatePaddleBounce(ballX, ballY, ballVx, ballVy, centerX, centerY, ballAngle, paddleAngle, ballSpeed)
  -- Normal vector pointing inward (perpendicular to curved surface)
  local normalAngleRad = math.rad(ballAngle)
  local nx = -math.cos(normalAngleRad)
  local ny = -math.sin(normalAngleRad)

  -- Reflect velocity
  local newVx, newVy = GameLogic.reflectVelocity(ballVx, ballVy, nx, ny)

  -- Add spin effect based on offset from paddle center
  local hitOffset = GameLogic.calculateHitOffset(ballAngle, paddleAngle)

  -- Apply tangential velocity (curved surface effect)
  local tangentAngleRad = normalAngleRad + math.pi / 2
  local spinForce = hitOffset * 0.05
  newVx = newVx + math.cos(tangentAngleRad) * spinForce
  newVy = newVy + math.sin(tangentAngleRad) * spinForce

  -- Normalize to target speed
  newVx, newVy = GameLogic.normalizeSpeed(newVx, newVy, ballSpeed)

  return newVx, newVy
end

-- Check if all bricks are destroyed
function GameLogic.checkWinCondition(bricks)
  for _, brick in ipairs(bricks) do
    if brick.active then
      return false
    end
  end
  return true
end

-- Count active bricks
function GameLogic.countActiveBricks(bricks)
  local count = 0
  for _, brick in ipairs(bricks) do
    if brick.active then
      count = count + 1
    end
  end
  return count
end

return GameLogic
