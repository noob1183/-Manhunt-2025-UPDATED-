local PreyItems = {
    {ItemType.VOID_AXE, 1};
    {ItemType.IRON, 50};
}

local ChosenPreyList = {}
local DeadPreyList = {}
local ForcedPlayersToBePrey = {}
local AvailablePrefix = {',', '.', '!', '$', '>', ';'}

local MatchInProgress = false

local MatchTime = 10 * 60
local PreyExtraHealth = 40
local PreyHealthStackPerKill = 5
local MaxPreyHealthStack = 200
local MaxPreysAmount = 3

local ChoseIndex = nil

local OutputMark = '[ManhuntGameSource]: '

local OptimizerModule = require('Optimizer')

local function tableRemove(tbl, key)
    local result = OptimizerModule.RunTableLibFunc('remove', {tbl, key})
    return result
end

local function tableFind(tbl, value)
    local result = OptimizerModule.RunTableLibFunc('find', {tbl, value})
    return result
end

local function tableInsert(tbl, value, position)
    OptimizerModule.RunTableLibFunc('insert', {tbl, value, position})
end

Events.PlayerChatted(function(chatEvent)
    local plr = chatEvent.player
    local message = chatEvent.message
    
    local commandPrefix = ';'

    if not tableFind(AvailablePrefix, commandPrefix) then
        commandPrefix = ';'
    end

    local commandsList = {
        commandPrefix..'setmatchtime';
        commandPrefix..'setextrahealth';
        commandPrefix..'sethealthstacklimit';
        commandPrefix..'setpreyamountlimit';
        commandPrefix..'addpreyitem';
        commandPrefix..'removepreyitem';
        commandPrefix..'forceprey';
        commandPrefix..'unforceprey';
        commandPrefix..'changecmdprefix'
    }

    local filteredCommand = string.split(message, ' ') ---// "/cmd", "any"
    local command = string.lower(filteredCommand[1])

    if MatchInProgress == true then
        MessageService.sendError(plr, 'You cannot run the command once you started the match!!')
        return
    end

    if command == commandsList[1] then
        local timeToSet = tonumber(filteredCommand[2])
        if timeToSet ~= nil then
            if timeToSet < 1 then
                MessageService.sendError(plr, 'The time of the match must be above 1 minute and cannot go lower.')
                return
            end
            MatchTime = timeToSet * 60
            if timeToSet > 1 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed match time to '..timeToSet..' minutes!!')
            elseif timeToSet < 2 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed match time to '..timeToSet..' minute!!')
            end
        elseif timeToSet == nil then
            MessageService.sendError(plr, 'Format: '..commandsList[1]..' <number>')
        end
    elseif command == commandsList[2] then
        local extraPreyHealth = tonumber(filteredCommand[2])

        if extraPreyHealth ~= nil then
            if extraPreyHealth < 20 then
                MessageService.sendError(plr, 'The extra health of the prey must be 20 or over. Cannot go below 20!!')
                return
            end
            PreyExtraHealth = extraPreyHealth
            if extraPreyHealth > 1 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey extra health to '..extraPreyHealth..' healths!!')
            elseif extraPreyHealth < 2 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey extra health to '..extraPreyHealth..' health!!')
            end
        elseif extraPreyHealth == nil then
            MessageService.sendError(plr, 'Format: '..commandsList[2]..' <number>')
        end
    elseif command == commandsList[3] then
        local healthStackToSet = tonumber(filteredCommand[2])

        if healthStackToSet ~= nil then
            if healthStackToSet <= 0 then
                MessageService.sendError(plr, 'The health stack of the prey must be 1 or over. Cannot go to 0 or below 0!!')
                return
            end
            PreyHealthStackPerKill = healthStackToSet
            if healthStackToSet > 1 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey health stack to '..healthStackToSet..' stacks!!')
            elseif healthStackToSet < 2 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey health stack to '..healthStackToSet..' stack!!')
            end
        elseif healthStackToSet == nil then
            MessageService.sendError(plr, 'Format: '..commandsList[3]..' <number>')
        end
    elseif command == commandsList[4] then
        local preyLimitAmount = tonumber(filteredCommand[2])

        if preyLimitAmount ~= nil then
            if preyLimitAmount < 1 then
                MessageService.sendError(plr, 'The prey limit amount must be 1 or over. Cannot go below 1!!')
                return
            end
            MaxPreysAmount = preyLimitAmount
            if preyLimitAmount > 1 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey limit amount to '..preyLimitAmount..' preys!!')
            elseif preyLimitAmount < 2 then
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prey limit amount to '..preyLimitAmount..' prey!!')
            end
        elseif preyLimitAmount == nil then
            MessageService.sendError(plr, 'Format: '..commandsList[4]..' <number>')
        end
    elseif command == commandsList[5] then
        local preyItemName = tostring(filteredCommand[2])
        local preyItemAmount = tonumber(filteredCommand[3])

        if preyItemAmount == nil then
            MessageService.sendError(plr, 'Amount of item is not a number. Format: '..commandsList[5]..' <itemtype> <number>')
            return
        end

        if ItemType[string.upper(preyItemName)] == nil then
            MessageService.sendError(plr, 'Item does not exist. Format: '..commandsList[5]..' <itemtype> <number>')
            return
        end

        local NewItemList = {ItemType[string.upper(preyItemName)], preyItemAmount}

        if tableFind(PreyItems, NewItemList) == nil then
            tableInsert(PreyItems, NewItemList)
            MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> added '..preyItemAmount..' '..string.upper(preyItemName)..' into prey items list!!')
        elseif tableFind(PreyItems, NewItemList) ~= nil then
            MessageService.sendError(plr, 'Item already in list, if you wish to change the amount then please remove the item from the list!!')
        end

    elseif command == commandsList[6] then
        local preyItemName = tostring(filteredCommand[2])

        if ItemType[string.upper(preyItemName)] == nil then
            MessageService.sendError(plr, 'Item does not exist. Format: '..commandsList[5]..' <itemtype>')
            return
        end

        for _, items in pairs(PreyItems) do
            if tableFind(items, ItemType[string.upper(preyItemName)]) then
                tableRemove(PreyItems, items)
            end
        end
        MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> removed '..string.upper(preyItemName)..' from the prey items list!!')
    elseif command == commandsList[7] then
        local targetToForce = PlayerService.getPlayerByUserName(filteredCommand[2])

        if targetToForce ~= nil then

            if tableFind(ForcedPlayersToBePrey, targetToForce.name) ~= nil then
                MessageService.sendError(plr, 'Player is already forced to be the prey!!')
                return
            else
                tableInsert(ForcedPlayersToBePrey, targetToForce.name)
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> forced @'..targetToForce.name..' to be the prey!!')
            end
        elseif targetToForce == nil then
            MessageService.sendError(plr, 'Player cannot be found in the server!!')
        end
    elseif command == commandsList[8] then
        local targetToUnforce = PlayerService.getPlayerByUserName(filteredCommand[2])

        if targetToUnforce ~= nil then
    
            if tableFind(ForcedPlayersToBePrey, targetToUnforce.name) ~= nil then
                tableRemove(ForcedPlayersToBePrey, targetToUnforce.name)  -- Corrected removal using the found index
                MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> unforced @'..targetToUnforce.name..' to be the prey!!')
            else
                MessageService.sendError(plr, '@'..targetToUnforce.name..' cannot be found in the forced list!!')
                return
            end
        else
            MessageService.sendError(plr, '@'..tostring(filteredCommand[2])..' cannot be found in the server!!')
        end
    elseif command == commandsList[9] then
        local prefixToChange = tostring(filteredCommand[2])
        local prefixResult = tableFind(AvailablePrefix, prefixToChange)
        
        print(OutputMark..tostring(prefixResult))
        print(OutputMark..prefixToChange)

        if prefixResult then
            commandPrefix = AvailablePrefix[prefixResult]
            MessageService.sendInfo(plr, '<font color = "rgb(0, 255, 0)">Successfully</font> changed prefix to "'..prefixToChange..'"')
        else
            MessageService.sendError(plr, 'The avaliable prefixes are "," "." "!" "$" ">" ";"')
        end
    end
end)

