--[[
    Your love2d game start here
]]
button = {
    sprite = nil;
    pos_x = 0;
    pos_y = 0;
    width = 8;
    height = 8;
    isHovered = function(self)
        return (love.mouse.getX()>self.pos_x and love.mouse.getX()<self.width+self.pos_x and love.mouse.getY()>self.pos_y+scroll_y and love.mouse.getY()<self.height+self.pos_y+scroll_y)
    end;
    renderCondition = function(self)
        return true
    end;
    buttonAction = function(self) end;
    Render = function(self)
        if not self:renderCondition() then return end 
        local r, g, b, a = love.graphics.getColor()
        if self:isHovered() then
            love.graphics.setColor(0.5,0.5,0.5, 1) else love.graphics.setColor(r, g, b, a)
            love.graphics.setBlendMode("alpha")
        end
        love.graphics.draw(self.sprite,self.pos_x,self.pos_y)
        love.graphics.setColor(r, g, b, a)
    end;
    New = function(self, table)
        self.__index = self
        setmetatable(table, self)
        return table
    end,
}
function formatNumber(number)
    if number<1000 then 
        return tostring(round(number)) or ""
            
    end
    local endings = {"","k","m","b","t"}
    local oom = math.floor(math.log(number,10)/3)
    return string.format("%.2f%s",number/(10^(oom*3)),endings[oom+1])
end
--boxes ={}
function drawBox(x,y,width,height)
    if(not boxes[width.."_"..height]) then
        boxes[width.."_"..height] = love.graphics.newCanvas(width, height)
        local old_canvas = love.graphics.getCanvas()
        love.graphics.setCanvas(boxes[width.."_"..height])
            love.graphics.setColor(109/255, 88/255, 88/255, 1)
            love.graphics.rectangle("fill", 0,0, width,height)
            love.graphics.setColor(13/255, 20/255, 25/255, 1)
            love.graphics.rectangle("fill", 2,2, width-4,height-4)
            love.graphics.setColor(1,1,1, 1)
        love.graphics.setCanvas(old_canvas)
    end
    love.graphics.draw(boxes[width.."_"..height],x,y)
end
function drawBox(x,y,width,height)
    love.graphics.setColor(109/255, 88/255, 88/255, 1)
    love.graphics.rectangle("fill", x,y, width,height)
    love.graphics.setColor(13/255, 20/255, 25/255, 1)
    love.graphics.rectangle("fill", x+2,y+2, width-4,height-4)
    love.graphics.setColor(1,1,1, 1)
end


love.graphics.setDefaultFilter('nearest', 'nearest')
function renderButton(sprite,x,y,width,height)
    if(love.mouse.getX()>x and love.mouse.getX()<width+x and love.mouse.getY()>y and love.mouse.getY()<height+y) then
        love.graphics.setColor(0.5,0.5,0.5, 1) else love.graphics.setColor(1,1,1, 1)
        love.graphics.setBlendMode("alpha")
    end
    love.graphics.draw(sprite,x,y)
    love.graphics.setColor(1,1,1, 1)
end
function avgMult(chance,mult) return 1+chance*(mult-1) end
local currentResource = 1
local resourceWaveReqs ={1,5,10,15}
function resourcesPerMinute(wave_data,resource)
    local avgWave = math.floor((wave_data[1]+(resource==1 and ((5-wave_data[2])/5-1) or 0))/resourceWaveReqs[resource or 1])
    return (avgWave^2+avgWave)*120/wave_data[3]* avgMult(p.x5money/100,5)*avgMult(p.x2money,2)
