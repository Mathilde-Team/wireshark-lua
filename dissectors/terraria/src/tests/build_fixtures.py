#!/usr/bin/env python3
"""Writes the release-326 fixtures in tests/fixtures as text2pcap hex dumps.

Each fixture is a list of frames; each frame is one TCP segment holding one or more packets.
Layouts follow terrustia's transcription of Terraria 1.4.5.8. Run it after changing a packet
here, then `make test-update` and review the new *.expected files.
"""

import struct
from pathlib import Path

FIXTURES = Path(__file__).resolve().parent / "fixtures"


class W:
    """Little-endian writer mirroring .NET BinaryWriter."""

    def __init__(self):
        self.buf = bytearray()

    def raw(self, data):
        self.buf += data
        return self

    def u8(self, v):
        return self.raw(struct.pack("<B", v))

    def i8(self, v):
        return self.raw(struct.pack("<b", v))

    def u16(self, v):
        return self.raw(struct.pack("<H", v))

    def i16(self, v):
        return self.raw(struct.pack("<h", v))

    def i32(self, v):
        return self.raw(struct.pack("<i", v))

    def u64(self, v):
        return self.raw(struct.pack("<Q", v))

    def f32(self, v):
        return self.raw(struct.pack("<f", v))

    def bool(self, v):
        return self.u8(1 if v else 0)

    def var(self, v):
        while True:
            byte = v & 0x7F
            v >>= 7
            if v:
                self.u8(byte | 0x80)
            else:
                return self.u8(byte)

    def string(self, s):
        data = s.encode("utf-8")
        return self.var(len(data)).raw(data)

    def vec2(self, x, y):
        return self.f32(x).f32(y)


def packet(message_id, body):
    payload = bytes(body.buf)
    return struct.pack("<HB", len(payload) + 3, message_id) + payload


def write(name, comment, frames):
    lines = [f"# {line}" for line in comment.strip().splitlines()]
    for frame in frames:
        lines.append("0000 " + " ".join(f"{b:02x}" for b in frame))
    (FIXTURES / f"{name}.txt").write_text("\n".join(lines) + "\n")


def world_data(dungeon=(3413, 400)):
    w = W()
    w.i32(27000).u8(0x01).u8(3)
    w.i16(4200).i16(1200).i16(2100).i16(300).i16(350).i16(500)
    w.i32(123456).string("Testland").u8(1)
    w.raw(bytes(range(16))).u64(1198295875585).u8(0)
    w.raw(bytes(range(13)))  # background styles
    w.u8(1).u8(2).u8(3).f32(0.25).u8(40)
    for x in (1000, 2000, 4200):
        w.i32(x)
    w.raw(bytes([0, 1, 2, 3]))
    for x in (1500, 3000, 4200):
        w.i32(x)
    w.raw(bytes([4, 5, 6, 7]))
    w.raw(bytes(range(13)))  # tree tops
    w.f32(0.0)
    # flags: downed_boss1, crimson, downed_king_slime, party_is_up; byte 11 left raw
    w.raw(bytes([0x02, 0x20, 0x08, 0x80, 0, 0, 0, 0, 0x22, 0, 0x01]))
    w.u8(0).u8(5)  # sundial, moondial
    for tier in (7, 6, 9, 8, -1, -1, -1):
        w.i16(tier)
    w.i8(0).u64(0).f32(0.0)
    w.u8(1).i16(100).i16(200)  # one extra spawn point
    w.i16(dungeon[0]).i16(dungeon[1])
    return packet(7, w)


