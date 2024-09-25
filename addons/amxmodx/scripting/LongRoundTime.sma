/* CS Hack Sample Plugin
*
* by Damaged Soul (thanks to BlueRaja for the idea)
*
* This file is provided as is (no warranties).
*/

#include <amxmodx>
#include <cshack>

public plugin_init() {
	register_plugin("CS Hack Sample", "1.00", "Damaged Soul")
}

public plugin_cfg() {
	long_roundtime()
}

// Set mp_roundtime ro 500 (Just for the heck of it it)
long_roundtime() {
	cs_set_roundtime_max(500.0)
	server_cmd("mp_roundtime 30.0")
}
