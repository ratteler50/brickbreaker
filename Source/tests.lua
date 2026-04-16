-- Unit tests for Circular Brick Breaker
-- Tests actual game logic from game-logic.lua module

local GameLogic = import "game-logic"
local gfx <const> = playdate.graphics

-- Simple test framework
local tests = {}
local testResults = {passed = 0, failed = 0}

local function test(name, fn)
  table.insert(tests, {name = name, fn = fn})
end

local function assertEquals(actual, expected, message)
  if actual ~= expected then
    error(message or ("Expected " .. tostring(expected) .. " but got " .. tostring(actual)))
  end
end

local function assertNear(actual, expected, tolerance, message)
  tolerance = tolerance or 0.001
  if math.abs(actual - expected) > tolerance then
    error(message or ("Expected " .. tostring(expected) .. " but got " .. tostring(actual) .. " (tolerance: " .. tolerance .. ")"))
  end
end

local function assertTrue(condition, message)
  if not condition then
    error(message or "Expected true but got false")
  end
end

local function assertFalse(condition, message)
  if condition then
    error(message or "Expected false but got true")
  end
end

-- Angle normalization tests
test("normalizeAngle: positive angle in range", function()
  assertEquals(GameLogic.normalizeAngle(90), 90)
end)

test("normalizeAngle: angle at 0", function()
  assertEquals(GameLogic.normalizeAngle(0), 0)
end)

test("normalizeAngle: angle at 360 wraps to 0", function()
  assertEquals(GameLogic.normalizeAngle(360), 0)
end)

test("normalizeAngle: negative angle wraps correctly", function()
  assertEquals(GameLogic.normalizeAngle(-90), 270)
end)

test("normalizeAngle: large positive angle wraps", function()
  assertEquals(GameLogic.normalizeAngle(450), 90)
end)

test("normalizeAngle: large negative angle wraps", function()
  assertEquals(GameLogic.normalizeAngle(-450), 270)
end)

-- Angle range tests
test("isAngleBetween: angle in simple range", function()
  assertTrue(GameLogic.isAngleBetween(45, 0, 90))
end)

test("isAngleBetween: angle at start of range", function()
  assertTrue(GameLogic.isAngleBetween(0, 0, 90))
end)

test("isAngleBetween: angle at end of range", function()
  assertTrue(GameLogic.isAngleBetween(90, 0, 90))
end)

test("isAngleBetween: angle outside simple range", function()
  assertFalse(GameLogic.isAngleBetween(100, 0, 90))
end)

test("isAngleBetween: angle in wrapped range", function()
  assertTrue(GameLogic.isAngleBetween(10, 350, 20))
end)

test("isAngleBetween: angle in wrapped range (near 0)", function()
  assertTrue(GameLogic.isAngleBetween(355, 350, 20))
end)

test("isAngleBetween: angle outside wrapped range", function()
  assertFalse(GameLogic.isAngleBetween(180, 350, 20))
end)

-- Paddle collision tests using actual game logic
test("checkPaddleCollision: ball hits paddle center", function()
  local paddleAngle = 90
  local paddleLength = 50
  local paddleRadius = 100
  local ballAngle = 90

  assertTrue(GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius))
end)

test("checkPaddleCollision: ball hits paddle left edge", function()
  local paddleAngle = 90
  local paddleLength = 50
  local paddleRadius = 100
  local paddleHalfArc = paddleLength / paddleRadius * 180 / math.pi
  local ballAngle = paddleAngle - paddleHalfArc

  assertTrue(GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius))
end)

test("checkPaddleCollision: ball hits paddle right edge", function()
  local paddleAngle = 90
  local paddleLength = 50
  local paddleRadius = 100
  local paddleHalfArc = paddleLength / paddleRadius * 180 / math.pi
  local ballAngle = paddleAngle + paddleHalfArc

  assertTrue(GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius))
end)

test("checkPaddleCollision: ball misses paddle", function()
  local paddleAngle = 90
  local paddleLength = 50
  local paddleRadius = 100
  local ballAngle = 180

  assertFalse(GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius))
end)

test("checkPaddleCollision: paddle at 0/360 boundary", function()
  local paddleAngle = 0
  local paddleLength = 50
  local paddleRadius = 100
  local ballAngle = 355

  assertTrue(GameLogic.checkPaddleCollision(ballAngle, paddleAngle, paddleLength, paddleRadius))
end)

-- Distance calculation tests using actual game logic
test("distanceFromPoint: ball at center", function()
  local centerX = 200
  local centerY = 120
  local ballX = centerX
  local ballY = centerY

  local dist = GameLogic.distanceFromPoint(ballX, ballY, centerX, centerY)

  assertEquals(dist, 0)
end)