local function MatchSetup()
    local PlayersList = PlayerService.getPlayers()

    if #PlayersList < 5 and #PlayersList > 1 then
        MaxPreysAmount = 1
    -- else
    --     MessageService.broadcast('Cannot start game with 1 player!!')
    --     return
    end

    ChoseIndex = MaxPreysAmount

    for _, forcedPlayer in ipairs(ForcedPlayersToBePrey) do
        local player = PlayerService.getPlayerByUserName(forcedPlayer)
        
        if player ~= nil then
            tableInsert(ChosenPreyList, player.name)
            tableRemove(ForcedPlayersToBePrey, player.name)
            ChoseIndex = ChoseIndex - 1
        end
    end

    repeat task.wait()
        if ChoseIndex > 0 then
            local ChosenPrey = nil
        
            if ChoseIndex < #PlayersList then
                ChosenPrey = PlayersList[ChoseIndex]
                
                if ChosenPrey ~= nil then
                    tableInsert(ChosenPreyList, ChosenPrey.name)
                end
            end
        
            ChoseIndex = ChoseIndex - 1
        end
    until ChoseIndex == 0

    for _, preyName in pairs(ChosenPreyList) do
        local prey = PlayerService.getPlayerByUserName(preyName)

        print(preyName)

        if prey ~= nil then
            local preyEntity = prey:getEntity()
            for _, ItemsConfig in pairs(PreyItems) do
                InventoryService.giveItem(prey, ItemsConfig[1], ItemsConfig[2], true)
            end
            print(OutputMark..'Finished giving prey items...')
            preyEntity:setMaxHealth(preyEntity:getMaxHealth() + PreyExtraHealth)
            CombatService.heal(preyEntity, preyEntity:getMaxHealth() - preyEntity:getHealth())
            print(OutputMark..'Finished add extra health')
            for _, team in pairs(TeamService.getAllTeams()) do
                if team.name == 'Orange' then
                    TeamService.setTeam(prey, team)
                end
            end
        end
    end

