--[[
  I wrote this mainly because I wanted an easy way to save script settings
  across my projects, so I wrote this up and this is where it's at.
  
  Credits:
      Synotize#0000 (no discord yet)
  Updates:
      3/21/2022
          + Placeholder Phase (Haven't even tested the code yet)
          + Save, Load Features coming soon (hopefully)
      3/26/2022
          + Added Get(<void>) function, return list of configs in ascending order.
          + Added DeepCopy(<table>) recursion function, will be used to convert types.
]]

local Config = {
    Folder = "Settings",
    Name = "Test",
    Extension = "json",
    Content = "{}"
}

local function Date()
    return os.date("%c")
end

local function DeepCopy(Table : table)
    local Copy
    for k,v in next, Table do
        if typeof(v) == 'table' then
            v = DeepCopy(v)
        end
        Copy[k] = v
    end
    return Copy
end

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
    if not isfolder(NewConfig.Folder) then
        makefolder(NewConfig.Folder)
    end

    -- File Check
    if not isfile(NewConfig.Folder .. '\\' .. NewConfig.Name .. '.' .. NewConfig.Extension) then
        writefile(NewConfig.Folder .. '\\' .. NewConfig.Name .. '.' .. NewConfig.Extension, NewConfig.Content)
    end

    self.__index = self

    return NewConfig
end

function Config:Get()
    --[[
       Will need to add a check, to see if the user gave certain inputs.
       Because if i don't do this, technically nothing would work (?).
       So let's say it needs to be initialized before running this.
    ]]

    if #{listfiles} ~= 1 then
        while true do end
    end

    local NewCopy = {};
    for k, v in next, listfiles(self.Folder) do
        -- Escape Certain Characters
        NewCopy[#NewCopy + 1] = v:sub(#self.Folder + 2, -5)
    end

    -- Sort
    table.sort(NewCopy, function(file1, file2)
        return file1 < file2
    end)

    return NewCopy
end

local Settings = Config:NewConfig({
    Folder = "Settings1",
    Name = "idk",
    Extension = "txt",
    Content = "{}"
})

-- Testing
Settings:Get()