test("distanceFromPoint: ball at known distance", function()
  local centerX = 200
  local centerY = 120
  local ballX = 200 + 30  -- 30 pixels to the right
  local ballY = 120 + 40  -- 40 pixels down

  local dist = GameLogic.distanceFromPoint(ballX, ballY, centerX, centerY)

  assertNear(dist, 50, 0.1)  -- sqrt(30^2 + 40^2) = 50
end)

-- Ball reflection tests using actual game logic
test("reflectVelocity: perpendicular bounce", function()
  -- Ball moving right, hits vertical wall, should bounce left
  local vx = 3
  local vy = 0
  local nx = -1  -- Normal pointing left
  local ny = 0

  local newVx, newVy = GameLogic.reflectVelocity(vx, vy, nx, ny)

  assertEquals(newVx, -3)
  assertEquals(newVy, 0)
end)

test("reflectVelocity: 45-degree bounce", function()
  -- Ball moving diagonally down-right, hits horizontal wall
  local vx = 3
  local vy = 3
  local nx = 0  -- Normal pointing up
  local ny = -1

  local newVx, newVy = GameLogic.reflectVelocity(vx, vy, nx, ny)

  assertEquals(newVx, 3)
  assertEquals(newVy, -3)
end)

-- Crank position mapping tests using actual game logic
test("crankToPaddleAngle: down position (0°) maps to 6:00 (270°)", function()
  assertEquals(GameLogic.crankToPaddleAngle(0), 270)
end)

test("crankToPaddleAngle: up position (180°) maps to 12:00 (90°)", function()
  assertEquals(GameLogic.crankToPaddleAngle(180), 90)
end)

test("crankToPaddleAngle: right position (90°) maps to 9:00 (0°)", function()
  assertEquals(GameLogic.crankToPaddleAngle(90), 0)
end)

test("crankToPaddleAngle: left position (270°) maps to 3:00 (180°)", function()
  assertEquals(GameLogic.crankToPaddleAngle(270), 180)
end)

-- Speed normalization tests
test("normalizeSpeed: maintains speed", function()
  local vx, vy = 3, 4  -- Speed = 5
  local targetSpeed = 10
  local newVx, newVy = GameLogic.normalizeSpeed(vx, vy, targetSpeed)

  local actualSpeed = math.sqrt(newVx * newVx + newVy * newVy)
  assertNear(actualSpeed, targetSpeed, 0.1)
end)

test("normalizeSpeed: zero velocity returns zero", function()
  local vx, vy = 0, 0
  local targetSpeed = 5
  local newVx, newVy = GameLogic.normalizeSpeed(vx, vy, targetSpeed)

  assertEquals(newVx, 0)
  assertEquals(newVy, 0)
end)

-- Hit offset calculation tests
test("calculateHitOffset: ball hits center", function()
  local ballAngle = 90
  local paddleAngle = 90
  local offset = GameLogic.calculateHitOffset(ballAngle, paddleAngle)

  assertEquals(offset, 0)
end)

test("calculateHitOffset: ball hits left side", function()
  local ballAngle = 80
  local paddleAngle = 90
  local offset = GameLogic.calculateHitOffset(ballAngle, paddleAngle)

  assertEquals(offset, -10)
end)

test("calculateHitOffset: handles wraparound", function()
  local ballAngle = 355
  local paddleAngle = 5
  local offset = GameLogic.calculateHitOffset(ballAngle, paddleAngle)

  assertEquals(offset, -10)
end)

-- Win condition tests
test("checkWinCondition: all bricks destroyed returns true", function()
  local bricks = {
    {active = false},
    {active = false},
    {active = false}
  }

  assertTrue(GameLogic.checkWinCondition(bricks))
end)

test("checkWinCondition: some bricks active returns false", function()
  local bricks = {
    {active = false},
    {active = true},
    {active = false}
  }

  assertFalse(GameLogic.checkWinCondition(bricks))
end)

test("countActiveBricks: counts correctly", function()
  local bricks = {
    {active = true},
    {active = false},
    {active = true},
    {active = true}
  }

  assertEquals(GameLogic.countActiveBricks(bricks), 3)
end)

-- Run all tests
local function runTests()
  print("\n=== Running Circular Brick Breaker Tests ===\n")

  for _, testCase in ipairs(tests) do
    local success, err = pcall(testCase.fn)
    if success then
      testResults.passed = testResults.passed + 1
      print("✓ " .. testCase.name)
    else
      testResults.failed = testResults.failed + 1
      print("✗ " .. testCase.name)
      print("  Error: " .. tostring(err))
    end
  end

  print("\n=== Test Results ===")
  print("Passed: " .. testResults.passed)
  print("Failed: " .. testResults.failed)
  print("Total:  " .. (testResults.passed + testResults.failed))

  if testResults.failed == 0 then
    print("\n🎉 All tests passed!")
  else
    print("\n❌ Some tests failed")
  end
end

-- Auto-run tests when file is loaded
runTests()
