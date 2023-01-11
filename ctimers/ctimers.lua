addon.name      = "CTimers";
addon.author    = "Shinzaku";
addon.version   = "1.0";
addon.desc      = "Simple custom timer functionality";
addon.link      = "https://github.com/Shinzaku/Ashita4-Addons/ctimers";

require "common";
local fonts = require("fonts");

local allTimers = {};
local globalTimer = 0;
local globalDelay = 1;

local fontSettings = T{
    visible = true,
    color = 0xFFFFFFFF,
    font_family = "Tahoma",
    font_height = 11,
    position_x = 50,
    position_y = 100,
};
local fontTimer = fonts.new(fontSettings);
fontTimer.background.color = 0xCC000000;
fontTimer.background.visible = true;

ashita.events.register("command", "command_callback1", function (e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= "/ctimers") then
        return;
    else
        e.blocked = true;
        local cmd = args[2];

        if (cmd == "add") then
			if (args[3] == nil or args[4] == nil or args[5] == nil or args[6] == nil) then
				PPrint("Unable to create timer; Missing parameters (Need H M S)");
			else
				local h = tonumber(args[4]);
				local m = tonumber(args[5]);
				local s = tonumber(args[6]);
				local totaltime = (h * 3600) + (m * 60) + s;
				CreateNewTimer(args[3], totaltime);
			end;
		elseif (cmd == "del") then
			if (args[3] == nil) then
				PPrint("Missing timer label in arguments");
			else
				for i=1,#allTimers do
					if (allTimers[i].label == args[3]) then
						allTimers[i].time = 0;
                        PPrint("Clearing timer");
                        return;
					end;
				end;

                PPrint("No timer found with that label");
			end;
		end;
    end
end);

ashita.events.register("unload", "unload_callback1", function ()
    fontTimer:destroy();
end);

ashita.events.register("d3d_present", "present_cb", function ()
	local cleanupList = {};
	if  (os.time() >= (globalTimer + globalDelay)) then
		globalTimer = os.time();

        for i,v in pairs(allTimers) do
            v.time = v.time - 1;
            if (v.time <= 0) then
                table.insert(cleanupList, v.id);
            end
        end
	end;

	-- Update timer display
    local strOut = "";
    for i,v in pairs(allTimers) do
        if (v.time >= 0) then
            local h = v.time / 3600;
            local m = (v.time % 3600) / 60;
            local s = ((v.time % 3600) % 60);
            strOut = strOut .. string.format("%s> %02d:%02d:%02d\n", v.label, h, m, s);
        end
    end
    fontTimer.text = strOut:sub(1, #strOut - 1);

	if (#cleanupList > 0) then
		for i=1,#cleanupList do
			local indexToRemove = 0;
			for x=1,#allTimers do
				if (allTimers[x].id == cleanupList[i]) then
					indexToRemove = x;
				end;
			end;

			table.remove(allTimers, indexToRemove);
		end;

        cleanupList = {};
	end;
end);

function CreateNewTimer(txtName, maxTime)
	table.insert(allTimers, { id = txtName .. os.time(), label = txtName, time = maxTime });
end;

function PPrint(txt)
    print(string.format("[\30\08CTimers\30\01] %s", txt));
end