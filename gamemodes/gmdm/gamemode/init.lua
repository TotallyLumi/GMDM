AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "cl_postprocess.lua" )

include( 'shared.lua' )

function GM:SetFireTime( pl, add )
    pl:SetNetworkedFloat( "FireTime", CurTime() + add)
end

function GM:SetVar( pl, name, value )
    if not IsValid( pl ) then return end

    if IsEntity( value ) then
        pl:SetNWEntity( name, value )
    elseif isnumber( value ) then
        pl:SetNWFloat( name, value )
    elseif isstring( value ) then
        pl:SetNWString( name, value )
    elseif isbool( value ) then
        pl:SetNWBool( name, value )
    else
        print("Warning: Attempted to set NW var with unsupported type: " .. type( value ) )
    end

    -- pl:SetNetworkedFloat( name, value )
end

function GM:GMDM_Extinguish( pl )
    if not IsValid( pl ) then return end

    self:SetFireTime( pl, -1 )
    self:SetVar( pl, "FireAttacker", NULL )
end

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
    self:GMDM_Extinguish( pl )

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