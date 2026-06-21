
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

// Global to track the number of active fires
NUM_FIRES 		= 0
MAX_NUM_FIRES 	= 128

function ENT:RemoveMe()

	if (!self.Entity) then return end
	if (self.Entity == NULL) then return end

	self.Entity:Remove()

end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:DrawShadow( false )

	// Make the bbox short so we can jump over it
	// Note that we need a physics object to make it call triggers
	self.Entity:SetCollisionBounds( Vector( -32, -32, -32 ), Vector( 32, 32, 0 ) )
	self.Entity:PhysicsInitBox( Vector( -32, -32, -32 ), Vector( 32, 32, 0 ) )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableCollisions( false )		
	end
	
	local Time = math.Rand( 9, 10 )
	timer.Simple( Time, function()
		if IsValid( self ) then
			self:RemoveMe()
		end
	end)
	
	self.Entity:SetNetworkedFloat( 0, CurTime() + Time )
	
	NUM_FIRES = NUM_FIRES + 1
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self.Entity:SetTrigger( true )
	self.Entity:SetNotSolid( true )
	
end

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
	NUM_FIRES = NUM_FIRES - 1
end

function ENT:SetFireTime( pl, add )
	if not IsValid( pl ) then
		return
	end
    pl:SetNetworkedFloat( "FireTime", CurTime() + add)
end

function ENT:SetVar( pl, name, value )
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

function ENT:GMDM_Ignite( attacker )
	if not IsValid( attacker ) then
		print( "DEBUG: GMDM_Ignite was called, but attacker is invalid/nil!" )
		debug.Trace()
		return 
	end

	self:SetFireTime( attacker, 5 )
	self:SetVar( "FireAttacker", attacker )
end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )

	if (!entity:IsPlayer()) then return end
	
	self:GMDM_Ignite( self.Entity:GetOwner() )

end

include('shared.lua')