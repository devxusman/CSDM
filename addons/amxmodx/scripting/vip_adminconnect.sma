#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <WPMGPrintChatColor>

#define PLUGIN "ADMIN & VIP CONNECT"
#define VERSION "1.0"
#define AUTHOR "TSM - Mr.Pro"


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

}


public client_putinserver(id) {
	new name[32]
	get_user_name(id, name, 31)
    
	if(get_user_flags(id) & ADMIN_LEVEL_H) {
		PrintChatColor(0, PRINT_COLOR_RED, "^4[VIP] ^1Player ^4%s ^1Connected!", name)
		set_dhudmessage(0, 255, 255, 0.03, 0.75, 2, 6.0, 3.0)
		show_dhudmessage(id, "VIP Player %s Connected!", name)
	}else{
	if(get_user_flags(id) & ADMIN_KICK) {
		PrintChatColor(0, PRINT_COLOR_RED, "^4[ADMIN + VIP] ^1Player ^4%s ^1Connected!", name)
		set_dhudmessage(0, 255, 255, 0.03, 0.75, 2, 6.0, 3.0)
		show_dhudmessage(id, "ADMIN + VIP Player %s Connected!", name)
		}
	}
}