AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "cl_postprocess.lua" )

include( 'shared.lua' )

function GM:EntitytakeDamage( ent, inflictor, attacker, amount )
    if ( ent:IsPlayer() ) then
        ent:OnTakeDamage( inflictor, attacker, amount )
    end
end

function GM:Initialize()
    self.BaseClass:Initialize()
end

function GM:InitPostEntity()
end

function GM:PlayerInitialSpawn( pl )
    self.BaseClass:PlayerInitialSpawn( pl )
end

function GM:PlayerSpawn( pl )
    self.BaseClass:PlayerSpawn( pl )
    -- pl:GMDM_Extinguish()

    // Make the jump height a bit higher
    pl:SetGravity( 0.75 )

    // Set the player's speed
    GAMEMODE:SetPlayerSpeed( pl, 500, 200 )
end

function GM:DoPlayerDeath( pl, attacker, dmginfo )
    MsgAll( "Killer Damange: "..dmginfo:GetDamange().."\n" )
    MsgAll( "Was Explosion?: "..tostring(dmginfo:IsExplosionDamage()).."\n" )
    MsgAll( "Was Bullet?: "..tostring(dmginfo:IsBulletDamage()).."\n\n" )

    if ( pl:GetFireTime() > 0 ) then
        pl:GMDM_Extinguish()
        pl:DoFireDeath( attacker )
    elseif ( dmginfo:GetDamage() > 20 ) then
        pl:Gib( dmginfo )
    else
        pl:CreateRagdoll()
    end

    pl:AddDeaths( 1 )

    if ( attacker:IsValid() && attacker:IsPlayer() ) then
        if ( attacker == pl ) then
            attacker:AddFlags( -1 )
        else
            pl:DropSouls()
            attacker:AddSouls( 1 )
            attacker:AddFlags( 1 )
        end
    end

    // Drop fire on the floor if we were on fire?
end

function GM:PlayerLoadout( pl )
    pl:GiveAmmo( 54, "Pistol", true )
    pl:GiveAmmo( 8, "buckshot", true )

    pl:Give( "gmdm_pistol" )
    pl:Give( "weapon_crowbar" )

    pl:SelectWeapon( "gmdm_pistol" )

    -- pl:SetCustomAmmo( "tripmine", 0 )
    -- pl:SetCustomAmmo( "egonenergy", 0 )
end