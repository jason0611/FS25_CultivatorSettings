--
-- CultivatorSettings for LS 25
--
-- Glowins Modschmiede

CultivatorSettings = {}

if CultivatorSettings.MOD_NAME == nil then CultivatorSettings.MOD_NAME = g_currentModName end
if CultivatorSettings.PATH_NAME == nil then CultivatorSettings.PATH_NAME = g_currentModDirectory end
CultivatorSettings.MODSETTINGSDIR = g_currentModSettingsDirectory

source(g_currentModDirectory.."tools/gmsDebug.lua")
GMSDebug:init(CultivatorSettings.MOD_NAME, true, 1)
GMSDebug:enableConsoleCommands("csDebug")

-- Standards / Basics
function CultivatorSettings.prerequisitesPresent(specializations)
	return true
end

-- create configuration 
function CultivatorSettings.getConfigurationsFromXML(self, superfunc, xmlFile, baseXMLName, baseDir, customEnvironment, isMod, storeItem)
    local configurations, defaultConfigurationIds = superfunc(self, xmlFile, baseXMLName, baseDir, customEnvironment, isMod, storeItem)
	dbgprint("getConfigurationsFromXML : Kat: "..storeItem.categoryName.." / ".."Name: "..storeItem.xmlFilename, 2)

	local category = storeItem.categoryName
	if configurations ~= nil and category == "CULTIVATORS" then
		local csConfigFile = XMLFile.load("cultivatorSettingsConfig", CultivatorSettings.PATH_NAME.."cultivatorSettingsConfig.xml", xmlFile.schema)
		
		if csConfigFile ~= nil then
			local allConfigs = self:getConfigurations()
			local csConfig = allConfigs["CultivatorSettings"]
			
			dbgprint("addCSconfig : loading config from xml", 2)
			dbgprint_r(csConfig, 4, 1)
			
			if csConfig ~= nil then
				local configItems = {}
				local i = 0
				while true do
					dbgprint("getConfigurationsFromXML : step "..tostring(i+1), 4)
					local xmlKey = string.format(csConfig.configurationKey .."(%d)", i)
					if not csConfigFile:hasProperty(xmlKey) or i > 4 then
						dbgprint("getConfigurationsFromXML : exiting...", 4)
						break
					end
					
					dbgprint("getConfigurationsFromXML : loading item at "..tostring(xmlKey), 4)
					local configItem = csConfig.itemClass.new(csConfig.name)
					configItem:setIndex(#configItems + 1)
					if configItem:loadFromXML(csConfigFile, csConfig.configurationsKey, xmlKey, baseDir, customEnvironment) then
						if i == 0 then
							configItem.name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_off")
							configItem.desc = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_off")
						elseif i == 1 then 
							configItem.name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_shallow")
							configItem.desc = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_shallow")
						elseif i == 2 then 
							configItem.name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_normal")
							configItem.desc = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_normal")
						elseif i == 3 then 
							configItem.name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_deep")
							configItem.desc = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_deep")
						elseif i == 4 then 
							configItem.name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_ISOBUS")
							configItem.desc = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_ISOBUS")
						end
						table.insert(configItems, configItem)
						dbgprint("getConfigurationsFromXML : item added:", 4)
						dbgprint_r(configItem, 4, 1)
					end
					i = i + 1
				end
				if #configItems > 0 then
					defaultConfigurationIds[csConfig.name] = ConfigurationUtil.getDefaultConfigIdFromItems(configItems)
					configurations[csConfig.name] = configItems
					dbgprint("getConfigurationsFromXML : configurations", 4)
					dbgprint_r(configItems, 4, 2)
				end
			end
			
			csConfigFile:delete()
		end
    	
    	dbgprint("getConfigurationsFromXML : Configuration CultivatorSettings added", 2)
    	dbgprint_r(configurations["CultivatorSettings"], 4)
	end
	
    return configurations, defaultConfigurationIds
end

function CultivatorSettings.initSpecialization()
	dbgprint("initSpecialization : start", 2)
	
    -- register schema
    local schemaSavegame = Vehicle.xmlSchemaSavegame
	local key = CultivatorSettings.MOD_NAME..".CultivatorSettings"
	schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?)."..key.."#config", "Cultivator configuration", 1)
	schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?)."..key.."#mode", "Cultivator setting", 1)
	dbgprint("initSpecialization: finished xmlSchemaSavegame registration process", 2)
	
	-- add configuration
	if g_vehicleConfigurationManager.configurations["CultivatorSettings"] == nil then
		g_vehicleConfigurationManager:addConfigurationType("CultivatorSettings", g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_configuration"), key, VehicleConfigurationItem)
	end
	ConfigurationUtil.getConfigurationsFromXML = Utils.overwrittenFunction(ConfigurationUtil.getConfigurationsFromXML, CultivatorSettings.getConfigurationsFromXML)
	dbgprint("initSpecialization : Configuration initialized", 1)
end

function CultivatorSettings.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "registerOverwrittenFunctions", CultivatorSettings)
 	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", CultivatorSettings)
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", CultivatorSettings)
end