end

Events.EntityDeath(function(deathEvent)
    local player = deathEvent.entity:getPlayer()
    local killer = deathEvent.killer

    if killer ~= nil then
        killer = killer:getPlayer()
    else
        print(OutputMark..'Killer is nil.')
    end

    if killer ~= nil and tableFind(ChosenPreyList, killer.name) and MatchInProgress == true then
        local killerEntity = killer:getEntity()
        killerEntity:setMaxHealth(killerEntity:getMaxHealth() + PreyHealthStackPerKill)
        print(OutputMark..'Add health stack for @'..killer.name)
    end

    if player ~= nil and tableFind(ChosenPreyList, player.name) and MatchInProgress == true then ---// If the player name is in the prey list and match has started when player died then.
        tableInsert(DeadPreyList, player.name) ---// Insert the prey into deadlist.
        tableRemove(ChosenPreyList, player.name) ---// Remove the prey out of ChosenPreyList.
        if #ChosenPreyList == 0 then ---// If ChosenPreyList is empty then the hunters win.
            for _, deadPreyName in pairs(DeadPreyList) do
                local prey = PlayerService.getPlayerByUserName(deadPreyName)
                if prey then
                    local preyTeam = TeamService.getTeam(prey)
                    MatchService.endMatch(preyTeam)
                end
            end
        end
        if #ChosenPreyList > 1 then
            AnnouncementService.sendAnnouncement('A prey got caught by the hunters!! There are only '..#ChosenPreyList..' more PREYS!!')
        elseif #ChosenPreyList < 2 then
            AnnouncementService.sendAnnouncement('A prey got caught by the hunters!! There are only '..#ChosenPreyList..' more PREY!!')
        end
    end
end)

Events.EntitySpawn(function(spawnEvent)
    local player = spawnEvent.entity:getPlayer()

    if player ~= nil and tableFind(DeadPreyList, player.name) and #ChosenPreyList ~= 0 and MatchInProgress == true then
        for _, team in pairs(TeamService.getAllTeams()) do
            if team.name == 'Blue' then
                TeamService.setTeam(player, team)
            end
        end
    end
end)

Events.MatchStart(function()
    MatchSetup()
    for _, player in pairs(PlayerService.getPlayers()) do
        local PlayerTeam = TeamService.getTeam(player)

        if PlayerTeam.name == 'Orange' and not tableFind(ChosenPreyList, player.name) then
            for _, team in pairs(TeamService.getAllTeams()) do
                if team.name == 'Blue' then
                    TeamService.setTeam(player, team)
                end
            end
            CombatService.damage(player, math.huge)
        end
    end
    print(OutputMark..'Finished assign players that are not hunter and on orange team to blue team!!')
    
    MatchInProgress = true

    if #ChosenPreyList > 1 then
        if (MatchTime / 60) < 1 then
            AnnouncementService.sendAnnouncement('All players have '..(MatchTime/ 60)..' minute to catch '..#ChosenPreyList..' preys before the timer end.', Color3.fromRGB(255, 0, 0))
        elseif (MatchTime / 60) > 2 then
            AnnouncementService.sendAnnouncement('All players have '..(MatchTime/ 60)..' minute to catch '..#ChosenPreyList..' preys before the timer end.', Color3.fromRGB(255, 0, 0))
        end
    elseif #ChosenPreyList < 2 then
        if (MatchTime / 60) < 1 then
            AnnouncementService.sendAnnouncement('All players have '..(MatchTime/ 60)..' minutes to catch '..#ChosenPreyList..' prey before the timer end.', Color3.fromRGB(255, 0, 0))
        elseif (MatchTime / 60) > 2 then
            AnnouncementService.sendAnnouncement('All players have '..(MatchTime/ 60)..' minutes to catch '..#ChosenPreyList..' prey before the timer end.', Color3.fromRGB(255, 0, 0))
        end
    end

    task.spawn(function() OptimizerModule.RunSupportAndTips() end)

    MatchTime = math.clamp(MatchTime, 60, math.huge)
    OptimizerModule.Countdown(MatchTime, 0, -1, 1)

    if #ChosenPreyList ~= 0 then
        for _, player in pairs(PlayerService.getPlayers()) do
            local PlayerTeam = TeamService.getTeam(player)

            if PlayerTeam.name == 'Blue' then
                MatchService.endMatch(PlayerTeam)
            end
        end
    end
end)
