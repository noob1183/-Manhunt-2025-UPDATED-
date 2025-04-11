local ChatMessages = {
    ['SupportsMessages'] = {
        'Want more game modes? Go to https://github.com/noob1183 and get more there!!';
        'Want to check for this game mode updates? Go to https://github.com/noob1183/Bedwars_Manhunt then find the "LATEST UPDATE(S)"!!';
        'Follow me on Roblox in my profile to help me get verified badge (@Tranquananh2811)!!';
    };
 
    ['TipsMessage'] = {
        'Lassy kit can be use to throw lasso to pull and stun player.';
        'Eldertree kit and hunter health stack is op?';
        'Void axe and Triton trident will create a great travel distance when both used.';
        'Hunter health stack is 5 health per kill.';
    };
}
 
local ChatMessagesNames = {
    'SupportsMessages';
    'TipsMessage'
}

local ChatSupportsTag = '[SUPPORTS]: '
local ChatTipsTag = '[TIPS]: '

return {
    RunSupportAndTips = function()
        while task.wait(20) do
            local ChosenCategory = ChatMessagesNames[math.random(1, #ChatMessagesNames)]
            local ChosenMessage = ChatMessages[ChosenCategory][math.random(1, #ChatMessages[ChosenCategory])]
    
            if ChosenCategory == 'SupportsMessages' then
                ChatService.sendMessage(ChatSupportsTag..ChosenMessage, Color3.fromRGB(255, 0, 0))
            elseif ChosenCategory == 'TipsMessage' then
                ChatService.sendMessage(ChatTipsTag..ChosenMessage, Color3.fromRGB(255, 255, 0))
            end
        end
    end;

    RunTableLibFunc = function(RunType, Configs)
        local tbl = Configs[1]
        local key = Configs[2]
        local position = Configs[3]
    
        if RunType == 'remove' then
            local length = #tbl
    
            if key then
                local indexToRemove
    
                for i = 1, length do
                    if tbl[i] == key then
                        indexToRemove = i
                        break
                    end
                end
    
                if indexToRemove then
                    local removedValue = tbl[indexToRemove]
    
                    for i = indexToRemove, length - 1 do
                        tbl[i] = tbl[i + 1]
                    end
    
                    tbl[length] = nil
                    return removedValue
                end
            end
    
            return nil
        elseif RunType == 'find' then
            for i, v in ipairs(tbl) do
                if v == key then
                    return i
                end
            end
            return nil        
        elseif RunType == 'insert' then
            position = position or (#tbl + 1)
    
            if position >= 1 and position <= (#tbl + 1) then
                for i = #tbl, position, -1 do
                    tbl[i + 1] = tbl[i]
                end
                tbl[position] = key
                print(tbl[position])
            else
                print("Invalid position for insertion")
            end
        end
    end;

    Countdown = function(startVal, endVal, increasementVal, delayVal)
        for timeValue = startVal, endVal, increasementVal do
            task.wait(delayVal)
    
            if timeValue == 10 then
                AnnouncementService.sendAnnouncement('Hunters only have 10 seconds left!!', Color3.fromRGB(255, 0, 0))
            end
        end
    end
}
