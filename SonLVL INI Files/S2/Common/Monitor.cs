using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Drawing;
using SonicRetro.SonLVL.API;

namespace S3KObjectDefinitions.Common
{
	class HiddenMonitor : Monitor
	{
		public override string Name
		{
			get { return "Hidden Monitor"; }
		}

		public override int GetDepth(ObjectEntry obj)
		{
			return 5;
		}
	}

	class Monitor : ObjectDefinition
	{
		private ReadOnlyCollection<byte> subtypes;
		private string[] subtypeNames;
		private Sprite[][] sprites;

		private Sprite[] unknownSprite;

		public override string Name
		{
			get { return "Monitor"; }
		}

		public override Sprite Image
		{
			get { return sprites[0][0]; }
		}

		public override ReadOnlyCollection<byte> Subtypes
		{
			get { return subtypes; }
		}

		public override string SubtypeName(byte subtype)
		{
			return subtypeNames[subtype];
		}

		public override Sprite SubtypeImage(byte subtype)
		{
			return GetSubtypeSprites(subtype)[0];
		}

		public override Sprite GetSprite(ObjectEntry obj)
		{
			return GetSubtypeSprites(obj.SubType)[(obj.XFlip ? 1 : 0) | (obj.YFlip ? 2 : 0)];
		}

		public override int GetDepth(ObjectEntry obj)
		{
			return 3;
		}

		public override void Init(ObjectData data)
		{
			var indexer = new MultiFileIndexer<byte>();
			indexer.AddFile(new List<byte>(LevelData.ReadFile(
				"../General/SpritesS2/Monitors/Monitors.bin", CompressionType.Nemesis)), 0);
			indexer.AddFile(new List<byte>(LevelData.ReadFile(
				"../General/Sprites/HUD Icon/Sonic Life Icon.bin", CompressionType.Nemesis)), 25088);

			var art = indexer.ToArray();
			var map = LevelData.ASMToBin(
				"../General/Sprites/Monitors/Map - Monitor.asm", LevelData.Game.MappingsVersion);

			subtypeNames = new[]
			{
				"Static",
				"1-Up",
				"Super",
				"Eggman",
				"Rings",
				"Speed Shoes",
				"Thunder Barrier",
				"Invincibility",
				"Flame Barrier",
				"Aqua Barrier"
			};

			var subtypes = new byte[subtypeNames.Length];
			subtypes[1] = 1;

			sprites = new Sprite[subtypeNames.Length][];
			sprites[0] = BuildFlippedSprites(ObjectHelper.MapToBmp(art, map, 0, 0));
			sprites[1] = BuildFlippedSprites(ObjectHelper.MapToBmp(art, map, 2, 0));

			var index = 2;
			while (index < subtypeNames.Length)
			{
				subtypes[index] = (byte)index;
				sprites[index++] = BuildFlippedSprites(ObjectHelper.MapToBmp(art, map, index, 0));
			}

			unknownSprite = BuildFlippedSprites(ObjectHelper.UnknownObject);
			this.subtypes = new ReadOnlyCollection<byte>(subtypes);
		}

		private Sprite[] BuildFlippedSprites(Sprite sprite)
		{
			var flipX = new Sprite(sprite, true, false);
			var flipY = new Sprite(sprite, false, true);
			var flipXY = new Sprite(sprite, true, true);

			return new[] { sprite, flipX, flipY, flipXY };
		}

		private Sprite[] GetSubtypeSprites(byte subtype)
		{
			return subtype < sprites.Length ? sprites[SubtypeRemapS2toS3(subtype)] : unknownSprite;
		}

		/**
		Obj_MonitorSubtypeRemapList_S2:
		dc.b	0	;0 -> 0	;Static
		dc.b	1	;1 -> 1	;1 up
		dc.b	1	;2 -> 1	;Tails 1 up monitor
		dc.b	2	;3 -> 2 ;robotnik
		dc.b	3	;4 -> 3 ;rings
		dc.b	4	;5 -> 4 ;speed shoes
		dc.b	6	;6 -> 6 ;shield		;todo: Restore S2 shield object "Obj_S2Shield".
		dc.b	8	;7 -> 8 ;invincibility
		dc.b	5	;8 -> 5 ;teleport, no equivalent, so remapped to fire shield
		dc.b	7	;9 -> 7 ;q mark, remapped to bubble shield to allow using all shields. Leaves Super Sonic monitor unmapped.
		*/

		public byte SubtypeRemapS3toS2(byte subtype)
		{
			switch(subtype){
			case 0:
				return 0;	//Static -> Static
			case 1:
				return 1;	//1up -> 1up
			case 2:
				return 9;	//tails 1up -> 1up
			case 3:
				return 2;	//eggman
			case 4:
				return 3;
			case 5:
				return 4;
			case 6:
				return 6;	//lightning shield
			case 7:
				return 8;	//invincibility
			case 8:
				return 5;	//teleport -> Fire shield
			case 9:
				return 7;	//qmark -> Bubble Shield
			}

			return 0;
		}

		public byte SubtypeRemapS2toS3(byte subtype)
		{
			switch(subtype){
			case 0:
				return 0;	//Static -> Static
			case 1:
				return 1;	//1up -> 1up
			case 2:
				return 9;	//tails 1up -> S monitor
			case 3:
				return 2;
			case 4:
				return 3;
			case 5:
				return 4;	//speed shoes
			case 6:
				return 6;	//lightning shield
			case 7:
				return 8;	//invincibility
			case 8:
				return 5;	//teleport -> fire shield
			case 9:
				return 7;	//qmark -> Bubble Shield
			}

			return 0;
		}
	}
}
