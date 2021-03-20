-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

------------------------------------------------------
--                REQUIRE BLOCK
------------------------------------------------------

require('internal/util')
require('gamemode')
require("libraries/buildinghelper")
require("libraries/upgrades")
require("libraries/keyvalues")
require("libraries/popups")
GameRules.JSON = require("libraries/json")

-- Require core files!
require('core/bm_core')
require('core/queue')
require('core/utilities')
require('core/research')
require('core/spawner')
require('core/tower_control')
require('core/spawn_synchronizer')
require('core/gathering')
require('core/creep_control')
require('core/hero_selection')
require('core/player_colors')

-- Convert all reliable gold to unreliable
require('widgets/gold_to_unreliable')

-- Gives access to ModifyLumber
require('widgets/modify_lumber')
require('widgets/error_message')

-- Ability Swapper Stuff
require('widgets/ability_swapper/class_utils')
require('widgets/ability_swapper/ability_swapper_ling')
require('widgets/ability_swapper/ability_swapper_xoo')

-- Alchemist Gifter
require('widgets/alchemist_gifter')

-- Gives access to GetPlayerAllyNumber
require('widgets/get_player_info')

-- Gives access to GetItemByName
require('widgets/get_item_by_name')

-- Gives access to ApplyModifier
require('widgets/apply_modifier')

-- Map settings for various maps
require('widgets/map_settings')

-- Alert when bulidings/workers are under attack
require('widgets/damaged_warning')

-- Plays sound for a player
require('widgets/emit_sound_on_client')

-- For lumber cost display on pano
--require('widgets/ability_values_overlay') DEPRECATED

-- For in-game scoreboard
require('scoreboard_updater')

-- Gives access to Resource Functions
require('widgets/get_resources_info')

-- Allows Purifier code to work when built
require('widgets/purifier')

-- LeaderBoard
require('statcollection/web_api')
require('statcollection/points')

-- Developer Tools
require('widgets/developer_tools')

------------------------------------------------------
--                PRECACHE BLOCK
------------------------------------------------------

function Precache( context )
DebugPrint("[BAREBONES] Performing pre-load precache")



-- GLOBAL
--------------------------

-- Custom Game Announcer
PrecacheResource("soundfile", "soundevents/bm2_custom_sounds.vsndevts", context)

-- Towers and Ancients
PrecacheUnitByNameSync("tower_lane1_tier1_team2", context)
PrecacheUnitByNameSync("tower_lane1_tier1_team3", context)
PrecacheUnitByNameSync("ancient_team2", context)
PrecacheUnitByNameSync("ancient_team3", context)

-- Giant Trees
PrecacheUnitByNameSync("giant_tree_1", context)
PrecacheUnitByNameSync("giant_tree_2", context)

-- Items
PrecacheItemByNameSync("item_scout_land", context)
PrecacheItemByNameSync("item_last_stand", context)
PrecacheItemByNameSync("item_mines", context)
PrecacheResource("particle", "particles/econ/courier/courier_flopjaw/flopjaw_death_coins.vpcf", context) -- for Mines
PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_techies.vsndevts", context) -- for Mines

-- Scouts
PrecacheUnitByNameSync("scout_land", context)
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", context) -- for scout_land
PrecacheUnitByNameSync("scout_techies", context)
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context) -- for scout_techies

-- Creephero
PrecacheUnitByNameSync("creephero_drow_ranger", context)
PrecacheUnitByNameSync("creephero_elder_titan", context)
PrecacheUnitByNameSync("creephero_medusa", context)

-- Abilities
PrecacheResource("particle_folder", "particles/units/heroes/hero_treant", context) -- Living Armor
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context) -- Living Armor
PrecacheResource("particle", "particles/items3_fx/mango_active.vpcf", context) -- Mango

PrecacheResource("particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", context) -- Ling Blinding Attack          
PrecacheResource("particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf", context) -- Ling Blinding Attack
PrecacheResource("particle", "particles/items2_fx/mekanism.vpcf", context) -- Ling Mekansm
PrecacheResource("particle", "particles/items2_fx/mekanism_recipient.vpcf", context) -- Ling Mekansm
PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", context) -- Ling Purification            
PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", context) -- Ling Purification
PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", context) -- Ling Purification
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context) -- Ling Purification
PrecacheResource("particle", "particles/units/heroes/hero_centaur/centaur_return.vpcf", context) -- Ling Retaliate
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context) -- Ling Static Touch
PrecacheResource("particle", "particles/status_fx/status_effect_frost_lich.vpcf", context) -- Ling Snowball
PrecacheResource("particle", "particles/units/heroes/hero_lich/lich_frost_nova.vpcf", context) -- Ling Snowball
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context) -- Ling Snowball

PrecacheResource("particle", "particles/items_fx/desolator_projectile.vpcf", context) -- Xoo Corrupted Blade
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context) -- Xoo Counter Helix
PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", context) -- Xoo Counter Helix
PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", context) -- Xoo Fireball
PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context) -- Xoo Fireball
PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", context) -- Xoo Flame Guard


-- LING
--------------------------

-- Ling Buildings
PrecacheUnitByNameSync("ling_building_elixir", context)
PrecacheUnitByNameSync("ling_building_clorn", context)
PrecacheUnitByNameSync("ling_building_orthi", context)
PrecacheUnitByNameSync("ling_building_lumber", context)
PrecacheUnitByNameSync("ling_building_catlan", context)
PrecacheUnitByNameSync("ling_building_thiki", context)
PrecacheUnitByNameSync("ling_building_gnorgil", context)
PrecacheUnitByNameSync("ling_building_temple", context)
PrecacheUnitByNameSync("ling_building_purifier", context)
PrecacheUnitByNameSync("ling_building_runic", context)

-- Ling Creeps
PrecacheUnitByNameSync("ling_creep_clorn", context)
PrecacheUnitByNameSync("ling_creep_orthi", context)
PrecacheUnitByNameSync("ling_creep_catlan", context)
PrecacheUnitByNameSync("ling_creep_thiki", context)
PrecacheUnitByNameSync("ling_creep_gnorgil", context)

-- Ling Workers
PrecacheUnitByNameSync("xoya_worker_nelum", context)


-- XOYA
--------------------------

-- Xoya Buildings
PrecacheUnitByNameSync("xoo_building_belek", context)
PrecacheUnitByNameSync("xoya_building_citol", context)
PrecacheUnitByNameSync("xoya_building_phe", context)
PrecacheUnitByNameSync("xoya_building_lumber", context)
PrecacheUnitByNameSync("xoo_building_catlix", context)
PrecacheUnitByNameSync("xoo_building_zavartu", context)
PrecacheUnitByNameSync("xoya_building_warthan", context)
PrecacheUnitByNameSync("xoya_building_tech", context)
PrecacheUnitByNameSync("xoo_building_arrow", context)
PrecacheUnitByNameSync("xoya_building_skeleton", context)
PrecacheUnitByNameSync("xoya_building_purifier", context)
PrecacheUnitByNameSync("xoo_building_holocron", context)

-- Xoya Creeps
PrecacheUnitByNameSync("xoya_creep_citol", context)
PrecacheUnitByNameSync("xoya_creep_phe", context)
PrecacheUnitByNameSync("xoo_creep_catlix", context)
PrecacheUnitByNameSync("xoo_creep_zavartu", context)
PrecacheUnitByNameSync("xoya_creep_warthan", context)

-- Xoya Workers
PrecacheUnitByNameSync("xoya_worker_dendro", context)


-- Below are Barbones examples

--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
  PlayerColors:Init()
  GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
end