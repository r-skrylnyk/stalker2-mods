local modName = "FractionRadio"

local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

local scripts = {
    "utils",
    "uemath"
}

local _startpath = file_exists([[ue4ss\Mods\]] .. modName .. [[\options.lua]]) and ([[ue4ss\Mods\]] .. modName) or ([[Mods\]] .. modName)
print("Loading options from " .. _startpath .. "\n")
dofile(_startpath .. [[\options.lua]])

print("Loading " .. modName .. " deps\n")
for _, script in ipairs(scripts) do
    require(script)
end

local UEHelpers = require("UEHelpers")

local radioEnabled = false
local playerRadio = nil
local hasLoadedRadioAsset = false
local isEnabled = false
local changedRadioFrequency = false

-- State Variables for new features
local currentVolume = DEFAULT_RADIO_VOLUME or 1.0
local currentStationIndex = 1

-- Helper for On-Screen Text - DISABLED (crashes)
local function PrintToScreen(Text)
    print("[FractionRadio] " .. Text .. "\n")
end

-- This should always be executed in game thread
local function SpawnFromClass(className)
    if (not className) or (type(className) ~= "string") then
        dprint("Invalid class name\n")
        return
    end

    local position = GetPlayerLocation()

    if (not position) then
        dprint("Failed to get player position\n")
        return
    end

    dprint("Player position: " .. VectorToString(position) .. "\n")
    dprint("Spawning object at " .. position.X .. ", " .. position.Y .. ", " .. position.Z .. "\n")

    local object = SpawnActorFromClass(className, FVector(position.X, position.Y, position.Z), FRotator(0, 0, 0))

    if (IsValid(object)) then
        dprint("Object spawned successfully\n")
        return object
    else
        dprint("Failed to spawn object\n")
        return nil
    end
end

function SpawnPortableRadio()
    if (not isEnabled) then return end
    print("SpawnPortableRadio:\n")

    if IsValid(playerRadio) then
        dprint("Radio already spawned\n")
        return nil
    end

    if (not IsWalking()) then
        dprint("Not walking\n")
        return
    end

    if (ALWAYS_TRY_LOAD_ASSET) then
        LoadAsset(RADIO_BP_ASSET)
    end

    playerRadio = SpawnFromClass(RADIO_BP_ASSET)

    if (not IsRadioValid()) then
        playerRadio = nil
        dprint("Failed to spawn radio\n")
        return
    end

    playerRadio:SetActorEnableCollision(false)
    playerRadio:SetActorHiddenInGame(true)

    local playerPawn = GetPlayerPawn()

    if IsValid(playerPawn) and IsValid(playerPawn.RootComponent) then
        playerRadio:K2_AttachToComponent(playerPawn.RootComponent, playerPawn.RootComponent:GetAttachSocketName(), 1, 1, 1, false)
        dprint("Radio attached to player\n")
    end

    TurnOnRadio()
    dprint("Radio spawned\n")
end

function GetRadio()
    return IsValid(playerRadio) and playerRadio or nil
end

function TurnOnRadio()
    if (radioEnabled) then return end

    dprint("Attempting to turn on radio\n")

    if (not CanUseRadio()) then
        SpawnPortableRadio()
        return
    end

    playerRadio:BndEvt__BP_Interactable_Radio_120_HoldOn_K2Node_ComponentBoundEvent_10_InteractSignature__DelegateSignature()
    dprint("Radio turned on\n")

    SetRadioVolume(currentVolume)
    radioEnabled = true
    
    return true
end

function TurnOffRadio()
    if (changedRadioFrequency) then return false end

    dprint("Attempting to turn off radio\n")

    if (not CanUseRadio()) then
        radioEnabled = false
        return
    end

    playerRadio:BndEvt__BP_Interactable_Radio_120_HoldOff_K2Node_ComponentBoundEvent_11_InteractSignature__DelegateSignature()
    dprint("Radio turned off\n")

    radioEnabled = false
    return true
end

function ToggleRadio()
    if (not isEnabled) then return end

    dprint("Attempting to toggle radio\n")

    if (radioEnabled) then
        if (not IsRadioValid()) then
            radioEnabled = false
            TurnOnRadio()
            return
        end

        TurnOffRadio()
    else
        TurnOnRadio()
    end
end

function ChangeRadioFrequency()
    if (not radioEnabled) then return end

    dprint("Attempting to change radio frequency\n")

    if (not CanUseRadio()) then
        return
    end

    playerRadio:BndEvt__BP_Interactable_Radio_120_SingleClick_K2Node_ComponentBoundEvent_9_InteractSignature__DelegateSignature()
    dprint("Radio frequency changed\n")

    changedRadioFrequency = true

    ExecuteWithDelay(2500, function()
        changedRadioFrequency = false
    end)

    return true
