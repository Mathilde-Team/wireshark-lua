-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/builders/init.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local simple = require("terraria.payload.builders.simple")
local hello = require("terraria.payload.builders.hello")
local kick = require("terraria.payload.builders.kick")
local player_info = require("terraria.payload.builders.player_info")
local sync_player = require("terraria.payload.builders.sync_player")
local sync_equipment = require("terraria.payload.builders.sync_equipment")
local world_data = require("terraria.payload.builders.world_data")
local spawn_tile_data = require("terraria.payload.builders.spawn_tile_data")
local status_text_size = require("terraria.payload.builders.status_text_size")
local tile_section = require("terraria.payload.builders.tile_section")
local tile_frame_section = require("terraria.payload.builders.tile_frame_section")
local player_spawn = require("terraria.payload.builders.player_spawn")
local player_controls = require("terraria.payload.builders.player_controls")
local player_active = require("terraria.payload.builders.player_active")
local player_life_mana = require("terraria.payload.builders.player_life_mana")
local tile_manipulation = require("terraria.payload.builders.tile_manipulation")
local set_time = require("terraria.payload.builders.set_time")
local toggle_door_state = require("terraria.payload.builders.toggle_door_state")
local area_tile_change = require("terraria.payload.builders.area_tile_change")
local sync_item = require("terraria.payload.builders.sync_item")
local item_owner = require("terraria.payload.builders.item_owner")
local sync_npc = require("terraria.payload.builders.sync_npc")
local unused_melee_strike = require("terraria.payload.builders.unused_melee_strike")
local sync_projectile = require("terraria.payload.builders.sync_projectile")
local damage_npc = require("terraria.payload.builders.damage_npc")
local kill_projectile = require("terraria.payload.builders.kill_projectile")
local toggle_pvp = require("terraria.payload.builders.toggle_pvp")
local request_chest_open = require("terraria.payload.builders.request_chest_open")
local sync_chest_item = require("terraria.payload.builders.sync_chest_item")
local sync_player_chest = require("terraria.payload.builders.sync_player_chest")
local chest_updates = require("terraria.payload.builders.chest_updates")
local player_heal = require("terraria.payload.builders.player_heal")
local sync_player_zone = require("terraria.payload.builders.sync_player_zone")
local send_password = require("terraria.payload.builders.send_password")
local release_item_ownership = require("terraria.payload.builders.release_item_ownership")
local sync_talk_npc = require("terraria.payload.builders.sync_talk_npc")
local item_rotation_and_animation = require("terraria.payload.builders.item_rotation_and_animation")
local player_mana = require("terraria.payload.builders.player_mana")
local mana_effect = require("terraria.payload.builders.mana_effect")
local team_change = require("terraria.payload.builders.team_change")
local open_sign_request = require("terraria.payload.builders.open_sign_request")
local open_sign_response = require("terraria.payload.builders.open_sign_response")
local liquid_update = require("terraria.payload.builders.liquid_update")
local player_buffs = require("terraria.payload.builders.player_buffs")
local misc_data_sync = require("terraria.payload.builders.misc_data_sync")
local lock_and_unlock = require("terraria.payload.builders.lock_and_unlock")
local add_npc_buff = require("terraria.payload.builders.add_npc_buff")
local npc_buffs = require("terraria.payload.builders.npc_buffs")
local add_player_buff_pvp = require("terraria.payload.builders.add_player_buff_pvp")
local unique_town_npc_info_sync_request = require("terraria.payload.builders.unique_town_npc_info_sync_request")
local world_evil_tally = require("terraria.payload.builders.world_evil_tally")
local instrument_sound = require("terraria.payload.builders.instrument_sound")
local hit_switch = require("terraria.payload.builders.hit_switch")
local npc_home = require("terraria.payload.builders.npc_home")
local spawn_boss_use_license_start_event = require("terraria.payload.builders.spawn_boss_use_license_start_event")
local sync_dodge = require("terraria.payload.builders.sync_dodge")
local sync_tile_paint_or_coating = require("terraria.payload.builders.sync_tile_paint_or_coating")
local sync_wall_paint_or_coating = require("terraria.payload.builders.sync_wall_paint_or_coating")
local teleport_entity = require("terraria.payload.builders.teleport_entity")
local heal_player = require("terraria.payload.builders.heal_player")
local client_uuid = require("terraria.payload.builders.client_uuid")
local chest_name = require("terraria.payload.builders.chest_name")
local bug_catching = require("terraria.payload.builders.bug_catching")
local bug_releasing = require("terraria.payload.builders.bug_releasing")
local travel_merchant_items = require("terraria.payload.builders.travel_merchant_items")
local request_teleportation_by_server = require("terraria.payload.builders.request_teleportation_by_server")
local angler_quest = require("terraria.payload.builders.angler_quest")
local quests_count_sync = require("terraria.payload.builders.quests_count_sync")
local temporary_animation = require("terraria.payload.builders.temporary_animation")
local invasion_progress_report = require("terraria.payload.builders.invasion_progress_report")
local place_object = require("terraria.payload.builders.place_object")
local sync_player_chest_index = require("terraria.payload.builders.sync_player_chest_index")
local combat_text_int = require("terraria.payload.builders.combat_text_int")
local net_modules = require("terraria.payload.builders.net_modules")
local player_stealth = require("terraria.payload.builders.player_stealth")
local quick_stack_chests = require("terraria.payload.builders.quick_stack_chests")
local tile_entity_sharing = require("terraria.payload.builders.tile_entity_sharing")
local tile_entity_placement = require("terraria.payload.builders.tile_entity_placement")
local item_tweaker = require("terraria.payload.builders.item_tweaker")
local item_frame_try_placing = require("terraria.payload.builders.item_frame_try_placing")
local sync_emote_bubble = require("terraria.payload.builders.sync_emote_bubble")
local sync_extra_value = require("terraria.payload.builders.sync_extra_value")
local murder_someone_elses_portal = require("terraria.payload.builders.murder_someone_elses_portal")
local teleport_player_through_portal = require("terraria.payload.builders.teleport_player_through_portal")
local achievement_message_npc_killed = require("terraria.payload.builders.achievement_message_npc_killed")
local achievement_message_event_happened = require("terraria.payload.builders.achievement_message_event_happened")
local minion_rest_target_update = require("terraria.payload.builders.minion_rest_target_update")
local teleport_npc_through_portal = require("terraria.payload.builders.teleport_npc_through_portal")
local update_tower_shield_strengths = require("terraria.payload.builders.update_tower_shield_strengths")
local nebula_levelup_request = require("terraria.payload.builders.nebula_levelup_request")
local moonlord_horror = require("terraria.payload.builders.moonlord_horror")
local shop_override = require("terraria.payload.builders.shop_override")
local gem_lock_toggle = require("terraria.payload.builders.gem_lock_toggle")
local poof_of_smoke = require("terraria.payload.builders.poof_of_smoke")
local smart_text_message = require("terraria.payload.builders.smart_text_message")
local wired_cannon_shot = require("terraria.payload.builders.wired_cannon_shot")
local mass_wire_operation = require("terraria.payload.builders.mass_wire_operation")
local mass_wire_operation_pay = require("terraria.payload.builders.mass_wire_operation_pay")
local special_fx = require("terraria.payload.builders.special_fx")
local crystal_invasion_start = require("terraria.payload.builders.crystal_invasion_start")
local minion_attack_target_update = require("terraria.payload.builders.minion_attack_target_update")
local crystal_invasion_send_wait_time = require("terraria.payload.builders.crystal_invasion_send_wait_time")
local player_hurt_v2 = require("terraria.payload.builders.player_hurt_v2")
local player_death_v2 = require("terraria.payload.builders.player_death_v2")
local combat_text_string = require("terraria.payload.builders.combat_text_string")
local emoji = require("terraria.payload.builders.emoji")
local te_display_doll_data_sync = require("terraria.payload.builders.te_display_doll_data_sync")
local request_tile_entity_interaction = require("terraria.payload.builders.request_tile_entity_interaction")
local weapons_rack_try_placing = require("terraria.payload.builders.weapons_rack_try_placing")
local te_hat_rack_item_sync = require("terraria.payload.builders.te_hat_rack_item_sync")
local sync_tile_picking = require("terraria.payload.builders.sync_tile_picking")
local sync_revenge_marker = require("terraria.payload.builders.sync_revenge_marker")
local remove_revenge_marker = require("terraria.payload.builders.remove_revenge_marker")
local land_golf_ball_in_cup = require("terraria.payload.builders.land_golf_ball_in_cup")
local fish_out_npc = require("terraria.payload.builders.fish_out_npc")
local tamper_with_npc = require("terraria.payload.builders.tamper_with_npc")
local play_legacy_sound = require("terraria.payload.builders.play_legacy_sound")
local food_platter_try_placing = require("terraria.payload.builders.food_platter_try_placing")
local update_player_luck_factors = require("terraria.payload.builders.update_player_luck_factors")
local dead_player = require("terraria.payload.builders.dead_player")
local sync_cavern_monster_type = require("terraria.payload.builders.sync_cavern_monster_type")
local request_npc_buff_removal = require("terraria.payload.builders.request_npc_buff_removal")
local set_counts_as_host_for_gameplay = require("terraria.payload.builders.set_counts_as_host_for_gameplay")
local set_misc_event_values = require("terraria.payload.builders.set_misc_event_values")
local shimmer_actions = require("terraria.payload.builders.shimmer_actions")
local sync_loadout = require("terraria.payload.builders.sync_loadout")
local sync_item_despawn = require("terraria.payload.builders.sync_item_despawn")
local npc_debuff_damage = require("terraria.payload.builders.npc_debuff_damage")
local sync_chest_size = require("terraria.payload.builders.sync_chest_size")
local te_leashed_entity_anchor_place_item = require("terraria.payload.builders.te_leashed_entity_anchor_place_item")
local request_section = require("terraria.payload.builders.request_section")
local item_position = require("terraria.payload.builders.item_position")

