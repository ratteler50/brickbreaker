import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/sprites"
local gfx <const> = playdate.graphics
local GameLogic = import "game-logic"

-- Game constants
local SCREEN_WIDTH <const> = 400
local SCREEN_HEIGHT <const> = 240
local CENTER_X <const> = SCREEN_WIDTH / 2
local CENTER_Y <const> = SCREEN_HEIGHT / 2
local ARENA_RADIUS <const> = 110
local PADDLE_RADIUS <const> = ARENA_RADIUS - 10
local PADDLE_LENGTH <const> = 50
local BALL_RADIUS <const> = 4
local BALL_SPEED <const> = 3
local BRICK_ROWS <const> = 4
local BRICKS_PER_ROW <const> = 12

-- Art assets (images created procedurally)
local brickImage = nil
local ballImage = nil
local paddleSegmentImage = nil

-- Game state
local gameState = "start" -- "start", "playing", "win", "lose"
local paddleAngle = 0
local ball = {x = CENTER_X, y = CENTER_Y, vx = 0, vy = 0}
local bricks = {}
local score = 0
local lives = 3

-- Create art assets procedurally
local function createArtAssets()
  -- Create brick image (30x12)
  brickImage = gfx.image.new(30, 12)
  gfx.pushContext(brickImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 30, 12)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(2, 2, 26, 8)
    gfx.setColor(gfx.kColorBlack)
    -- Brick pattern
    for i = 5, 25, 5 do
      gfx.drawLine(i, 3, i, 8)
    end
    gfx.drawLine(3, 5, 27, 5)
  gfx.popContext()

  -- Create ball image (10x10)
  ballImage = gfx.image.new(10, 10)
  gfx.pushContext(ballImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(5, 5, 4)
    gfx.setColor(gfx.kColorWhite)
    -- Highlight
    gfx.fillCircleAtPoint(3, 3, 1)
  gfx.popContext()

  -- Create paddle segment image (24x10)
  paddleSegmentImage = gfx.image.new(24, 10)
  gfx.pushContext(paddleSegmentImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(0, 0, 24, 10, 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(2, 2, 20, 6, 1)
    gfx.setColor(gfx.kColorBlack)
    -- Segment lines
    gfx.drawLine(6, 3, 6, 6)
    gfx.drawLine(12, 3, 12, 6)
    gfx.drawLine(18, 3, 18, 6)
  gfx.popContext()
end

-- Initialize bricks in circular pattern
local function initBricks()
  bricks = {}
  for row = 1, BRICK_ROWS do
    local radius = ARENA_RADIUS - 30 - (row - 1) * 12
    for i = 1, BRICKS_PER_ROW do
      local angle = (i - 1) * (360 / BRICKS_PER_ROW)
      table.insert(bricks, {
        angle = angle,
        radius = radius,
        width = 28,
        height = 10,
        active = true
      })
    end
  end
end

-- Draw circular arena
local function drawArena()
  gfx.drawCircleAtPoint(CENTER_X, CENTER_Y, ARENA_RADIUS)
end

-- Draw paddle using image asset
local function drawPaddle()
  -- Draw multiple paddle segments around the arc
  local numSegments = 3
  local segmentSpacing = PADDLE_LENGTH / numSegments / PADDLE_RADIUS * 180 / math.pi

  for i = 0, numSegments - 1 do
    local segmentAngle = paddleAngle - PADDLE_LENGTH / PADDLE_RADIUS * 90 / math.pi + i * segmentSpacing
    local angleRad = math.rad(segmentAngle)
    local x = CENTER_X + math.cos(angleRad) * PADDLE_RADIUS
    local y = CENTER_Y + math.sin(angleRad) * PADDLE_RADIUS

    -- Draw rotated paddle segment
    paddleSegmentImage:drawRotated(x, y, segmentAngle + 90)
  end
end

-- Draw ball using image asset
local function drawBall()
  ballImage:draw(ball.x - 5, ball.y - 5)
end

-- Draw bricks using image assets
local function drawBricks()
  for _, brick in ipairs(bricks) do
    if brick.active then
      local angleRad = math.rad(brick.angle)
      local x = CENTER_X + math.cos(angleRad) * brick.radius
      local y = CENTER_Y + math.sin(angleRad) * brick.radius

      -- Draw rotated brick image
      brickImage:drawRotated(x, y, brick.angle + 90)
    end
  end
end

-- Start new game
local function startGame()
  initBricks()
  ball.x = CENTER_X
  ball.y = CENTER_Y
  local angle = math.random() * 2 * math.pi
  ball.vx = math.cos(angle) * BALL_SPEED
  ball.vy = math.sin(angle) * BALL_SPEED
  score = 0
  lives = 3
  gameState = "playing"
end

-- Update ball physics
local function updateBall()
  ball.x = ball.x + ball.vx
  ball.y = ball.y + ball.vy

  -- Check collision with circular boundary
  local distFromCenter, dx, dy = GameLogic.distanceFromPoint(ball.x, ball.y, CENTER_X, CENTER_Y)

  -- Collision with paddle (inner edge of arena)
  if distFromCenter >= PADDLE_RADIUS - BALL_RADIUS then
    -- Check if paddle is there
    local ballAngle = GameLogic.pointToAngle(ball.x, ball.y, CENTER_X, CENTER_Y)
    local hitPaddle = GameLogic.checkPaddleCollision(ballAngle, paddleAngle, PADDLE_LENGTH, PADDLE_RADIUS)

    if hitPaddle then
      -- Calculate reflection and spin based on curved paddle surface
      ball.vx, ball.vy = GameLogic.calculatePaddleBounce(
        ball.x, ball.y, ball.vx, ball.vy, 
        CENTER_X, CENTER_Y, ballAngle, paddleAngle, BALL_SPEED
      )

      -- Push ball back slightly to prevent sticking
      ball.x = CENTER_X + (dx / distFromCenter) * (PADDLE_RADIUS - BALL_RADIUS - 1)
      ball.y = CENTER_Y + (dy / distFromCenter) * (PADDLE_RADIUS - BALL_RADIUS - 1)
    else
      -- Missed paddle - lose life
      lives = lives - 1
      if lives <= 0 then
        gameState = "lose"
      else
        -- Reset ball
        ball.x = CENTER_X
        ball.y = CENTER_Y
        local angle = math.random() * 2 * math.pi
        ball.vx = math.cos(angle) * BALL_SPEED
        ball.vy = math.sin(angle) * BALL_SPEED
      end
    end
  end

  -- Check collision with bricks
  for _, brick in ipairs(bricks) do
    if brick.active then
      local brickX = CENTER_X + math.cos(math.rad(brick.angle)) * brick.radius
      local brickY = CENTER_Y + math.sin(math.rad(brick.angle)) * brick.radius

      local brickDx = ball.x - brickX
      local brickDy = ball.y - brickY
      local dist = math.sqrt(brickDx * brickDx + brickDy * brickDy)

      if dist < BALL_RADIUS + brick.height / 2 then
        brick.active = false
        score = score + 10

        -- Simple reflection
        ball.vx = -ball.vx
        ball.vy = -ball.vy
      end
    end
  end

  -- Check win condition
  if GameLogic.checkWinCondition(bricks) then
    gameState = "win"
  end
end

function playdate.update()
  gfx.clear()

  -- Update paddle angle from crank (1:1 mapping with offset)
  -- Crank down (0°) = paddle at 6:00 (270°)
  local crankPos = playdate.getCrankPosition()
  if crankPos ~= nil then
    paddleAngle = GameLogic.crankToPaddleAngle(crankPos)
  end

  if gameState == "start" then
    drawArena()
    gfx.drawTextAligned("*CIRCULAR BRICK BREAKER*", CENTER_X, 20, kTextAlignment.center)
    gfx.drawTextAligned("Press A to Start", CENTER_X, CENTER_Y, kTextAlignment.center)
    gfx.drawTextAligned("Use Crank to Move Paddle", CENTER_X, CENTER_Y + 20, kTextAlignment.center)

    if playdate.buttonJustPressed(playdate.kButtonA) then
      startGame()
    end

  elseif gameState == "playing" then
    updateBall()

    drawArena()
    drawBricks()
    drawPaddle()
    drawBall()

    gfx.drawText("Score: " .. score, 10, 10)
    gfx.drawText("Lives: " .. lives, 10, 25)

  elseif gameState == "win" then
    drawArena()
    gfx.drawTextAligned("*YOU WIN!*", CENTER_X, CENTER_Y - 10, kTextAlignment.center)
    gfx.drawTextAligned("Score: " .. score, CENTER_X, CENTER_Y + 10, kTextAlignment.center)
    gfx.drawTextAligned("Press A to Restart", CENTER_X, CENTER_Y + 30, kTextAlignment.center)

    if playdate.buttonJustPressed(playdate.kButtonA) then
      gameState = "start"
    end

  elseif gameState == "lose" then
    drawArena()
    gfx.drawTextAligned("*GAME OVER*", CENTER_X, CENTER_Y - 10, kTextAlignment.center)
    gfx.drawTextAligned("Score: " .. score, CENTER_X, CENTER_Y + 10, kTextAlignment.center)
    gfx.drawTextAligned("Press A to Restart", CENTER_X, CENTER_Y + 30, kTextAlignment.center)

    if playdate.buttonJustPressed(playdate.kButtonA) then
      gameState = "start"
    end
  end

  playdate.timer.updateTimers()
end

-- Initialize
createArtAssets()
initBricks()