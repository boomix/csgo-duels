void AFK_OnClientPutInServer(int client)
{
	b_isAFK[client] = true;
}

void AFK_MatchStarted(int client, int opponent)
{
	b_isAFK[client] 	= true;
	b_isAFK[opponent] 	= true;
}

//On some kind of action, set that the player is not afk anymore
public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVelocity[3], float fAngles[3], int &iWeapon) 
{
	if(b_isAFK[client]) {
		if(iButtons > 0) {
			
			//player has pressed some kind of button (w, s, d, a, r, mouse1, mouse2)
			b_isAFK[client] = false;
			PrintHintText(client, "");
		} else {
			
			float ang[3];
			GetClientEyeAngles(client, ang);
			
			//if first time setting
			int one = RoundFloat(fLastPos[client][0]);
			int two = RoundFloat(fLastPos[client][1]);
			int tree = RoundFloat(fLastPos[client][2]);
			
			//If not default coords
			if(one != 0 || two != 0 && tree != 0) {

				//player has moved mouse around
				if( fLastPos[client][0] != ang[0] || fLastPos[client][1] != ang[1] || fLastPos[client][2] != ang[2] )
				{
					b_isAFK[client] = false;
					PrintHintText(client, "");
					fLastPos[client] = ang;
				}
				
			} else {
				fLastPos[client] = ang;
			}
			
			
		}
		
		//Show message that the player is afk
		if(b_isAFK[client] && i_PlayerArena[client] == LOBBY)
			PrintHintText(client, "Your'e AFK, not searcing for enemies");
		
	}
	
	//Message that its searching for enemies
	if(!b_isAFK[client] && i_PlayerArena[client] == LOBBY)
		PrintHintText(client, "Searching for enemies..");
	else if(!b_isAFK[client])
		PrintHintText(client, "");
	
}

