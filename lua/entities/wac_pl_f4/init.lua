include("shared.lua")
AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent=ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*10)
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,2))
	ent.Owner=ply	
	self.Sounds=table.Copy(sndt)
	return ent
end

ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, -0.075, 0),
		Right = Vector(0, 0, 70), -- Rotate towards flying direction
		Top = Vector(0, 0, 0)
	},
	Lift = {
		Front = Vector(0, 0, 13.25), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.25)
	},
	Rail = Vector(1, 5, 20)
}

function ENT:CustomPhysicsUpdate(ph)
	if self.rotorRpm > 0.8 and self.rotorRpm < 0.89 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,1)
	elseif self.rotorRpm > 0.9 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,2)
	elseif self.rotorRpm < 0.8 and IsValid(self.TopRotorModel) then
		self.TopRotorModel:SetBodygroup(1,0)
	end
	
	local geardown,t1=self:LookupSequence("geardown")
	local gearup=self:LookupSequence("gearup")	
	local trace=util.QuickTrace(self:LocalToWorld(Vector(0,0,62)), self:LocalToWorld(Vector(0,0,50)), {self, self.Wheels[1], self.Wheels[2], self.Wheels[3], self.TopRotor})
	local phys=self:GetPhysicsObject()
	if IsValid(phys) and not self.disabled then
		if self.upMul>0.9 and self.rotorRpm>0.8 and phys:GetVelocity():Length() > 2000 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() != gearup then
			self:ResetSequence(gearup) 
			self:SetPlaybackRate(1.0)
			self:SetBodygroup(1,1)
			for i=1,3 do 
				self.Wheels[i]:SetRenderMode(RENDERMODE_TRANSALPHA)
				self.Wheels[i]:SetColor(Color(255,255,255,0))
				self.Wheels[i]:SetSolid(SOLID_NONE)
			end
		elseif self.upMul<0.6 and trace.HitPos:Distance( self:LocalToWorld(Vector(0,0,62)) ) > 50  and self:GetSequence() == gearup then
			self:ResetSequence(geardown)
			self:SetPlaybackRate(1.0)

			timer.Simple(t1,function()
				if self.Wheels then
					for i=1,3 do 
						self.Wheels[i]:SetRenderMode(RENDERMODE_NORMAL)
						self.Wheels[i]:SetColor(Color(255,255,255,255))
						self.Wheels[i]:SetSolid(SOLID_VPHYSICS)
					end
					self:SetBodygroup(1,0)
				end
			end)
		end
	end
end