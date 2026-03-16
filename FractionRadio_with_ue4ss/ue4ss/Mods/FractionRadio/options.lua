--------------------------------------------------------------------
--------------------- [FractionRadio] OPTIONS ----------------------
--------------------------------------------------------------------
DEBUG = true  -- Debug режим для логів
-- [[ Toggle radio ]]
KEY_TOGGLE_RADIO = Key.B
MODIFIERS_TOGGLE_RADIO = {ModifierKey.SHIFT}
-- [[ Change radio frequency ]]
KEY_CHANGE_RADIO_FREQUENCY = Key.F
MODIFIERS_CHANGE_RADIO_FREQUENCY = {ModifierKey.SHIFT}
-- [[ Volume Control ]]
KEY_VOLUME_UP = Key.PAGE_UP
MODIFIERS_VOLUME_UP = {ModifierKey.SHIFT}
KEY_VOLUME_DOWN = Key.PAGE_DOWN
MODIFIERS_VOLUME_DOWN = {ModifierKey.SHIFT}
VOLUME_STEP = 0.2
DEFAULT_RADIO_VOLUME = 1.0

-- [[ Quick Station Access - Shift+F1 to Shift+F10 ]]
KEY_STATION_MIX = Key.F1           -- Shift+F1
KEY_STATION_NEUTRAL = Key.F2       -- Shift+F2
KEY_STATION_BANDITS = Key.F3       -- Shift+F3
KEY_STATION_FREEDOM = Key.F4       -- Shift+F4
KEY_STATION_MILITARY = Key.F5      -- Shift+F5
KEY_STATION_DUTY = Key.F6          -- Shift+F6
KEY_STATION_MERCENARIES = Key.F7   -- Shift+F7
KEY_STATION_KAZKOVY = Key.F12       -- Shift+F12
KEY_STATION_CHEMICAL = Key.F9      -- Shift+F9
KEY_STATION_MALAKHIT = Key.F10     -- Shift+F10

ALWAYS_TRY_LOAD_ASSET = true

RADIO_STATIONS = {
    { Name = "Mix Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Mix_120.BP_Mix_120_C" },
    { Name = "Neutrals Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Neutrals_120.BP_Neutrals_120_C" },
    { Name = "Bandits Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Bandits_120.BP_Bandits_120_C" },
    { Name = "Freedom Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Freedom_120.BP_Freedom_120_C" },
    { Name = "Military Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Militaries_120.BP_Militaries_120_C" },
    { Name = "Dolg Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Duty_120.BP_Duty_120_C" },
    { Name = "Mercenaries Radio", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Location/BP_Mercenaries_120.BP_Mercenaries_120_C" },
    { Name = "Kazkovy Hub", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Hub/BP_Kazkovy_Hub_120.BP_Kazkovy_Hub_120_C" },
    { Name = "Chemical Plant", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Hub/BP_Chemical_Plant_120.BP_Chemical_Plant_120_C" },
    { Name = "Malakhit Plant", Path = "/Game/_STALKER2/GameDesign/QuestInteractiveObjects/Radio/GenericRadio/Radio_120/Hub/BP_STC_Malachite_120.BP_STC_Malachite_120_C" }
}
RADIO_BP_ASSET = RADIO_STATIONS[1].Path

-- Station indices for quick reference:
-- 1 = Mix Radio (F1)
-- 2 = Neutrals Radio (F2)
-- 3 = Bandits Radio (F3)
-- 4 = Freedom Radio (F4)
-- 5 = Military Radio (F5)
-- 6 = Dolg Radio (F6)
-- 7 = Mercenaries Radio (F7)
-- 8 = Kazkovy Hub (F8)
-- 9 = Chemical Plant (F9)
-- 10 = Malakhit Plant (F10)