def main():
    FIXTURES.mkdir(exist_ok=True)

    write("multiple_pdus", "Two PDUs in one segment: Info must list both",
          [packet(3, W().u8(7).bool(False)) + packet(14, W().u8(7).bool(True))])

    write("malformed_length", "Length field 2 is shorter than the 3-byte header",
          [bytes([0x02, 0x00, 0x01])])

    write("network_text", """
Kick (2) with a localization key whose first substitution is itself formattable, and a
StatusTextSize (9) carrying a literal""", [
        packet(2, W().u8(2).string("LegacyMultiplayer.19").u8(2)
               .u8(1).string("{0} and {1}").u8(1).u8(0).string("Bob")
               .u8(0).string("Alice")),
        packet(9, W().i32(15).u8(0).string("Receiving tile data").u8(0)),
    ])

    write("player_hurt_v2", "PlayerHurtV2 (117): killed by NPC 5 only, so every other death-reason field is absent",
          [packet(117, W().u8(0).u8(0x02).i16(5).i16(10).u8(1).u8(0).i8(0))])

    write("player_death_v2", "PlayerDeathV2 (118): killed by player 1 with item 0x0102 prefix 3",
          [packet(118, W().u8(2).u8(0x61).i16(1).i16(0x0102).u8(3).i16(100).u8(1).u8(0))])

    write("sync_player_chest", "SyncPlayerChest (33): chest named \"Box\", then a chest without a name", [
        packet(33, W().i16(1).i16(10).i16(11).u8(3).string("Box")),
        packet(33, W().i16(-1).i16(0).i16(0).u8(0)),
    ])

    write("tile_entity_sharing", "TileEntitySharing (86): training dummy (type 0) follows, then removal of entity 2", [
        packet(86, W().i32(1).bool(True).u8(0).i16(10).i16(11).i16(-1)),
        packet(86, W().i32(2).bool(False)),
    ])

    write("play_legacy_sound", "PlayLegacySound (132): flags 0x07 carry style, volume 1.0 and pitch 0.5",
          [packet(132, W().vec2(0.0, 0.0).u16(1).u8(0x07).i32(2).f32(1.0).f32(0.5))])

    write("handshake", """
Hello, PlayerInfo with its 1.4.5 bool, SyncPlayer with voice fields and three trailing flag
bytes, SyncEquipment with a u16 slot and favourite flag, SpawnTileData with team""", [
        packet(1, W().string("Terraria326")),
        packet(3, W().u8(2).bool(True)),
        packet(4, W().u8(2).u8(3).u8(1).f32(0.5).u8(53).string("Kris").u8(0).u16(0x0102).u8(0)
               .raw(bytes(range(21))).u8(0x01).u8(0x02).u8(0x04)),
        packet(5, W().u8(2).u16(305).i16(99).u8(81).i16(3507).u8(0x01)),
        packet(8, W().i32(2100).i32(300).u8(1)),
    ])

    write("world_data", "WorldData (7) for release 326, ending with one extra spawn point and the dungeon",
          [world_data()])

    write("player_spawn", "PlayerSpawn (12) with death counters, team and SpawningIntoWorld context",
          [packet(12, W().u8(2).i16(2100).i16(300).i32(0).i16(4).i16(1).u8(3).u8(1))])

    write("player_controls", "PlayerControls (13) with velocity, a mount and a camera target", [
        packet(13, W().u8(2).u8(0x40).u8(0x84).u8(0x00).u8(0x20).u8(5)
               .vec2(1600.0, 4800.0).vec2(2.5, -1.0).u16(8).vec2(1700.0, 4700.0)),
    ])

    tiles = W().i16(100).i16(200).u8(2).u8(1).u8(0)
    # (100, 200): active chest piece (frame-important type 21) with a painted wall
    tiles.u8(0x05).u8(0x08).u8(0x00).u8(27).u16(21).i16(36).i16(18).u16(4)
    # (101, 200): dirt (not frame-important) with half a tile of water
    tiles.u8(0x09).u8(0x00).u8(0x00).u16(0).u8(128).u8(0)
    write("area_tile_change", "AreaTileChange (20): a 2x1 rectangle, column-major", [packet(20, tiles)])

    write("items", """
SyncItem (21) with shimmer and grab-delay trailers, SpawnInstancedItem (90) without,
ItemOwner (22) with 7-bit reservation fields, ReleaseItemOwnership (39), SyncItemDespawn (151),
ItemPosition (160)""", [
        packet(21, W().i16(400).vec2(10.0, 20.0).vec2(0.0, 1.0).i16(5).u8(0).u8(0x0D).i16(73)
               .bool(True).f32(0.5).u8(30)),
        packet(90, W().i16(12).vec2(10.0, 20.0).vec2(0.0, 0.0).i16(1).u8(0).u8(0x00).i16(3318)),
        packet(22, W().i16(12).u8(2).var(300).u8(255).var(0).vec2(10.0, 20.0)),
        packet(39, W().i16(12).bool(False)),
        packet(151, W().i16(12)),
        packet(160, W().i16(12).vec2(11.0, 21.0)),
    ])

    write("sync_npc", "SyncNPC (23): index + generation, two AI slots, scaled stats, 2-byte life",
          [packet(23, W().u8(7).u8(3).vec2(100.0, 200.0).vec2(0.0, 0.0).u16(255).u8(0x0D).u8(0x05)
                  .f32(1.0).f32(-2.0).i16(4).u8(2).f32(1.5).u8(2).i16(1500))])

    write("projectiles", """
SyncProjectile (27) with a second flag byte, banner, damage and ai[2]; DamageNPC (28);
KillProjectile (29) with the same packed key (owner 2, index 17, generation 5)""", [
        packet(27, W().i32(2 | (17 << 8) | (5 << 18)).vec2(64.0, 128.0).vec2(4.0, 0.0).i16(1)
               .u8(0x1D).u8(0x01).f32(1.0).u16(42).i16(9).f32(-0.5)),
        packet(28, W().u8(7).u8(3).i16(25).f32(4.5).u8(2).bool(True)),
        packet(29, W().i32(2 | (17 << 8) | (5 << 18)).vec2(70.0, 128.0)),
    ])

    write("player_state", """
SyncPlayerZone (36) with five zone bytes and town NPCs, PlayerBuffs (50) and NPCBuffs (54)
as zero-terminated lists, UpdatePlayerLuckFactors (134)""", [
        packet(36, W().u8(2).u8(1).u8(2).u8(3).u8(4).u8(5).u8(3)),
        packet(50, W().u8(2).u16(261).u16(332).u16(0)),
        packet(54, W().i16(7).u16(20).u16(600).u16(0)),
        packet(134, W().u8(2).i32(0).f32(0.2).u8(0).bool(True).bool(False).f32(0.05).f32(0.0).u8(1)),
    ])

    write("misc_326", """
Paint with coating (63), QuickStackChests (85), MoonlordHorror (103) with two ints,
TEDisplayDollDataSync (121) pose and item commands, ShimmerActions (146), SyncLoadout (147),
SyncChestSize (155), and the empty Ping (154)""", [
        packet(63, W().i16(10).i16(11).u8(2).bool(True)),
        packet(85, W().i32(2).i16(10).i16(11).bool(True)),
        packet(103, W().i32(3600).i32(1200)),
        packet(121, W().u8(2).i32(5).u8(0).u8(2).u8(1)),
        packet(121, W().u8(2).i32(5).u8(3).u8(1).u16(2700).u16(1).u8(0)),
        packet(146, W().u8(1).vec2(5.0, 6.0).i32(100)),
        packet(147, W().u8(2).u8(1).u16(0x0004)),
        packet(155, W().i16(3).i16(80)),
        packet(154, W()),
    ])

    write("tile_entity_display_doll", """
TileEntitySharing (86) for a display doll: pose, the ninth equip slot and the misc slot""", [
        packet(86, W().i32(9).bool(True).u8(3).i16(50).i16(60)
               .u8(0x01).u8(0x00).u8(4).u8(0x03)
               .i16(1).u8(0).i16(1)     # equip 1
               .i16(2).u8(0).i16(1)     # equip 9
               .i16(3).u8(0).i16(1)),   # misc
    ])


if __name__ == "__main__":
    main()
