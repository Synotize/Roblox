local function Closest()
    --[[
        Don't be crying cuz I didn't use GetDistanceFromCharacter. pls stfu idc
        Now I could add more stuff here, but later on, thank you.
    ]]
    local Closest, Distance = nil, math.huge;
    local Camera = workspace:FindFirstChildOfClass('Camera');
    local Client, Players = game.Players.LocalPlayer, game.Players:GetPlayers();


    local function Valid(char)
        return (char and char:FindFirstChild('HumanoidRootPart')) or false
    end

    for Name = 1, #Players do
        local Player = rawget(Players, Name)

        if (Player ~= Client and Valid(Player.Character)) then
            local Position, OnScreen = Camera:WorldToScreenPoint(Player.Character.PrimaryPart.Position)
            local Difference = (Valid(Client.Character) and Client.Character.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude

            if (Difference < Distance) then
                Closest = Player
                Distance = Difference
            end
        end

    end

    return Closest, Distance
end

-- // [Testing] \\
local Closest, Distance = Closest()
print(Closest, Distance)