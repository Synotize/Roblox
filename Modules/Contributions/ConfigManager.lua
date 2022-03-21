--[[
  I wrote this mainly because I wanted an easy way to save script settings
  across my projects, so I wrote this up and this is where it's at.
  
  Credits:
      Synotize#0000 (no discord yet)
  Updates:
      3/21/2022
          + Placeholder Phase (Haven't even tested the code yet)
          + Save, Load Features coming soon (hopefully)
]]
local Config = {
    Folder = "Settings",
    Name = "Test",
    Extension = "json",
    Content = "{}"
}

function Config:NewConfig(Settings)
    local NewConfig = setmetatable({}, self)
    NewConfig.Folder = Settings.Folder or self.Folder
    NewConfig.Name = Settings.Name or self.Name
    NewConfig.Extension = Settings.Extension or self.Extension
    NewConfig.Content = Settings.Content or self.Content

    -- Exploit check
    if #{readfile, writefile, isfile, isfolder, makefolder} ~= 5 then
        while true do end
    end

    -- Folder Check
    if (not isfolder(NewConfig.Folder)) then
        makefolder(NewConfig.Folder)
    end

    -- File Check
    if (not isfile(NewConfig.Folder .. '\\' .. NewConfig.Name .. '.' .. NewConfig.Extension)) then
        print('no exists')
    end

    self.__index = self

    return NewConfig
end

local Settings = Config:NewConfig({
    Folder = "Settings2",
    Name = "Test",
    Extension = "json",
    Content = "{}"
})