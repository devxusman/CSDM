/**
 * csdm_ffa.sma
 * Allows for Counter-Strike to be played as DeathMatch.
 *
 * CSDM FFA - Sets free-for-all mode on other plugins.
 *
 * (C)2003-2006 David "BAILOPAN" Anderson
 *
 * Give credit where due.
 * Share the source - it sets you free
 * http://www.opensource.org/
 * http://www.gnu.org/
 *
 *
 *
 * Modification from ReCSDM Team (C) 2016
 * http://www.dedicated-server.ru/
 *
 */

#include <amxmodx>
#include <amxmisc>
#include <csdm>

#pragma semicolon 1

#pragma library csdm_main

#if AMXX_VERSION_NUM < 183
	#define send_client_cmd client_cmd
#else
	#define send_client_cmd amxclient_cmd
#endif

new PLUGIN[] = "ReCSDM FFA";
new VERSION[] = CSDM_VERSION;
new AUTHOR[] = "ReCSDM Team";

new ACCESS = ADMIN_LEVEL_A;
new const g_sFireInTheHole[] = "#Fire_in_the_hole";
new const g_sFireInTheHoleSound[] = "%!MRAD_FIREINHOLE";

new bool:g_MainPlugin = true;
new bool:g_PluginInited = false;
new bool:g_Enabled = false;
new bool:g_hideradar = false;
new g_SettingsMenu = 0;
new g_FfaSettMenu = 0;
new g_ItemsInMenuNr = 0;
new g_PageSettMenu = 0;

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const module[])
{
	if (equali(module, "csdm_main")) {
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public native_filter(const name[], index, trap)
{
	if (!trap) {
		return PLUGIN_HANDLED;
	}	
	return PLUGIN_CONTINUE;
}

public csdm_Init(const version[])
{
	if (version[0] == 0) {
		set_fail_state("ReCSDM failed to load.");
		return;
	}
}

public csdm_CfgInit()
{	
	csdm_reg_cfg("ffa", "read_cfg");
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd("csdm_ffa_enable", "csdm_ffa_enable", ACCESS, "Enabled FFA");
	register_concmd("csdm_ffa_disable", "csdm_ffa_disable", ACCESS, "Diable FFA");
	register_concmd("csdm_ffa_ctrl", "csdm_ffa_ctrl", ACCESS, "Control FFA");
	register_concmd("csdm_radar_ctrl", "csdm_radar_ctrl", ACCESS, "Radar Control");

	register_clcmd("csdm_ffa_sett_menu", "csdm_ffa_sett_menu", ACCESS, "Setting Menu FFA");

	register_event("ResetHUD", "eventResetHud", "be");

	register_message(get_user_msgid("TextMsg"), "msgTextMsg");
	register_message(get_user_msgid("SendAudio"), "msgSendAudio");

	g_MainPlugin = module_exists("csdm_main") ? true : false;

	if (g_MainPlugin)
	{
		g_SettingsMenu = csdm_settings_menu();
		g_ItemsInMenuNr = menu_items(g_SettingsMenu);
		g_PageSettMenu = g_ItemsInMenuNr / 7;

		menu_additem(g_SettingsMenu, "Settings FFA", "csdm_ffa_sett_menu", ACCESS);

		g_FfaSettMenu = menu_create("Seting Menu FFA", "use_csdm_ffa_menu");

		if (g_FfaSettMenu)
		{
			new cb_ffa = menu_makecallback("hook_ffa_menu");
			menu_additem(g_FfaSettMenu, "FFA [On/Off]", "csdm_ffa_ctrl", ADMIN_LEVEL_A, cb_ffa);

			new cb_radar = menu_makecallback("hook_radar_menu");
			menu_additem(g_FfaSettMenu, "Radar [Show/Hide]", "csdm_radar_ctrl", ADMIN_LEVEL_A, cb_radar);
			menu_additem(g_FfaSettMenu, "Back", "csdm_sett_back", 0, -1);
		}
	}

	set_task(4.0, "enforce_ffa");

	register_message(get_user_msgid("Radar"), "Radar_Hook");

	g_PluginInited = true;
}

public csdm_StateChange(csdm_state)
{
	if (g_Enabled)
	{
		new value = csdm_active() ? 1:0;

		if(value)
		{
			csdm_set_ffa(1);

			if (g_hideradar) {
				client_cmd(0, "hideradar");
			}
		}

	} else if (g_PluginInited) {
		csdm_set_ffa(0);
		client_cmd(0, "drawradar");
	}
}

// block "fire in the hole" msg
public msgTextMsg(msg_id, msg_dest, msg_entity)
{
	if (csdm_active() && csdm_get_ffa() && get_msg_args() == 5 && get_msg_argtype(5) == ARG_STRING)
	{
		new sTemp[sizeof(g_sFireInTheHole)];
		get_msg_arg_string(5, sTemp, sizeof(sTemp) - 1);

		if(equal(sTemp, g_sFireInTheHole)) {
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

// block "fire in the hole" radio
public msgSendAudio()
{
	if(csdm_active() && csdm_get_ffa())
	{
		new sTemp[sizeof(g_sFireInTheHoleSound)];
		get_msg_arg_string(2, sTemp, sizeof(sTemp) - 1);

		if(equali(sTemp, g_sFireInTheHoleSound)) {
			return PLUGIN_HANDLED;
		}
	} 

	return PLUGIN_CONTINUE;
}

public eventResetHud(id)
{
	if (g_Enabled && g_hideradar && csdm_active()) {
		client_cmd(id, "hideradar");
	}

	return PLUGIN_CONTINUE;
}

public Radar_Hook(msg_id, msg_dest, msg_entity)
{
	if (csdm_active() && csdm_get_ffa()) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public enforce_ffa()
{
	if (csdm_active() && csdm_get_ffa())
	{
		if (g_hideradar) {
			client_cmd(0, "hideradar");
		}

	} else if (g_hideradar) {
		client_cmd(0, "drawradar");
	}
}

public csdm_ffa_sett_menu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	menu_display(id, g_FfaSettMenu, 0);

	return PLUGIN_HANDLED;
}

public use_csdm_ffa_menu(id, menu, item)
{
	if (item < 0)
		return PLUGIN_CONTINUE;

	new command[24], paccess, call;

	if (!menu_item_getinfo(g_FfaSettMenu, item, paccess, command, charsmax(command), _, 0, call)) {
		log_amx("Error: csdm_menu_item() failed (menu %d) (page %d) (item %d)", g_FfaSettMenu, 0, item);
		return PLUGIN_HANDLED;
	}

	if (paccess && !(get_user_flags(id) & paccess)) {
		client_print(id, print_chat, "You Don't Have Permission To This Option.");
		return PLUGIN_HANDLED;
	}

	if ((equali(command,"csdm_ffa_ctrl")) || (equali(command,"csdm_radar_ctrl"))) {
		send_client_cmd(id, command);
		menu_display(id, g_FfaSettMenu, 0);
		return PLUGIN_HANDLED;

	} else if (equali(command,"csdm_sett_back")) {
		menu_display(id, g_SettingsMenu, g_PageSettMenu);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public csdm_ffa_ctrl(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	g_Enabled = (g_Enabled ? false : true);
	csdm_set_ffa(g_Enabled ? 1 : 0);

	client_print(id, print_chat, "Mode FFA %s.", g_Enabled ? "Enabled" : "Disabled");

	if (csdm_active() && csdm_get_ffa())
	{
		if (g_hideradar) {
			client_cmd(0, "hideradar");
		}

	} else if (g_hideradar) {
		client_cmd(0, "drawradar");
	}

	csdm_write_cfg(id, "ffa", "enabled", g_Enabled ? "1" : "0");

	menu_display(id, g_FfaSettMenu, 0);

	return PLUGIN_HANDLED;
}

public csdm_radar_ctrl(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	g_hideradar = (g_hideradar ? false : true);

	client_print(id, print_chat, "Mode %s.", g_hideradar ? "Hidden" : "Shown");

	if (csdm_active() && csdm_get_ffa())
	{
		if (g_hideradar) {
			client_cmd(0, "hideradar");
		} else {
			client_cmd(0, "drawradar");
		}
	}

	csdm_write_cfg(id, "ffa", "radar_disable", g_hideradar ? "1" : "0");

	menu_display(id, g_FfaSettMenu, 0);

	return PLUGIN_HANDLED;
}

public hook_ffa_menu(player, menu, item)
{
	new paccess, command[24], call;

	menu_item_getinfo(menu, item, paccess, command, charsmax(command), _, 0, call);

	if (equali(command, "csdm_ffa_ctrl"))
	{
		if (!g_Enabled) {
			menu_item_setname(menu, item, "FFA Mode Off");
		} else {
			menu_item_setname(menu, item, "FFA Mode Enabled");
		}
	}
}

public hook_radar_menu(player, menu, item)
{
	new paccess, command[24], call;

	menu_item_getinfo(menu, item, paccess, command, charsmax(command), _, 0, call);

	if (equali(command, "csdm_radar_ctrl"))
	{
		if (!g_hideradar) {
			menu_item_setname(menu, item, "Radar Shown");
		} else {
			menu_item_setname(menu, item, "The Radar Is Hidden");
		}
	}
}

public csdm_ffa_enable(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	csdm_set_ffa(1);
	g_Enabled = true;

	client_print(id, print_chat, "FFA Mode Enabled.");

	if (g_hideradar) {
		client_cmd(0, "hideradar");
	}

	return PLUGIN_HANDLED;
}

public csdm_ffa_disable(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) {
		return PLUGIN_HANDLED;
	}

	csdm_set_ffa(0);
	g_Enabled = false;

	client_print(id, print_chat, "FFA Mode Off.");

	if (g_hideradar) {
		client_cmd(0, "drawradar");
	}

	return PLUGIN_HANDLED;
}

public read_cfg(readAction, line[], section[])
{
	if (readAction == CFG_READ)
	{
		new setting[24], sign[3], value[32];

		parse(line, setting, charsmax(setting), sign, charsmax(sign), value, charsmax(value));

		if (equali(setting, "enabled"))
		{
			csdm_set_ffa(str_to_num(value));
			g_Enabled = (str_to_num(value) ? true : false);
		}
		else if (equali(setting, "radar_disable")) {
			g_hideradar = (str_to_num(value) ? true : false);
		}
	}
}