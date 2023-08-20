local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Automatically de-priv certain admin accounts on join to minimise account hijacking
dofile(modpath.."/admin_priv_deregister.lua")

dofile(modpath.."/userlimit.lua")