---@class PacketBuilderDefinition
---@field id integer
---@field build PayloadBuilder
---@field fields ProtoField[]

---@type PacketBuilderDefinition[]
local definitions = {
	hello,
	kick,
	player_info,
	sync_player,
	sync_equipment,
	simple.empty(6),
	world_data,
	spawn_tile_data,
	status_text_size,
	tile_section,
	tile_frame_section,
	player_spawn,
	player_controls,
	player_active,
	simple.empty(15),
	player_life_mana,
	tile_manipulation,
	set_time,
	toggle_door_state,
	area_tile_change,
	sync_item,
	item_owner,
	sync_npc,
	unused_melee_strike,
	simple.empty(25),
	simple.empty(26),
	sync_projectile,
	damage_npc,
	kill_projectile,
	toggle_pvp,
	request_chest_open,
	sync_chest_item,
	sync_player_chest,
	chest_updates,
	player_heal,
	sync_player_zone,
	simple.empty(37),
	send_password,
	release_item_ownership,
	sync_talk_npc,
	item_rotation_and_animation,
	player_mana,
	mana_effect,
	simple.empty(44),
	team_change,
	open_sign_request,
	open_sign_response,
	liquid_update,
	simple.empty(49),
	player_buffs,
	misc_data_sync,
	lock_and_unlock,
	add_npc_buff,
	npc_buffs,
	add_player_buff_pvp,
	unique_town_npc_info_sync_request,
	world_evil_tally,
	instrument_sound,
	hit_switch,
	npc_home,
	spawn_boss_use_license_start_event,
	sync_dodge,
	sync_tile_paint_or_coating,
	sync_wall_paint_or_coating,
	teleport_entity,
	heal_player,
	simple.empty(67),
	client_uuid,
	chest_name,
	bug_catching,
	bug_releasing,
	travel_merchant_items,
	request_teleportation_by_server,
	angler_quest,
	simple.empty(75),
	quests_count_sync,
	temporary_animation,
	invasion_progress_report,
	place_object,
	sync_player_chest_index,
	combat_text_int,
	net_modules,
	simple.raw(83, "unused83", "Data"),
	player_stealth,
	quick_stack_chests,
	tile_entity_sharing,
	tile_entity_placement,
	item_tweaker,
	item_frame_try_placing,
	simple.alias(sync_item, 90),
	sync_emote_bubble,
	sync_extra_value,
	simple.raw(93, "social_handshake", "Data"),
	simple.raw(94, "dev_commands", "Data"),
	murder_someone_elses_portal,
	teleport_player_through_portal,
	achievement_message_npc_killed,
	achievement_message_event_happened,
	minion_rest_target_update,
	teleport_npc_through_portal,
	update_tower_shield_strengths,
	nebula_levelup_request,
	moonlord_horror,
	shop_override,
	gem_lock_toggle,
	poof_of_smoke,
	smart_text_message,
	wired_cannon_shot,
	mass_wire_operation,
	mass_wire_operation_pay,
	simple.empty(111),
	special_fx,
	crystal_invasion_start,
	simple.empty(114),
	minion_attack_target_update,
	crystal_invasion_send_wait_time,
	player_hurt_v2,
	player_death_v2,
	combat_text_string,
	emoji,
	te_display_doll_data_sync,
	request_tile_entity_interaction,
	weapons_rack_try_placing,
	te_hat_rack_item_sync,
	sync_tile_picking,
	sync_revenge_marker,
	remove_revenge_marker,
	land_golf_ball_in_cup,
	simple.empty(129),
	fish_out_npc,
	tamper_with_npc,
	play_legacy_sound,
	food_platter_try_placing,
	update_player_luck_factors,
	dead_player,
	sync_cavern_monster_type,
	request_npc_buff_removal,
	simple.empty(138),
	set_counts_as_host_for_gameplay,
	set_misc_event_values,
	simple.raw(141, "request_lucy_popup", "Data"),
	simple.raw(142, "sync_projectile_trackers", "Data"),
	simple.empty(143),
	simple.empty(144),
	simple.raw(145, "sync_items_with_shimmer_deprecated", "Data"),
	shimmer_actions,
	sync_loadout,
	simple.raw(148, "sync_item_cannot_be_taken_by_enemies_deprecated", "Data"),
	simple.alias(food_platter_try_placing, 149),
	simple.raw(150, "spectate_player", "Data"),
	sync_item_despawn,
	simple.raw(152, "item_use_sound", "Data"),
	npc_debuff_damage,
	simple.empty(154),
	sync_chest_size,
	te_leashed_entity_anchor_place_item,
	simple.alias(team_change, 157),
	simple.raw(158, "extra_spawn_section_loaded", "Data"),
	request_section,
	item_position,
	simple.raw(161, "host_token", "Data"),
	simple.empty(162),
}

return definitions
