-- Automatically de-priv certain accounts on login to reduce account hijacking , eg: "AussieForks" as a server-admin account
local depriv_accounts = {}
local base_privs = {}
local huds = {}

local account_list = minetest.settings:get("aussieforks_custom.depriv_account_list")
local depriv_priv_list = minetest.settings:get("aussieforks_custom.depriv_priv_list")

if not account_list or account_list == "" then
	return
end

account_list = account_list:split(",")
if #account_list == 0 then
	return
end
for _, name in pairs(account_list) do
	depriv_accounts[name] = true
end

for _, priv in pairs(depriv_priv_list:split(",")) do
	base_privs[priv] = true
end


local function update_hud(pname)
	if not depriv_accounts[pname] then
		return
	end
	local playerRef = minetest.get_player_by_name(pname)
	local priv_list = {}
	for priv, _ in pairs(minetest.get_player_privs(pname)) do
		table.insert(priv_list, priv)
	end
	if priv_list[1] == nil then
		priv_list[1] = "No Privs"
	end
	playerRef:hud_change(huds[pname].priv_list, "text", "== PRIVS ==\n" .. table.concat(priv_list, "\n") .. "\n== PRIVS ==")
end

local function on_joinplayer(playerRef, last_login)
	local pname = playerRef:get_player_name()
	if not pname or pname == "" or not depriv_accounts[pname] then
		return
	end
	local ip = minetest.get_player_ip(pname)
	local last_login_readable = os.date("!%Y-%m-%dT%H:%M:%SZ", last_login)
	minetest.log("warning" ,"[AussieForks Custom] Admin account " .. pname .. " joined from ip " .. ip)
	minetest.log("warning", "[AussieForks Custom] Last login: " .. last_login_readable)
	minetest.set_player_privs(pname, base_privs)
	
	local priv_list = {}
	for priv in pairs(minetest.get_player_privs(pname)) do
		table.insert(priv_list, priv)
	end
	if priv_list[1] == nil then
		priv_list[1] = "No Privs"
	end
	
	minetest.chat_send_player(pname, minetest.colorize("#FF0000", "CAUTION: User is logged in as admin account"))
	minetest.chat_send_player(pname, minetest.colorize("#FF0000", "Privs will be reset to " .. depriv_priv_list .. " on next login"))
	minetest.chat_send_player(pname, "Admin Player: " .. pname)
	minetest.chat_send_player(pname, "Current Privs: " .. table.concat(priv_list, ", "))
	minetest.chat_send_player(pname, "Previous Login: " .. last_login_readable .. " from " .. ip)
	

	huds[pname] = {
		['priv_list'] = playerRef:hud_add({
			hud_elem_type	= "text",
			position		= {x = 0, y = 0.5},
			direction		= 1,
			text			= "",
			offset 			= {x = 0, y = 0},
			alignment		= {x = 1, y = 0},
			scale			= {x = 100, y = 100},
			number 			= 0xFFFFFF
		})
	}
	
	update_hud(pname)
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_priv_grant(update_hud)
minetest.register_on_priv_revoke(update_hud)