function CultivatorSettings.registerOverwrittenFunctions(vehicleType)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getPowerMultiplier", CultivatorSettings.getPowerMultiplier)
end

function CultivatorSettings:onLoad(savegame)
	dbgprint("onLoad", 2)

	CultivatorSettings.isDedi = g_server ~= nil and g_currentMission.connectedToDedicatedServer
	
	-- Make Specialization easier accessible
	self.spec_CultivatorSettings = self["spec_"..CultivatorSettings.MOD_NAME..".CultivatorSettings"]
	
	local spec = self.spec_CultivatorSettings
	
	spec.dirtyFlag = self:getNextDirtyFlag()
	
	spec.mode = 3
	spec.lastMode = 0
	spec.config = 0	
	spec.reset = false
	spec.useWorkModes = false
	spec.workModeAdded = false
	spec.workModeMapping = {}
end

function CultivatorSettings:onPostLoad(savegame)
	dbgprint("onPostLoad: "..self:getFullName(), 2)
	local spec = self.spec_CultivatorSettings
	local spec_wm = self.spec_workMode
	
	-- Get configuration
	spec.config = self.configurations["CultivatorSettings"] or 0
	dbgprint("onPostLoad: spec.config = "..tostring(spec.config), 2)
	
	if savegame ~= nil then	
		dbgprint("onPostLoad : loading saved data", 2)
		local xmlFile = savegame.xmlFile
		local key = savegame.key .."."..CultivatorSettings.MOD_NAME..".CultivatorSettings"
		
		spec.config = xmlFile:getValue(key.."#config", spec.config)
		if spec.config == 5 then
			spec.mode = xmlFile:getValue(key.."#mode", spec.mode)
		end
		dbgprint("onPostLoad : Loaded data for "..self:getName(), 1)
	end
	
	-- if choosen by config, reset to original behaviour
	if spec.config == 1 then 
		spec.mode = 3
		spec.reset = true 
	end
	
	-- Set DC configuration if set by savegame
	if spec.config > 1 then 
		self.configurations["CultivatorSettings"] = spec.config
		if spec.config < 5 then
			spec.mode = spec.config
		end
	end 
	
	dbgprint("onPostLoad : Cultivator config: "..tostring(spec.config), 1)
	dbgprint("onPostLoad : Mode setting: "..tostring(spec.mode), 1)
	
	-- identify existing workModes and create mapping table, expand workmodes with subsoiler setting
	if spec_wm ~= nil and spec_wm.workModes ~= nil and spec_wm.workModes[1] ~= nil and spec_wm.workModes[2] ~= nil then
		for i = 1,2 do
			spec_wm.workModes[i].isSubsoiler = false
			if spec_wm.workModes[i].useDeepMode then
				-- add third workMode by cloning
				if spec_wm.workModes[3] == nil then
					spec.workModeAdded = true
					local cloneMode = {}
					for j, k in pairs(spec_wm.workModes[i]) do
						cloneMode[j] = k
					end
					spec_wm.workModes[3] = cloneMode
					spec_wm.workModes[3].forceScale = 1.5
					spec_wm.workModes[3].isSubsoiler = true
				end

				-- rename normal cultivator mode
				spec_wm.workModes[i].name = g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("normalModeShort")
				
				-- set mapping to spec.mode
				spec.workModeMapping[2] = i == 1 and 2 or 1
				spec.workModeMapping[3] = i
				spec.workModeMapping[4] = 3
				
				spec.useWorkModes = true
				spec_wm.stateMax = 3
				
				dbgprint_r(spec.workModeMapping, 2)
				dbgprint_r(spec_wm.workModes, 2)
			end
		end
	end
	if spec.useWorkModes then
		Cultivator.onWorkModeChanged = Utils.overwrittenFunction(Cultivator.onWorkModeChanged, CultivatorSettings.onWorkModeChanged)
	end
	
	dbgprint_r(self.configurations, 4, 2)
