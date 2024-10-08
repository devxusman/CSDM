#include <amxmodx>

/*---------------EDIT ME------------------*/
#define ADMIN_CHECK ADMIN_RESERVATION

static const COLOR[] = "^x04" //green
static const CONTACT[] = "fb.com/cs.pro.usman"
/*----------------------------------------*/

new maxplayers
new gmsgSayText

public plugin_init() {
	register_plugin("[CSDM] VIP Check", "1.51", "TSM - Mr.Pro")
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say", "handle_say")
	register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER)
}

public handle_say(id) {
	new said[192]
	read_args(said,192)
	if( ( containi(said, "vipsonline") != -1 && containi(said, "vips") != -1 ) || contain(said, "/vips") != -1 )
		set_task(0.1,"print_viplist",id)
	return PLUGIN_CONTINUE
}

public print_viplist(user) 
{
	new adminnames[33][32]
	new message[256]
	new contactinfo[256], contact[112]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_CHECK)
				get_user_name(id, adminnames[count++], 31)

	len = format(message, 255, "%s VIPS ONLINE: ",COLOR)
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "%s ",COLOR)
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "No admins online.")
		print_message(user, message)
	}
	
	get_cvar_string("amx_contactinfo", contact, 63)
	if(contact[0])  {
		format(contactinfo, 111, "%s Contact Server OWNER TSM - Mr.Pro", COLOR, contact)
		print_message(user, contactinfo)
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}