end

function ChangeRadioStation(direction)
    if (not isEnabled) then return end
    
    if RADIO_STATIONS == nil or #RADIO_STATIONS == 0 then return end

    if direction == "next" then
        currentStationIndex = currentStationIndex + 1
        if currentStationIndex > #RADIO_STATIONS then currentStationIndex = 1 end
    elseif direction == "prev" then
        currentStationIndex = currentStationIndex - 1
        if currentStationIndex < 1 then currentStationIndex = #RADIO_STATIONS end
    end
    
    local station = RADIO_STATIONS[currentStationIndex]
    local wasEnabled = radioEnabled
    
    ExecuteInGameThread(function()
        if IsValid(playerRadio) and (not playerRadio.bActorIsBeingDestroyed) then
            playerRadio:K2_DestroyActor()
            playerRadio = nil
            radioEnabled = false
        end
        
        RADIO_BP_ASSET = station.Path
        hasLoadedRadioAsset = false
        
        if wasEnabled then
            ExecuteWithDelay(500, function()
                SpawnPortableRadio()
            end)
        end
    end)
end

function NextRadioStation()
    ChangeRadioStation("next")
end

function PrevRadioStation()
    ChangeRadioStation("prev")
end

function ChangeVolumeUp()
    if (not isEnabled) then return end
    currentVolume = currentVolume + (VOLUME_STEP or 0.5)
    if currentVolume > 10.0 then currentVolume = 10.0 end
    
    if radioEnabled then
        SetRadioVolume(currentVolume)
    end
end

function ChangeVolumeDown()
    if (not isEnabled) then return end
    currentVolume = currentVolume - (VOLUME_STEP or 0.5)
    if currentVolume < 0.0 then currentVolume = 0.0 end
    
    if radioEnabled then
        SetRadioVolume(currentVolume)
    end
end

function DestroyRadio()
    ExecuteInGameThread(function()
        if IsValid(playerRadio) and (not playerRadio.bActorIsBeingDestroyed) then
            playerRadio:K2_DestroyActor()
            playerRadio = nil
            dprint("Radio destroyed\n")
        end
    end)
end

function SetRadioVolume(volume)
    if (not isEnabled) then return end

    volume = tonumber(volume)

    if (not volume) then
        dprint("Invalid volume value\n")
        return
    end

    if (not CanUseRadio()) then
        return
    end

    local audio = playerRadio.InteractableRadioAk

    if IsNotValid(audio) then
        dprint("Failed to get radio audio component\n")
        return
    end

    audio:SetOutputBusVolume(volume)
    dprint("Radio volume set to " .. volume .. "\n")
end

function IsRadioValid()
    return IsValid(playerRadio) and (playerRadio.BndEvt__BP_Interactable_Radio_120_HoldOn_K2Node_ComponentBoundEvent_10_InteractSignature__DelegateSignature ~= nil)
end

function CanUseRadio()
    if (not isEnabled) then 
        dprint("Not enabled\n")
        return false 
    end
    if (not IsRadioValid()) then 
        dprint("Radio not spawned\n")
        return false 
    end
    if (not IsWalking()) then 
        dprint("Not walking\n")
        return false 
    end
    return true
end

function IsWalking()
    local characterMovement = GetPlayerCharacterMovement()

    if IsNotValid(characterMovement) then
        dprint("Failed to get player character movement\n")
        return false
    end

    return characterMovement:IsWalking()
end

-- Switch to specific station by index
function SwitchToStation(stationIndex)
    print("[FractionRadio] SwitchToStation called with index: " .. stationIndex .. "\n")
    
    if (not isEnabled) then 
        print("[FractionRadio] Not enabled\n")
        return 
    end
    if RADIO_STATIONS == nil or stationIndex < 1 or stationIndex > #RADIO_STATIONS then 
        print("[FractionRadio] Invalid station index\n")
        return 
    end
    
    local station = RADIO_STATIONS[stationIndex]
    local wasEnabled = radioEnabled
    
    currentStationIndex = stationIndex
    
    ExecuteInGameThread(function()
        print("[FractionRadio] Destroying old radio\n")
        if IsValid(playerRadio) and (not playerRadio.bActorIsBeingDestroyed) then
            playerRadio:K2_DestroyActor()
            playerRadio = nil
            radioEnabled = false
        end
        
        ExecuteWithDelay(1500, function()
            ExecuteInGameThread(function()
                RADIO_BP_ASSET = station.Path
                hasLoadedRadioAsset = false
                
                print("[FractionRadio] Switched to: " .. station.Name .. "\n")
                
                if wasEnabled then
                    print("[FractionRadio] Spawning new radio\n")
                    SpawnPortableRadio()
                else
                    print("[FractionRadio] Radio was off, not spawning\n")
                end
            end)
        end)
    end)
