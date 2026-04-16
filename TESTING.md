# Testing Guide for Circular Brick Breaker

## Unit Tests

The game includes comprehensive unit tests in [`Source/tests.lua`](Source/tests.lua).

### Test Coverage

The test suite includes:

- **Angle Normalization Tests**: Ensures angles wrap correctly (0-360°)
- **Angle Range Tests**: Validates angle-between calculations, including wraparound at 0°/360°
- **Paddle Collision Detection**: Tests ball-paddle collision at center, edges, and boundaries
- **Distance Calculations**: Verifies distance-from-center calculations
- **Ball Reflection Physics**: Tests bounce mechanics with various angles
- **Crank Position Mapping**: Validates that crank positions map correctly to paddle positions

### Running Tests

#### Option 1: Using the Test Runner Script

```bash
./run-tests.sh
```

This will build a test version and output results to the console.

#### Option 2: Manual Testing

1. Temporarily modify `Source/main.lua` to import the tests:
   ```lua
   import "tests"
   ```

2. Build and run in the Playdate Simulator:
   ```bash
   pdc Source Build/BrickBreaker.pdx
   ```

3. Check the console output in the Simulator for test results

4. Remove the `import "tests"` line when done

### Test Output

Successful test run:
```
=== Running Circular Brick Breaker Tests ===

✓ normalizeAngle: positive angle in range
✓ normalizeAngle: angle at 0
✓ normalizeAngle: angle at 360 wraps to 0
✓ normalizeAngle: negative angle wraps correctly
...

=== Test Results ===
Passed: 20
Failed: 0
Total:  20

🎉 All tests passed!
```

### Adding New Tests

Use the simple test framework in `tests.lua`:

```lua
test("your test name", function()
  assertEquals(actual, expected)
  assertTrue(condition)
  assertFalse(condition)
  assertNear(actual, expected, tolerance)
end)
```

## Manual Testing Checklist

- [ ] Crank control moves paddle smoothly around circle
- [ ] Ball bounces correctly off paddle at different angles
- [ ] Ball bounces off paddle edges with spin
- [ ] Bricks are destroyed when hit
- [ ] Lives decrease when ball is missed
- [ ] Game over screen appears when lives reach 0
- [ ] Win screen appears when all bricks are destroyed
- [ ] Press A to start/restart game works correctly
