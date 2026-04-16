# Brick Breaker (Playdate) - Skeleton

This is a minimal Playdate Lua project set up for VS Code with tasks to build and run the Playdate Simulator.

## Prerequisites

- Playdate SDK installed (macOS default path: `/Applications/PlaydateSDK`)
- VS Code

Recommended extensions (auto-recommended in `.vscode/extensions.json`):
- Lua Language Server (sumneko.lua)
- CodeLLDB (vadimcn.vscode-lldb) – optional if you want to attach a debugger to C/Native; not required to launch the Simulator.

## Environment setup

The VS Code tasks are resilient if `PLAYDATE_SDK_PATH` is not set. They will fall back to the default SDK path:

- `/Applications/PlaydateSDK/bin/pdc`
- `/Applications/PlaydateSDK/bin/Playdate Simulator`

If you installed the SDK elsewhere, set `PLAYDATE_SDK_PATH`:

```zsh
# add to ~/.zshrc
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"
```

Reload your shell or VS Code after editing `~/.zshrc`.

## Project structure

- `Source/` – Lua sources and `pdxinfo`
- `Build/BrickBreaker.pdx` – built bundle (output)
- `.vscode/tasks.json` – Build/Run/Clean tasks
- `.vscode/launch.json` – Launches Playdate Simulator via macOS `open`
- `.luarc.json` – Lua LS config so `import` is recognized

## Commands

- Build: VS Code Task “Playdate: Build”
- Run: VS Code Task “Playdate: Run Simulator” (builds first)
- Debug launch: VS Code Run & Debug “Playdate: Launch Simulator” (builds first)

## Notes

- The Lua entrypoint is `Source/main.lua`. The Lua LS is configured to treat `import` as `require` and knows about `playdate` globals.
- If the Simulator doesn’t open: verify the SDK path in the tasks and that the SDK is installed.