end

function CultivatorSettings:onWorkModeChanged(superfunc, workMode, oldWorkMode)
	superfunc(self, workMode, oldWorkMode)
	if workMode.isSubsoiler ~= nil then
        self.spec_cultivator.isSubsoiler = workMode.isSubsoiler
        self:updateCultivatorAIRequirements()
    end
end

function CultivatorSettings:saveToXMLFile(xmlFile, key, usedModNames)
	dbgprint("saveToXMLFile", 2)
	local spec = self.spec_CultivatorSettings
	spec.config = self.configurations["CultivatorSettings"] or 0
	if spec.config > 0 then
		xmlFile:setValue(key.."#config", spec.config)
		if spec.config == 4 then
			dbgprint("saveToXMLFile : key: "..tostring(key), 2)
			xmlFile:setValue(key.."#mode", spec.mode)
		end
		dbgprint("saveToXMLFile : saving data finished", 2)
	end
end

function CultivatorSettings:onReadStream(streamId, connection)
	dbgprint("onReadStream", 3)
	local spec = self.spec_CultivatorSettings
	spec.config = streamReadInt8(streamId, connection)
	spec.mode = streamReadInt8(streamId, connection)
end

function CultivatorSettings:onWriteStream(streamId, connection)
	dbgprint("onWriteStream", 3)
	local spec = self.spec_CultivatorSettings
	streamWriteInt8(streamId, spec.config)
	streamWriteInt8(streamId, spec.mode)
end
	
function CultivatorSettings:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_CultivatorSettings
		if streamReadBool(streamId) then
			dbgprint("onReadUpdateStream: receiving data...", 4)
			spec.config = streamReadInt8(streamId)
			spec.mode = streamReadInt8(streamId)
		end
	end
end

function CultivatorSettings:onWriteUpdateStream(streamId, connection, dirtyMask)
	if connection:getIsServer() then
		local spec = self.spec_CultivatorSettings
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
			dbgprint("onWriteUpdateStream: sending data...", 4)
			streamWriteInt8(streamId, spec.config)
			streamWriteInt8(streamId, spec.mode)
		end
	end
end

-- inputBindings / inputActions
	
function CultivatorSettings:onRegisterActionEvents(isActiveForInput)
	dbgprint("onRegisterActionEvents", 4)
	local spec = self.spec_CultivatorSettings
	if spec ~= nil and self.isClient then
		spec.actionEvents = {} 
		if self:getIsActiveForInput(true) and spec.config == 5 and not spec.useWorkModes then 
		 	_, spec.actionEventMainSwitch = self:addPoweredActionEvent(spec.actionEvents, InputAction.TOGGLE_WORKMODE, self, CultivatorSettings.TOGGLE, false, true, false, true, nil)
		end		
	end
end

