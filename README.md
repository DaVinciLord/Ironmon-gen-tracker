# Ironmon-Tracker

This is an in-development fork of https://github.com/besteon/Ironmon-Tracker that aims to adapt the tracker to work for Gen 1 games.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/besteon/Ironmon-Tracker).

This is a WIP; bugs and instability can be expected.

## Supported Pokémon games / languages

- Red US/EU version
- Blue US/EU version
- Yellow US/EU version
- **Yellow French version — experimental**

The French Yellow support is intentionally being stabilized before larger feature work. See [`docs/yellow-fr.md`](docs/yellow-fr.md) for the current compatibility status, BizHawk validation procedure, and roadmap.

The long-term goal for this fork is to progressively catch up with useful features available in the GBA/DS IronMON trackers once Gen 1 memory compatibility is reliable.

## Development

There are a couple of VS Code extensions which we recommend, which should automatically be recommended to you in your VS Code:

- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig): To help with consistent formatting.
- [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua): Provides intellisense and linting for Lua.

Lua Versions:
- Bizhawk 2.8 uses Lua 5.1, this is the version currently set in our `.vscode/settings.json` file for linting.
- Bizhawk 2.9 and mGBA use Lua 5.4.
- Since we intend to still support Bizhawk 2.8 the code must be compatible with both Lua 5.1 and 5.4.

Emu-specific Lua documentation:
- [Bizhawk Lua Functions](https://tasvideos.org/Bizhawk/LuaFunctions)
- [mGBA Scripting API](https://mgba.io/docs/scripting.html)