end
function love.load()
    -- init something here ...
    love.window.setTitle('julk\'s shminer event sim')
    love.window.setMode(900,650)
    love.graphics.setBackgroundColor( 52/255, 52/255, 52/255, 1 )
    local path = "shminerEvent_stripped.lua"
    local chunk,errormsg = love.filesystem.load(path)
    --[[local dir = ""
    --assuming that our path is full of lovely files (it should at least contain main.lua in this case)
    local files = love.filesystem.getDirectoryItems(dir)
    result =""
    for k, file in ipairs(files) do
        result = result.."\n"..k .. ". " .. file --outputs something like "1. main.lua"
    end--]]
    --filedata = love.filesystem.newFileData(path)
    chunk()
    results_1,results_2,results_3= GiveResults()
    old_cost = results_3
    upgradeNames = {
        {"+1 Atk Dmg", "+2 Max Hp", "+0.02 Atk Spd", "+0.03 Move Spd", "+2% Event Game Spd", "+1% worthless crits"or"1% Crit Chance, +0.10 Crit Dmg", "+1 Atk Dmg +2 Max Hp", "+1 Tier 1 Upgrade Caps", "+1% Prestige Bonus", "+3 Atk Dmg, +3 Max Hp"}, 
        {"+3 Max Hp", "-0.02 Enemy Atk Spd", "-1 Enemy Atk Dmg", "-1% E.Crt rate, -0.1 E.Crt Dmg"or"-1% Enemy Crit Chance, -0.10 Enemy Crit Dmg", "+1 Atk Dmg, +0.01 Atk Spd", "+1 Tier 2 Upgrade Caps", "+2% Prestige Bonus"}, 
        {"+2 Atk Dmg", "+0.02 Atk Spd", "+1% more worthless crits"or"+1% Crit Chance", "+3% Event Game Spd", "+3 Atk Dmg, +3 Max Hp", "+1 Tier 3 Upgrade Caps", "+3% 5x Drop Chance", "+5 Max Hp, +0.03 Atk Spd"}, 
        {"+1% Block Chance", "+5 Max Hp", "-0.1  -0.1 E.Crt Dmg" or "+0.10 Crit Dmg, -0.10 Enemy Crit Dmg","+0.02 Move & Atk Spd"or "+0.02 Atk Spd, +0.02 Move Spd", "+4 Max Hp, +4 Atk Dmg", "+1 Tier 4 Upgrade Caps", "+1 Cap Of Cap Upgrades", "+10 Max Hp, +0.05 Atk Spd"}
    }
    upgradeNames_gem = {"+10% dmg","+10% max hp","+100% Event Game Spd","2x Event Currencies"}
    prestigeUnlocked = {
        {0, 0, 0, 0, 1, 2, 2, 4, 8, 10},
        {0, 0, 0, 3, 4, 5, 10},
        {1, 1, 2, 3, 4, 6, 8, 10},
        {1, 3, 4, 5, 6, 6, 7, 10}
    }
    maxLevels = {
        {50,50,25,25,25,25,25,10,5,40},--t1
        {25,15,10,15,25,10,15},--t2
        {20,20,20,20,10,10,10,40},--t3
        {15,15,15,15,15,10,10,40}--t4
    }
    capUpgrades =  {8, 6, 6, 6}
    currentMaxLvl = function(i,j)
        if(capUpgrades[i]==j) then
            return maxLevels[i][j]+upgrades[4][7]
        elseif(not (i==4 and j==7)) then
            return maxLevels[i][j]+upgrades[i][capUpgrades[i]]
        else
            return maxLevels[i][j]
        end
    end
    currentMaxLvl_gem = function(i)
        if (i<3) then
            return 5+prestigeCount
        elseif i==3 then
            return 1+math.min(2,math.floor(prestigeCount/5))
        else
            return 1
        end
    end
    positions = {
        prestige_x = 150,prestige_y = 85,
        upgrades_x = 360,upgrades_y = 30,
        upgrades_gem_x = 130, upgrades_gem_y = 550,
        playerStats_x = 140, playerStats_y = 100,
        enemyStats_x = 140, enemyStats_y = 300,
        costs_x = 140, costs_y = 405,
    }
    upg_string = "lvl %2i/%2i %s %s"
    upg_string_p = "(P%i)"
    upg_gem_string = "lvl %2i/%2i %s"
    approx_results_string = "approx wave:%i-%i time: %.2f resource %i/min: %.2f (scroll down for instructions)"
    approx_results_efficiency_string = "%.2f"
    approx_efficiency_base = 0
    scroll_y = 0
    love.keyboard.keysPressed = {}
    prev_mouseDown = false
    storedApprox = {}
    instructions = "INSTRUCTIONS:\n -click +/- buttons to change upgrade levels (holding shift will change level by 10) and prestige\n -press SPACE to cycle which resource is used for upgrade benefit calculations\n -press ENTER to set current cost as base cost\n -on the left you see your simulated run stats the number behind the wave is the time in seconds, \n in the lower section you can see a breakdown of how often you get how far for 1000 runs\n-number to the right of each upgrade is how much it changes your income of coins or other resources\n-beware that this may not be fully accurate as you get to higher waves, it slightly overshoots (negligable below w100)"
    
    upg_bg = love.graphics.newCanvas(400, 15)
    upg_gem_bg = love.graphics.newCanvas(225, 15)
    upg_button_up = love.graphics.newCanvas(8, 8)
    upg_button_down = love.graphics.newCanvas(8, 8)
    stats_bg = love.graphics.newCanvas(180, 195)
    stats_bg_2 = love.graphics.newCanvas(180, 100)
    button_set_costs = love.graphics.newCanvas(180, 195)
    -- Rectangle is drawn to the canvas with the regular/default alpha blend mode ("alphamultiply").
    love.graphics.setCanvas(upg_bg)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(151/255, 104/255, 104/255, 1)
        love.graphics.rectangle("fill", 0,1, 400,14)
        love.graphics.setColor(36/255, 36/255, 36/255, 1)
        love.graphics.rectangle("fill", 2,3, 396,10)
    love.graphics.setCanvas(upg_gem_bg)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(151/255, 104/255, 104/255, 1)
        love.graphics.rectangle("fill", 0,1, 225,14)
        love.graphics.setColor(36/255, 36/255, 36/255, 1)
        love.graphics.rectangle("fill", 2,3, 221,10)
    love.graphics.setCanvas(upg_button_up)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255/255, 0/255, 0/255, 1)
        love.graphics.rectangle("fill", 0,0, 8,8)
        love.graphics.setColor(1,1,1, 1)
        love.graphics.rectangle("fill", 1,3, 6,2)
        love.graphics.rectangle("fill", 3,1, 2,6)
    love.graphics.setCanvas(upg_button_down)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255/255, 0/255, 0/255, 1)
        love.graphics.rectangle("fill", 0,0, 8,8)
        love.graphics.setColor(1,1,1, 1)
        love.graphics.rectangle("fill", 1,3, 6,2)
    love.graphics.setCanvas(stats_bg)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        --the big box
        drawBox(0,15,180,180)
        --[[love.graphics.setColor(109/255, 88/255, 88/255, 1)
        love.graphics.rectangle("fill", 0,15, 180,180)
        love.graphics.setColor(13/255, 20/255, 25/255, 1)
        love.graphics.rectangle("fill", 2,17, 176,176)--]]
        --smol box
        drawBox(25,0,130,30)
        --[[love.graphics.setColor(109/255, 88/255, 88/255, 1)
        love.graphics.rectangle("fill", 25,0, 130,30)
        love.graphics.setColor(13/255, 20/255, 25/255, 1)
        love.graphics.rectangle("fill", 27,2, 126,26)
        love.graphics.setColor(1,1,1, 1)--]]
        love.graphics.print("Player stats",40,7)
    love.graphics.setCanvas(stats_bg_2)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        --the big box
        drawBox(0,15,180,85)
        --smol box
        drawBox(25,0,130,30)
        love.graphics.setColor(1,1,1, 1)
        love.graphics.print("Enemy stats",40,7)
    --[[love.graphics.setCanvas(button_set_costs)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255/255, 0/255, 0/255, 1)
        love.graphics.rectangle("fill", 0,0, 8,8)
        love.graphics.setColor(1,1,1, 1)
        love.graphics.rectangle("fill", 1,3, 6,2)
        love.graphics.rectangle("fill", 3,1, 2,6)
        love.graphics.print("set this to current ->",40,7)--]]
    love.graphics.setCanvas()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1,1,1, 1)
    button_minus = button:New {sprite=upg_button_down}
    button_plus = button:New {sprite=upg_button_up}
    buttons = {
        [0] = {
            button_minus:New {pos_x=positions.prestige_x,pos_y=positions.prestige_y+3, buttonAction = function(self) prestigeCount = prestigeCount-1 end, renderCondition = function(self) return prestigeCount>0 end,},
            button_plus:New {pos_x=positions.prestige_x+10,pos_y=positions.prestige_y+3, buttonAction = function(self) prestigeCount = prestigeCount+1 end,}
        },
    }
    local offset=positions.upgrades_y
    for i=1,4 do
        buttons[i] = buttons[i] or {}
        offset=offset+20
        for j=1,#upgradeNames[i] do
            buttons[i][j]=button_minus:New {pos_x=positions.upgrades_x+13,pos_y=offset+4,buttonAction = function(self) upgrades[i][j] = upgrades[i][j]-1 if love.keyboard.isDown( "lshift" ) then upgrades[i][j] = math.max(0,upgrades[i][j]-9) end end,renderCondition = function(self) return upgrades[i][j] and (upgrades[i][j]>0) end,}
            buttons[i][j+#upgradeNames[i]]=button_plus:New {pos_x=positions.upgrades_x+22,pos_y=offset+4,buttonAction = function(self) upgrades[i][j] = (upgrades[i][j] or 0)+1 if love.keyboard.isDown( "lshift" ) then upgrades[i][j] = math.min(currentMaxLvl(i,j),(upgrades[i][j] or 0)+9) end end,renderCondition = function(self) return upgrades[i][j] and (upgrades[i][j]<currentMaxLvl(i,j)) end,}
            offset=offset+15
        end
    end
    local offset=positions.upgrades_gem_y
    buttons.gem = {}
    offset=offset+20
    for j=1,#upgradeNames_gem do
        buttons.gem[j]=button_minus:New {pos_x=positions.upgrades_gem_x+13,pos_y=offset+4,buttonAction = function(self) gemUp[j] = gemUp[j]-1 if love.keyboard.isDown( "lshift" ) then gemUp[j] = math.max(0,gemUp[j]-9) end end,renderCondition = function(self) return gemUp[j] and (gemUp[j]>0) end,}
        buttons.gem[j+#upgradeNames_gem]=button_plus:New {pos_x=positions.upgrades_gem_x+22,pos_y=offset+4,buttonAction = function(self) gemUp[j] = (gemUp[j] or 0)+1 if love.keyboard.isDown( "lshift" ) then gemUp[j] = math.min(currentMaxLvl_gem(j),(gemUp[j] or 0)+9) end end,renderCondition = function(self) return gemUp[j] and (gemUp[j]<currentMaxLvl_gem(j)) end,}
        offset=offset+15
    end
end

function love.resize(w, h)
    -- ...
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'up' then
        scroll_y=scroll_y-5
    end
    if key == 'down' then
        scroll_y=scroll_y+5
    end
    if key == 'return' then
        old_cost = GiveCurrentCost()
        --results_1,results_2,results_3=GiveResults()
    end
    if key == 'space' then
        currentResource = 1+currentResource%4
    end
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end
function love.wheelmoved(x, y)
    scroll_y = scroll_y+math.ceil(y*2)
end

function love.update(dt)
    if love.mouse.isDown(1) and ( not prev_mouseDown) then
        for k,buttonSet in pairs(buttons) do
            for k,thisButton in pairs(buttonSet) do
                if thisButton:renderCondition() and thisButton:isHovered() then thisButton:buttonAction() storedApprox = {} results_1,results_2,results_3=GiveResults() end
            end
        end
    end
    prev_mouseDown = love.mouse.isDown(1)
    love.keyboard.keysPressed = {}
end

function love.draw()
    -- draw your stuff here
    love.graphics.translate( 0, scroll_y )
    love.graphics.setColor(1,1,1, 1)
    local _,lines = results_1:gsub("\n","\n")
    drawBox(5,93,130,14*lines-80)
    drawBox(5,5,340,78)
    love.graphics.print(results_1, 10, 10)
    love.graphics.draw(stats_bg,positions.playerStats_x,positions.playerStats_y)
    love.graphics.print(string.format("Max hp: %i\nAtk Dmg: %i\nAtk Spd: %.2f\nMove Spd: %.2f\nCrit Chance: %i\nCrit Dmg: %.2f\n2x Currencies: %i\nEvent Spd: %.2f\nBlock Chance: %i\nPrestige Mult: %.2f\n5x Currencies: %i",
    p.health,p.atk,p.atkSpeed,p.walkSpeed,p.crit,p.critDmg,p.x2money,p.gameSpeed,p.blockChance*100,1+prestigeCount*p.prestigeBonusScale,p.x5money),positions.playerStats_x+10,positions.playerStats_y+32)
    drawBox(8,638,725,120)
    love.graphics.print(instructions,10,640)
    
    
    
    love.graphics.draw(stats_bg_2,positions.enemyStats_x,positions.enemyStats_y)
    love.graphics.print(string.format("max oneshot wave: %i\natk 1 until wave: %i\nBase atk Spd: %.2f\nno crits up to wave: %i",
    get_highest_wave_killed_in_x_hits(p,e,1),math.max(0,math.ceil((-1*e.atk+1)/e.atkScaling)),e.atkSpeed,(-1*(e.critDmg-1))/e.critDmgScaling),positions.enemyStats_x+10,positions.enemyStats_y+32)
    
    love.graphics.print("Prestiges: "..prestigeCount,positions.prestige_x+20,positions.prestige_y)
    for i=1,#buttons[0] do buttons[0][i]:Render() end
    local offset=positions.upgrades_y
    
    love.graphics.print(string.format("~resource %i/min",currentResource),positions.upgrades_x+260,offset)
    for i=1,4 do
        storedApprox[i] = storedApprox[i] or {}
        love.graphics.print(string.format("Tier %i upgrades",i),positions.upgrades_x,offset)
        offset=offset+20
        for j=1,#upgradeNames[i] do
            if prestigeUnlocked[i][j]>prestigeCount then love.graphics.setColor(0.9,0,0, 1) else love.graphics.setColor(1,1,1, 1) end
            love.graphics.setBlendMode("alpha", "premultiplied")
            love.graphics.draw(upg_bg,positions.upgrades_x+10,offset)
            buttons[i][j]:Render()
            buttons[i][j+#upgradeNames[i]]:Render()
            love.graphics.setBlendMode("alpha")
            local prestige_or_price_string = upg_string_p:format(prestigeUnlocked[i][j])
            upgrades[i][j] = upgrades[i][j] or 0
            if prestigeUnlocked[i][j]<=prestigeCount then 
                prestige_or_price_string = formatNumber(costs[i][j]*1.25^upgrades[i][j])
            end
            love.graphics.print(upg_string:format(upgrades[i] and upgrades[i][j] or 0,currentMaxLvl(i,j),prestige_or_price_string,upgradeNames[i][j]),positions.upgrades_x+30,offset)
            storedApprox[i][j] = storedApprox[i][j] or {GiveApproxWithUpgraded(i,j)}
            --love.graphics.print(approx_results_efficiency_string:format(storedApprox[i][j][1],storedApprox[i][j][2],storedApprox[i][j][3],(storedApprox[i][j][1]+(5-storedApprox[i][j][2])/5))/storedApprox[i][j][3],positions.upgrades_x+330,offset)
            love.graphics.print(approx_results_efficiency_string:format(resourcesPerMinute(storedApprox[i][j],currentResource)-approx_efficiency_base),positions.upgrades_x+330,offset)
            offset=offset+15
        end
        love.graphics.setColor(1,1,1, 1)
    end
    storedApprox.base = storedApprox.base or {GiveApproxWithUpgraded(1,8)}
    approx_efficiency_base = resourcesPerMinute(storedApprox.base,currentResource)
    love.graphics.print(approx_results_string:format(storedApprox.base[1],storedApprox.base[2],storedApprox.base[3],currentResource,approx_efficiency_base),positions.upgrades_x,positions.upgrades_y-20)
    drawBox(positions.costs_x,positions.costs_y,180,140)
    love.graphics.print(string.format("base cost: \n%s %s \n%s %s",formatNumber(old_cost[1]),formatNumber(old_cost[2]),formatNumber(old_cost[3]),formatNumber(old_cost[4])),positions.costs_x+10,positions.costs_y+5)
    love.graphics.print(string.format("current cost: \n%s %s \n%s %s",formatNumber(results_3[1]),formatNumber(results_3[2]),formatNumber(results_3[3]),formatNumber(results_3[4])),positions.costs_x+10,positions.costs_y+50)
    love.graphics.print(string.format("difference: \n%s %s \n%s %s",formatNumber(results_3[1]-old_cost[1]),formatNumber(results_3[2]-old_cost[2]),formatNumber(results_3[3]-old_cost[3]),formatNumber(results_3[4]-old_cost[4])),positions.costs_x+10,positions.costs_y+95)
    local offset=positions.upgrades_gem_y
    love.graphics.print("Gem upgrades",positions.upgrades_gem_x,offset)
    offset=offset+20
    for i=1,#upgradeNames_gem do
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(upg_gem_bg,positions.upgrades_gem_x+10,offset)
        buttons.gem[i]:Render()
        buttons.gem[i+#upgradeNames_gem]:Render()
        love.graphics.setBlendMode("alpha")
        love.graphics.print(upg_gem_string:format(gemUp[i] or 0,currentMaxLvl_gem(i),upgradeNames_gem[i]),positions.upgrades_gem_x+30,offset)
        offset=offset+15
    end
    love.graphics.setColor(1,1,1, 1)
    --write stats, max hp, atk, atk spd, move spd, crit, crit dmg, 2x money, event spd, block, prestige effect, 5x money
end

