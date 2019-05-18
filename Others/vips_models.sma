#include <amxmodx>
#include <amxmisc>
#include <cstrike>

public plugin_init() {
        register_plugin("AMX Admin Model", "1.1.1", "whitemike")
        register_event("ResetHUD", "resetModel", "b")
        return PLUGIN_CONTINUE
}

public plugin_precache() {
        precache_model("models/player/ag_ct/ag_ct.mdl")
        precache_model("models/player/ag_tt/ag_tt.mdl")

        return PLUGIN_CONTINUE
}

public resetModel(id, level, cid) 
{
	if(get_user_flags(id) & ADMIN_LEVEL_H) 
	{
		new CsTeams:userTeam = cs_get_user_team(id)
		
		if (userTeam == CS_TEAM_T) 
		{
			cs_set_user_model(id, "ag_tt")
		}	
		else if(userTeam == CS_TEAM_CT) 
		{
			cs_set_user_model(id, "ag_ct")
		}
		else 
		{
            cs_reset_user_model(id)
        }
	}

    	return PLUGIN_CONTINUE
}
