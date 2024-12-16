--
-- Register DeepCultivator for LS 25
--
-- Glowins Modschmiede 
--

local specName = g_currentModName..".CultivatorSettings"

if g_specializationManager:getSpecializationByName("CultivatorSettings") == nil then
  	g_specializationManager:addSpecialization("CultivatorSettings", "CultivatorSettings", g_currentModDirectory.."cultivatorSettings.lua", nil)
  	dbgprint("Specialization 'CultivatorSettings' added", 2)
end

for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
    if
    		SpecializationUtil.hasSpecialization(Cultivator, typeEntry.specializations) 
    then
     	g_vehicleTypeManager:addSpecialization(typeName, specName)
		dbgprint(specName.." registered for "..typeName)
    end
end

