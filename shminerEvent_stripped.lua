
gemUp={0,0,0,0}--levels of the gem upgrades (+10%atk,+10%hp,+100% game speed,2x currency)
local oldUpgrades={{24,34,44,44,44,1,22,20,16,7},{20,1,30,23,1,20,12},{5,21,1,1,11,7,17,12},{1,16,16,16,12,1,10,10}}
--upgrades={{9,55,45,45,45,1,44,20,25,27},{36,35,30,35,30,20,28},{1,15,1,1,5,16,26,6},{1,17,30,27,20,15,10,22}}
prestigeCount = 0
upgrades = {{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0}}
--prices of each upgrade at base, incomplete
costs={
    {5,6,8,10,12,20,75,2500,25000,5000},--t1
    {5,8,12,20,40,500,650},--t2
    {5,8,12,18,30,250,300,125},--t3
    {10,12,15,20,50,250,500,150}--t4
}

function round(number,precision)
	return tonumber(string.format("%."..(precision or 0).."f",number))
end

local function copyTable(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[k]=v
	end
	return newT
end

local function modifyStat(stat, amount, target)
	--print(stat..target[stat].." "..amount)
	target[stat]=target[stat]+amount
end
--impact of each upgrade on stats, hopefully accurate, comments about unlock time may not be accurate
local upgradeInstructions ={
	{--t1 upgrades
		function(j,p,e) modifyStat("atk", j, p) end,--max 50
		function(j,p,e) modifyStat("health", 2*j, p) end,--max 50
		function(j,p,e) modifyStat("atkSpeed", 0.02*j, p) end,--max 25
		function(j,p,e) modifyStat("walkSpeed", 0.03*j, p) end,--max 25
		function(j,p,e) modifyStat("gameSpeed", 0.02*j, p) end,--max 25
		function(j,p,e) modifyStat("crit", j, p) modifyStat("critDmg", 0.1*j, p) end,--p1
		function(j,p,e) modifyStat("atk", j, p) modifyStat("health", 2*j, p) end,--p2?
		function(j,p,e) end,--p3 t1 cap +1, max 10
		function(j,p,e) modifyStat("prestigeBonusScale", 0.01*j, p) end, --p8
		function(j,p,e) modifyStat("health", 3*j, p) modifyStat("atk", 3*j, p) end,--p10
	},
	{--t2 upgrades
		function(j,p,e) modifyStat("health", 3*j, p) end,
		function(j,p,e) modifyStat("atkSpeed", -0.02*j, e) end,
		function(j,p,e) modifyStat("atk", -j, e) end,
		function(j,p,e) modifyStat("crit", -j, e) modifyStat("critDmg", -0.10*j, e) end,--p3 max 15
		function(j,p,e) modifyStat("atk", j, p) modifyStat("atkSpeed", 0.01*j, p) end, --p4 max 25
		function(j,p,e) --[[modifyStat("crit", -0.01*j, e)]]end,--p5 t2 cap +1, max 10
		function(j,p,e) modifyStat("prestigeBonusScale", 0.02*j, p) end,--p10
		
	},
	{--t3 upgrades
		function(j,p,e) modifyStat("atk", 2*j, p) end,
		function(j,p,e) modifyStat("atkSpeed", 0.02*j, p) end,
		function(j,p,e) modifyStat("crit", j, p) end,
		function(j,p,e) modifyStat("gameSpeed", 0.03*j, p) end,--p3 max 20
		function(j,p,e) modifyStat("atk", 3*j, p) modifyStat("health", 3*j, p) end,--p4 t4 max 10
		function(j,p,e) end,--p6 t3 cap +1, max 10
		function(j,p,e) modifyStat("x5money", 3*j, p) end,--p8
        function(j,p,e) modifyStat("health", 5*j, p) modifyStat("atkSpeed", 0.03*j, p) end, --p10
	},
	{--t4 upgrades
		function(j,p,e) modifyStat("blockChance", 0.01*j, p) end,
		function(j,p,e) modifyStat("health", 5*j, p) end, --t3 max 15
		function(j,p,e) modifyStat("critDmg", 0.1*j, p)  modifyStat("critDmg", -0.1*j, e) end, --t4 max 15
		function(j,p,e) modifyStat("atkSpeed", 0.02*j, p) modifyStat("walkSpeed", 0.02*j, p) end, --t5 max 15
		function(j,p,e) modifyStat("atk", 4*j, p) modifyStat("health", 4*j, p) end,--p6  max 10
		function(j,p,e) end,--p6 t4 cap +1, max 10
		function(j,p,e) end,--p7 +cap cap +1, max 10
        function(j,p,e) modifyStat("health", 10*j, p) modifyStat("atkSpeed", 0.05*j, p) end, --p10
	},
}
local function parseUpgrades(upgrades,upgradeInstructions,player,enemy,prestiges,gemUps)
	local gemUps= gemUps or {0,0,0,0}
	local p=copyTable(player)
	local e=copyTable(enemy)
	for i=1, #upgrades , 1 do
		for j=1, #upgrades[i],1 do
			upgradeInstructions[i][j](upgrades[i][j],p,e)
		end
	end
	--print(p.atk) print(p.health) print(e.atk)
	p.atk=round(p.atk*(1+p.prestigeBonusScale*prestiges)*(1+0.1*gemUps[1]))
	p.health=round(p.health*(1+p.prestigeBonusScale*prestiges)*(1+0.1*gemUps[2]))
	p.gameSpeed=p.gameSpeed+gemUps[3]
	p.x2money=p.x2money+gemUps[4]
	return p,e
end



local function calcMaterials(wave,p)
	local mat1 = (wave^2+wave)/2 * (1+(p.x2money or 0)) * (1+4*(p.x5money/100 or 0))
	local mat2 = (math.floor(wave/5)^2+math.floor(wave/5))/2 * (1+(p.x2money or 0)) * (1+4*(p.x5money/100 or 0))
	local mat3 = (math.floor(wave/10)^2+math.floor(wave/10))/2 * (1+(p.x2money or 0)) * (1+4*(p.x5money/100 or 0))
	local mat4 = (math.floor(wave/15)^2+math.floor(wave/15))/2 * (1+(p.x2money or 0)) * (1+4*(p.x5money/100 or 0))
	return mat1,mat2,mat3,mat4
end

local playerStats={
	defaultAtkTime=2,
	defaultWalkTime=4,
	walkSpeed=1,
	atkSpeed=1,
	health=100,
	atk=10,
	crit=0,
	critDmg=2,
	blockChance=0,
	gameSpeed=1,
	prestigeBonusScale=0.1,
	x2money=0,
	x5money=0,
	maxWave=1,
}
local enemyStats={
	defaultAtkTime=2,
	atkSpeed=0.8,
	baseHealth=4,
	healthScaling=7,
	atk=2.5,
	atkScaling=0.6,
	crit=0,
	critDmg=1,
	critDmgScaling=0.05,
}
local pAtkProg= 0
local function eventTest(playerStats, enemyStats)
	local player=playerStats
	local enemy=enemyStats
	local playerHp=player.health
	local enemyAttackProgress=0
	local enemyHp=enemy.baseHealth+enemy.healthScaling
	local i=0 --main wave
	local i2=-1 --subwave
	local time=0
	local eAtkProg=0
	
	while playerHp>0 do
		i=i+1
		for w = 5, 1, -1 do
			if playerHp>0 then
				enemyHp=enemy.baseHealth+enemy.healthScaling*i
				while enemyHp>0 do
					-- [[
					local pAtkTleft=(1-pAtkProg)/player.atkSpeed
					local eAtkTleft=(1-eAtkProg)/(enemy.atkSpeed+i*0.02)
					if pAtkTleft> eAtkTleft then
						pAtkProg=pAtkProg+(eAtkTleft/(enemy.atkSpeed+i*0.02))*player.atkSpeed
						eAtkProg=eAtkProg-1
						local dmg=math.max(1,round(enemy.atk+i*enemy.atkScaling))
						if 100*math.random()<=enemy.crit+i and enemy.crit+i>0 and enemy.critDmg+i*enemy.critDmgScaling>1 then dmg=round(dmg*(enemy.critDmg+enemy.critDmgScaling*i)) end
						if math.random()<=player.blockChance and player.blockChance>0 then dmg=0 end
						playerHp=playerHp-dmg
						time=time+enemy.defaultAtkTime*(eAtkTleft/(enemy.atkSpeed+i*0.02))
					else
						eAtkProg=eAtkProg+(pAtkTleft/player.atkSpeed)*(enemy.atkSpeed+i*0.02)
						pAtkProg=pAtkProg-1
						local dmg=player.atk
						if 100*math.random()<=player.crit and player.crit>0 then dmg=round(player.atk*(player.critDmg)) end
						enemyHp=enemyHp-dmg
						time=time+player.defaultAtkTime*(pAtkTleft/player.atkSpeed)
					end
				end
				time=time+(player.defaultWalkTime/player.walkSpeed)
			end
			if playerHp<1 and i2==-1 then
				i2=w
			end
		end
	end
	player.highestWave=i
	time=time/player.gameSpeed
	return {i,i2,time} --[["Died at Wave: "..i.."-"..i2.." within "..time.."seconds \n" ..--" with "..perfectRunChance.."% chance"..
	string.format("Gained:\n%i coins\n%i mat2\n%i mat3\n%i mat4",mat1, mat2, mat3, mat4)--]]
end

p,e = parseUpgrades(upgrades,upgradeInstructions,playerStats,enemyStats,prestigeCount,gemUp)
local function FullEventSim(p,e,runs)
	local eventRuns={}
	local avgDistance=0
	local avgTime=0
	local runCount=runs or 1000
	for i=1,runCount do
		eventRuns[i]= eventTest(p,e)
		avgDistance=(avgDistance + eventRuns[i][1]+1-(eventRuns[i][2]*0.2))
		avgTime=(avgTime + eventRuns[i][3])
	end
	table.sort(eventRuns,function(a,b) return a[1]+1-a[2]*0.2<b[1]+1-b[2]*0.2 end)
	avgDistance=avgDistance/runCount
	avgTime=avgTime/runCount
	--[[print("worst run:			"..table.concat(eventRuns[1],"	"))
	print("best run:			"..table.concat(eventRuns[runCount],"	"))
	print("average distance:	"..math.floor(avgDistance).."	"..5-(avgDistance%1)/0.2)
	print("average time:		"..avgTime)
	print(string.format("Avg. Material:		%i %i %i %i",calcMaterials(math.floor(avgDistance)-1)))	--]]
	return eventRuns, avgDistance, avgTime
end

local function printRunData(eventRuns,avgDistance,avgTime)
	local tab = "	"
	local runDataString="worst run:		%s\nbest run:		%s\nAvg. distance:	%s\naverage time:	%.2f\nAvg. Material:	%.2f %.2f %.2f %.2f\n"
	--local returnString = runDataString:format(table.concat(eventRuns[1],tab),table.concat(eventRuns[#eventRuns],tab),math.floor(avgDistance)..tab..5-(avgDistance%1)/0.2,avgTime,calcMaterials(math.floor(avgDistance)-1,p))
	local returnString = runDataString:format(string.format("%i-%i%s%.2f",eventRuns[1][1],eventRuns[1][2],tab,eventRuns[1][3]),string.format("%i-%i%s%.2f",eventRuns[#eventRuns][1],eventRuns[#eventRuns][2],tab,eventRuns[#eventRuns][3]),string.format("%i-%.2f",math.floor(avgDistance),5-((avgDistance)%1)*5),avgTime,calcMaterials(math.floor(avgDistance)-1,p))
	local returnString2=""
	local runTallyIndex=1
	local stupid_index = eventRuns[1][1]+1
	local stupid_tally_for_current_wave = 0
	local countedRuns={{eventRuns[1][1],eventRuns[1][2],1}}
	for i=2, #eventRuns do
		if countedRuns[runTallyIndex][1]==eventRuns[i][1] and countedRuns[runTallyIndex][2]==eventRuns[i][2] then
			countedRuns[runTallyIndex][3]=countedRuns[runTallyIndex][3]+1
		else
			if((countedRuns[1][1]==countedRuns[runTallyIndex][1] )or (countedRuns[runTallyIndex][1]==eventRuns[#eventRuns][1])) then
				returnString2=returnString2..string.format("%i-%i %6.1f%%\n",countedRuns[runTallyIndex][1],countedRuns[runTallyIndex][2],countedRuns[runTallyIndex][3]*100/#eventRuns)
			else
				stupid_tally_for_current_wave = stupid_tally_for_current_wave + countedRuns[runTallyIndex][3]
				if(not eventRuns[i+1] or(eventRuns[i+1][1]>stupid_index)) then
					returnString2=returnString2..string.format("%i %6.1f%%\n",countedRuns[runTallyIndex][1],stupid_tally_for_current_wave*100/#eventRuns)
					stupid_tally_for_current_wave=0
					if(eventRuns[i+1]) then
						stupid_index=eventRuns[i+1][1]
					end
				end
			end
			--returnString2:format(returnString2base,table.concat(countedRuns[runTallyIndex],tab))
			runTallyIndex = runTallyIndex + 1
			countedRuns[runTallyIndex]={eventRuns[i][1],eventRuns[i][2],1}
			--print(returnString2)
		end
	end
	returnString2=returnString2..string.format("%i-%i %6.1f%%\n",countedRuns[runTallyIndex][1],countedRuns[runTallyIndex][2],countedRuns[runTallyIndex][3]*100/#eventRuns)
	return returnString, returnString2
end

local function UpgradePrice(price,levels)
	local totalCost=0
	local p=price or 0
	local l=levels
	for i = 1, l do
		totalCost=totalCost+round(p*(1.25^(i-1)))
	end
	return totalCost
end
local function totalUpgradeCost(upgrades,upgradeCosts)
	local totalCosts={0,0,0,0}
	for i=1, #upgrades do
		local upgradeTier=upgrades[i]
		for j=1, #upgradeTier do
			totalCosts[i]=totalCosts[i]+UpgradePrice(upgradeCosts[i][j],upgrades[i][j])
			--print(totalCosts[i])
		end
	end
	return totalCosts
end
--[[
print(string.format("%s\n%s",printRunData(FullEventSim(p,e,1000))))

print("hp: "..p.health)
print("atk: "..p.atk)
print("spd: "..p.atkSpeed)

local m= totalUpgradeCost(oldUpgrades,costs)
local n= totalUpgradeCost(upgrades,costs)
local tCosts={}
for i=1, #m do
	tCosts[i]=n[i]-m[i]
end
print("price for old upgrades:\t"..table.concat(m,","))
print("price for new upgrades:\t"..table.concat(n,","))
print("price difference:\t\t"..table.concat(tCosts,","))
--]]
	
function GiveResults()
	p,e = parseUpgrades(upgrades,upgradeInstructions,playerStats,enemyStats,prestigeCount,gemUp)
	return string.format("%s\n%s",printRunData(FullEventSim(p,e,1000))), totalUpgradeCost(oldUpgrades,costs), totalUpgradeCost(upgrades,costs)
end
function GiveCurrentCost()
	return totalUpgradeCost(upgrades,costs)
end
function get_highest_wave_killed_in_x_hits(player,enemy,hits)
	return math.floor((hits*player.atk-enemy.baseHealth)/enemy.healthScaling);
end
function avgEvent_short(playerStats, enemyStats)
	local player=playerStats
	local enemy=enemyStats
	local time = 0
	local max_wave = 1
	playerHp=player.health/(1-player.blockChance)
	remainder = 0
	ret1,ret2,ret3 = -1,0,0
	for j = 1, 10 do
		local wavesToTest = get_highest_wave_killed_in_x_hits(player,enemy,j)
		for i=max_wave,wavesToTest do
			if playerHp<=0 then break end
			local hits = remainder + j*5*(enemy.atkSpeed+i*0.02)/player.atkSpeed
			remainder = hits%1
			hits = math.floor(hits)
			local enemyAtk = math.max(1,round(enemy.atk+i*enemy.atkScaling))* (1+math.max(0,math.min(100,enemy.crit+i)/100*(enemy.critDmg+i*enemy.critDmgScaling-1)/100))
			playerHp = playerHp - math.max(0,hits*enemyAtk)
			if playerHp<=0 then --10 hits, 10 atk, remaining hp -44 -> 6 -> 3
				if ret1>-1 then break end
				local current_subwave = 5-math.floor((hits +math.floor(playerHp/enemyAtk))/hits*5)
				time = time + (i-max_wave+(6-current_subwave)/5) * 5 * (j*player.defaultAtkTime/player.atkSpeed+player.defaultWalkTime/player.walkSpeed)/player.gameSpeed
				ret1,ret2,ret3 = i,current_subwave,time
				break
			end
		end
		if playerHp<=0 then break end
		time = time + (wavesToTest-max_wave+1) * 5 * (j*player.defaultAtkTime/player.atkSpeed+player.defaultWalkTime/player.walkSpeed)/player.gameSpeed
		max_wave = wavesToTest +1
	end
	return ret1,ret2,ret3
end
function GiveApproxWithUpgraded(i,j)
	upgrades[i][j] = upgrades[i][j]+1
	p,e = parseUpgrades(upgrades,upgradeInstructions,playerStats,enemyStats,prestigeCount,gemUp)
	upgrades[i][j] = upgrades[i][j]-1
	ret1,ret2,ret3=avgEvent_short(p, e)
	return ret1,ret2,ret3
end