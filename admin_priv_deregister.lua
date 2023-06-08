-- Automatically de-priv certain accounts on login to reduce account hijacking , eg: "AussieForks" as a server-admin account
local depriv_accounts = {}
local base_priv_list = {}
local huds = {}

local setting_list = minetest.settings:get("aussieforks_custom.depriv_account_list")
local depriv_priv_list = minetest.settings:get("aussieforks_custom.depriv_priv_list")
if setting_list and setting_list ~= "" then
	for name in setting_list:gmatch("%S+") do
		depriv_accounts[name] = true
	end
end


if depriv_accounts[1] then
	if depriv_priv_list and depriv_priv_list ~= "" then
		for priv in depriv_priv_list:gmatch("%S+") do
			base_priv_list[priv] = true
		end
	end
	
	minetest.register_on_joinplayer(function(playerRef, last_login)
		local pname = playerRef:get_player_name()
		if pname and pname ~= "" and depriv_accounts[pname] then
			local ip = minetest.get_player_ip(pname)
			local last_login_readable = os.date("!%Y-%m-%dT%H:%M:%SZ", last_login)
			minetest.log("warning","[AussieForks Custom] Admin account "..pname.." joined from ip "..ip)
			minetest.log("warning","[AussieForks Custom] Last login: "..last_login_readable)
			minetest.set_player_privs(pname,base_priv_list)
			
			local priv_list = {}
			for priv in pairs(minetest.get_player_privs(pname)) do
				table.insert(priv_list, priv)
			end
			if priv_list[1] == nil then
				priv_list[1] = "No Privs"
			end
			
			minetest.chat_send_player(pname, minetest.colorize("#FF0000", "CAUTION: User is logged in as admin account"))
			minetest.chat_send_player(pname, minetest.colorize("#FF0000", "Privs will be reset to "..depriv_priv_list.." on next login"))
			minetest.chat_send_player(pname, "Admin Player: "..pname)
			minetest.chat_send_player(pname, "Current Privs: "..table.concat(priv_list, ", "))
			minetest.chat_send_player(pname, "Previous Login: "..last_login_readable.." from "..ip)
			

			huds[pname] = {
				['priv_list'] = playerRef:hud_add({
					hud_elem_type	= "text",
					position		= {x = 0, y = 0.5},
					direction		= 1,
					text			= "== PRIVS ==\n"..table.concat(priv_list, "\n").."\n== PRIVS ==",
					offset 			= {x = 0, y = 0},
					alignment		= {x = 1, y = 0},
					scale			= {x = 100, y = 100},
					number 			= 0xFFFFFF
				})
			}
		end
	end)

	local function update_hud(pname, updater, priv)
		if depriv_accounts[pname] and updater ~= nil then
			local playerRef = minetest.get_player_by_name(pname)
			local priv_list = {}
			for priv, _ in pairs(minetest.get_player_privs(pname)) do
				table.insert(priv_list, priv)
			end
			if priv_list[1] == nil then
				priv_list[1] = "No Privs"
			end
			playerRef:hud_change(huds[pname].priv_list, "text", "== PRIVS ==\n"..table.concat(priv_list, "\n").."\n== PRIVS ==")
		end
	end

	minetest.register_on_priv_grant(update_hud)
	minetest.register_on_priv_revoke(update_hud)
end