end

-- Game state hooks
NotifyOnNewObject("/Script/Stalker2.LoadingScreenWidget", function(self)
    DestroyRadio()

    if (not hasLoadedRadioAsset) then
        ExecuteInGameThread(function()
            LoadAsset(RADIO_BP_ASSET)
        end)
        hasLoadedRadioAsset = true
    end

    isEnabled = false

    dprint("Loading screen created\n")
end)

NotifyOnNewObject("/Script/Stalker2.DeathScreen", function(self)
    DestroyRadio()

    isEnabled = false
    dprint("Death screen created\n")
end)

NotifyOnNewObject("/Script/Stalker2.Stalker2PlayerController", function(self)
    isEnabled = true
    dprint("Player controller created\n")
end)

-- Console commands
RegisterConsoleCommandHandler("TurnOnRadio", TurnOnRadio)
RegisterConsoleCommandHandler("TurnOffRadio", TurnOffRadio)
RegisterConsoleCommandHandler("ToggleRadio", ToggleRadio)
RegisterConsoleCommandHandler("ChangeRadioFrequency", ChangeRadioFrequency)
RegisterConsoleCommandHandler("SetRadioVolume", function(FullCommand, Parameters, OutputDevice)
    local vol = tonumber(Parameters[1])
    if vol then
        currentVolume = vol
        SetRadioVolume(currentVolume)
        PrintToScreen("Radio Volume: " .. string.format("%.1f", currentVolume))
    end
    return false
end)

-- Keybinds
RegisterKeyBind(KEY_TOGGLE_RADIO, MODIFIERS_TOGGLE_RADIO, function()
    ExecuteInGameThread(function()
        ToggleRadio()
    end)
end)

RegisterKeyBind(KEY_CHANGE_RADIO_FREQUENCY, MODIFIERS_CHANGE_RADIO_FREQUENCY, function()
    ExecuteInGameThread(function()
        ChangeRadioFrequency()
    end)
end)

RegisterKeyBind(KEY_VOLUME_UP, MODIFIERS_VOLUME_UP, function()
    ExecuteInGameThread(function()
        ChangeVolumeUp()
    end)
end)

RegisterKeyBind(KEY_VOLUME_DOWN, MODIFIERS_VOLUME_DOWN, function()
    ExecuteInGameThread(function()
        ChangeVolumeDown()
    end)
end)

-- Station quick-select keybinds (Shift+F1 to Shift+F10)
RegisterKeyBind(KEY_STATION_MIX, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F1 pressed - switching to Mix Radio\n")
        SwitchToStation(1)
    end)
end)

RegisterKeyBind(KEY_STATION_NEUTRAL, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F2 pressed - switching to Neutrals Radio\n")
        SwitchToStation(2)
    end)
end)

RegisterKeyBind(KEY_STATION_BANDITS, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F3 pressed - switching to Bandits Radio\n")
        SwitchToStation(3)
    end)
end)

RegisterKeyBind(KEY_STATION_FREEDOM, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F4 pressed - switching to Freedom Radio\n")
        SwitchToStation(4)
    end)
end)

RegisterKeyBind(KEY_STATION_MILITARY, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F5 pressed - switching to Military Radio\n")
        SwitchToStation(5)
    end)
end)

RegisterKeyBind(KEY_STATION_DUTY, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F6 pressed - switching to Dolg Radio\n")
        SwitchToStation(6)
    end)
end)

RegisterKeyBind(KEY_STATION_MERCENARIES, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F7 pressed - switching to Mercenaries Radio\n")
        SwitchToStation(7)
    end)
end)

RegisterKeyBind(KEY_STATION_KAZKOVY, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F8 pressed - switching to Kazkovy Hub\n")
        SwitchToStation(8)
    end)
end)

RegisterKeyBind(KEY_STATION_CHEMICAL, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F9 pressed - switching to Chemical Plant\n")
        SwitchToStation(9)
    end)
end)

RegisterKeyBind(KEY_STATION_MALAKHIT, {ModifierKey.SHIFT}, function()
    ExecuteInGameThread(function()
        print("[FractionRadio] Shift+F10 pressed - switching to Malakhit Plant\n")
        SwitchToStation(10)
    end)
end)