function CultivatorSettings:TOGGLE(actionName, keyStatus, arg3, arg4, arg5)
	dbgprint("TOGGLE", 4)
	local spec = self.spec_CultivatorSettings
	dbgprint_r(spec, 4)
	
	spec.mode = spec.mode + 1
	if spec.mode > 4 then spec.mode = 2 end

	if spec.mode == 2 then
		g_currentMission:addGameNotification(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_configuration"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("shallowMode"), "")
	elseif spec.mode == 3 then
		g_currentMission:addGameNotification(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_configuration"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("normalMode"), "")
	elseif spec.mode == 4 then
		g_currentMission:addGameNotification(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("text_DC_configuration"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("deepMode"), "")
	end
	self:raiseDirtyFlags(spec.dirtyFlag)
	dbgprint("TOGGLE : Cultivator config: "..tostring(spec.config), 1)
	dbgprint("TOGGLE : Mode setting: "..tostring(spec.mode), 1)
end
Utils.appendedFunction(Cultivator.onWorkModeChanged, CultivatorSettings.TOGGLE)

function CultivatorSettings:getIsWorkModeChangeAllowed(superfunc)
	local spec = self.spec_CultivatorSettings
	local result = superfunc(self)
	if spec ~= nil and spec.config > 1 and spec.config < 5 then
		result = false
	end
	return result
end
WorkMode.getIsWorkModeChangeAllowed = Utils.overwrittenFunction(WorkMode.getIsWorkModeChangeAllowed, CultivatorSettings.getIsWorkModeChangeAllowed) 

function CultivatorSettings:getPowerMultiplier(superfunc)
	local spec = self.spec_CultivatorSettings
	local multiplier = 1
	
	if not spec.useWorkModes then
		if spec.mode == 2 then multiplier = 0.7 end
		if spec.mode == 4 then multiplier = 1.5 end
	end
	
	--[[ fix multiplier value for REAimplements
	local specPC = self.spec_powerConsumer
	if specPC ~= nil and specPC.MaxForceLeft ~= nil then
		if specPC.maxForceBackup == nil then
			specPC.maxForceBackup = specPC.maxForce
			dbgrender("maxForceBackup: "..tostring(specPC.maxForceBackup), 8, 3)
		end
		specPC.maxForce = specPC.maxForceBackup * multiplier
		dbgrender("maxForce: "..tostring(specPC.maxForce), 8, 3)
	end 	
	--]]
		
	return superfunc(self) * multiplier
end

-- change setting using spec.mode or workmode

function CultivatorSettings:onUpdate(dt)
	local spec = self.spec_CultivatorSettings
	local specCV = self.spec_cultivator
	local specWM = self.spec_workMode
	
	if spec ~= nil and specCV ~= nil then
		if specCV.useDeepModeBackup == nil then
			specCV.useDeepModeBackup = specCV.useDeepMode
			dbgprint("onUpdate: useDeepMode saved", 2)
		end
		if specCV.isSubsoilerBackup == nil then
			specCV.isSubsoilerBackup = specCV.isSubsoiler
			dbgprint("onUpdate: isSubsoiler saved", 2)
		end		
		if spec.config >= 2 and spec.config <= 4 and spec.mode ~= spec.lastMode then
			spec.mode = spec.config

		elseif spec.config == 5 and not spec.useWorkModes then
			if spec.mode == 2 then
				specCV.useDeepMode = false
				specCV.isSubsoiler = false
				dbgprint("onUpdate: setting shallow mode", 2)
			elseif spec.mode == 3 then
				specCV.useDeepMode = true
				specCV.isSubsoiler = false
				dbgprint("onUpdate: setting normal mode", 2)
			elseif spec.mode == 4 then
				specCV.useDeepMode = true
				specCV.isSubsoiler = true
				dbgprint("onUpdate: setting deep mode", 2)
			elseif spec.config == 5 and spec.useWorkModes then
				self:setWorkMode(spec.workModeMapping[spec.mode])
				AnimatedVehicle.updateAnimations(self, 0, true)	
				dbgprint("onUpdate: setting workMode to "..tostring(spec.workModeMapping[spec.mode]), 2)
			end
			
			spec.lastMode = spec.mode
		end
		if spec.config == 1 and spec.reset then
			if specCV.useDeepMode ~= specCV.useDeepModeBackup then
				specCV.useDeepMode = specCV.useDeepModeBackup
				dbgprint("useDeepMode reset", 1)
			end
			if specCV.isSubsoiler ~= specCV.isSubsoilerBackup then
				specCV.isSubsoiler = specCV.isSubsoilerBackup
				dbgprint("isSubsoiler reset", 1)
			end
			if specWM ~= nil and spec.workModeAdded then 
				specWM.workModes[3] = nil 
				specWM.stateMax = 2
			end
			spec.reset = false
		end
	end
end

function CultivatorSettings:onDraw(dt)
	local spec = self.spec_CultivatorSettings
	local specCV = self.spec_cultivator
	if spec ~= nil and spec.config > 1 and (spec.config < 5 or not spec.useWorkModes) then 
		if spec.mode == 3 then
			g_currentMission:addExtraPrintText(string.format(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("mode"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("normalModeShort")))
		elseif spec.mode == 2 then
			g_currentMission:addExtraPrintText(string.format(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("mode"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("shallowModeShort")))
		elseif spec.mode == 4 then
			g_currentMission:addExtraPrintText(string.format(g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("mode"), g_i18n.modEnvironments[CultivatorSettings.MOD_NAME]:getText("deepModeShort")))
		end
	end
	if specCV ~= nil then
		dbgrender("useDeepMode: "..tostring(specCV.useDeepMode), 1, 3)
		dbgrender("isSubsoiler: "..tostring(specCV.isSubsoiler), 2, 3)
		dbgrender("useDeepModeBackup: "..tostring(specCV.useDeepModeBackup), 4, 3)
		dbgrender("isSubsoilerBackup: "..tostring(specCV.isSubsoilerBackup), 5, 3)
	end
end
