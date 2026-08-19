dofile("ironmon_tracker/FileManager.lua")

local existing = {
	["/seeds/YellowKaizo002.gbc"] = true,
	["/seeds/RedKaizo003.gb"] = true,
}
FileManager.fileExists = function(path) return existing[path] == true end

assert(FileManager.isRomExtension("gb") and FileManager.isRomExtension("GBC"))
assert(not FileManager.isRomExtension("gba"))
local yellowPath, yellowExtension = FileManager.findRomPath("/seeds/YellowKaizo002")
assert(yellowPath == "/seeds/YellowKaizo002.gbc" and yellowExtension == ".gbc")
local redPath, redExtension = FileManager.findRomPath("/seeds/RedKaizo003")
assert(redPath == "/seeds/RedKaizo003.gb" and redExtension == ".gb")
assert(FileManager.findRomPath("/seeds/Missing004") == nil)

print("Gen 1 quickload smoke tests passed")
