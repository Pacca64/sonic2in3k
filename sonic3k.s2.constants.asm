;RAM address equivalents between S2 and S3K
TempArray_LayerDef = HScroll_table

Camera_BG_X_pos = Camera_X_pos_BG_copy
Camera_BG_Y_pos = Camera_Y_pos_BG_copy

PalCycle_Timer = Palette_cycle_counter1
PalCycle_Frame = Palette_cycle_counter0

Normal_palette_line1 = Normal_palette
Normal_palette_line2 = Normal_palette_line_2
Normal_palette_line3 = Normal_palette_line_3
Normal_palette_line4 = Normal_palette_line_4

MainCharacter = Player_1
Sidekick = Player_1

Vint_runcount = V_int_run_count

Boss_defeated_flag = Boss_flag

Camera_Max_X_pos = Camera_max_X_pos
Camera_Min_X_pos = Camera_min_X_pos
Camera_Max_Y_pos = Camera_max_Y_pos
Camera_Min_Y_pos = Camera_min_Y_pos

Dynamic_Resize_Routine = Dynamic_resize_routine

Tails_Min_X_pos = Camera_min_X_pos_P2
Tails_Max_X_pos = Camera_max_X_pos_P2
Tails_Min_Y_pos = Camera_min_Y_pos_P2
Tails_Max_Y_pos = Camera_max_Y_pos_P2

Dynamic_Object_RAM = Dynamic_object_RAM
Dynamic_Object_RAM_End = Dynamic_object_RAM_end

;RAM addresses that need to be reestablished from S2
MTZCylinder_Angle_Sonic = _unkEEF2  ;these *might* be unsafe.
MTZCylinder_Angle_Tails = _unkEEF4  ;perhaps make sure these are initiliazed or something?


;Object RAM

;Players
obj_control = object_control
inertia = ground_vel
flip_turned = flip_type
anim_frame_duration = anim_frame_timer
next_anim = prev_anim



;VRAM CONSTANTS

; Common tiles for all bosses.
ArtTile_ArtNem_FieryExplosion         = $0580

; End of level.
ArtTile_ArtNem_Signpost               = $0434
ArtTile_HUD_Bonus_Score               = $0520
ArtTile_ArtNem_Perfect                = $0540
ArtTile_ArtNem_ResultsText            = $05B0
ArtTile_ArtUnc_Signpost               = $05E8
ArtTile_ArtNem_MiniCharacter          = $05F4
ArtTile_ArtNem_Capsule                = ArtTile_Monitors    ;$0680  ;moved due to conflict with player art!

;General VRAM for all levels
ArtTile_ArtKos_LevelArt               = $0000

;EHZ
ArtTile_ArtKos_Checkers               = ArtTile_ArtKos_LevelArt+$0158
ArtTile_ArtUnc_Flowers1               = $0394
ArtTile_ArtUnc_Flowers2               = $0396
ArtTile_ArtUnc_Flowers3               = $0398
ArtTile_ArtUnc_Flowers4               = $039A

ArtTile_ArtUnc_EHZPulseBall           = $039C
ArtTile_ArtNem_Waterfall              = $039E
ArtTile_ArtNem_EHZ_Bridge             = $03B6
ArtTile_ArtNem_Buzzer                 = $0500
ArtTile_ArtNem_Coconuts               = $0409
ArtTile_ArtNem_Masher                 = $0520	;prevents conflicts with water graphics.
ArtTile_ArtUnc_EHZMountains           = $0500

; EHZ boss
ArtTile_ArtNem_Eggpod_1               = $03A0
ArtTile_ArtNem_EHZBoss                = $0400
ArtTile_ArtNem_EggChoppers            = $056C

; GHZ
ArtTile_ArtNem_GHZ_Bridge             = $038E
;ArtTile_ArtNem_GHZ_Bridge             = ArtTile_ArtNem_EHZ_Bridge
ArtTile_ArtNem_BuzzBomber             = $040E
ArtTile_ArtNem_Newtron              	= $4FF;$04C0
ArtTile_ArtNem_Newtron_split          	= $543
ArtTile_ArtNem_Chopper                 = $0462
ArtTile_ArtNem_Motobug                 = $0445
ArtTile_ArtNem_Crabmeat                 = $03CA
ArtTile_ArtNem_GHZ_Spiked_Log         = $0398
ArtTile_ArtNem_BigRing                = ArtTile_ArtNem_GHZ_Purple_Rock;$0400
ArtTile_ArtNem_FloatPlatform          = $0418
ArtTile_ArtNem_BreakWall              = $0515
ArtTile_ArtNem_GHZ_Purple_Rock        = $03B0
ArtTile_ArtNem_GHZ_Swing            = $0380
ArtTile_ArtNem_GHZ_Ball            = $03AA
ArtTile_ArtNem_GHZ_Walls            = $034C

; SBZ
ArtTile_ArtNem_Stomper            = $2C0 ;$5800/$20
ArtTile_ArtNem_SbzDoor1		= $2E8;$5D00/$20
ArtTile_Nem_Girder	= $2F0;$5E00/$20	; girder
ArtTile_Nem_BallHog	= $302;$6040/$20	; ball hog enemy
ArtTile_Nem_SbzWheel1	= $344;$6880/$20	; spot on large	wheel
ArtTile_Nem_SbzWheel2	= $348;$6900/$20	; wheel	that grabs Sonic
ArtTile_Nem_SyzSpike1	= $391;$7220/$20	; large	spikeball
ArtTile_Nem_Cutter	= $3B5;$76A0/$20	; pizza	cutter
ArtTile_Nem_FlamePipe	= $3D9;$7B20/$20	; flaming pipe
ArtTile_Nem_Cater	= $2B0;$5600/$20	; caterkiller enemy

ArtTile_Nem_Orbinaut	= $429;$8520/$20	; orbinaut enemy
ArtTile_Nem_SlideFloor = $429;$460;$8C00/$20	; floor	that slides away
ArtTile_Nem_SbzDoor2	= $438;$46F;$8DE0/$20	; horizontal door
ArtTile_Nem_Electric	= $55B;$47E;$8FC0/$20	; electric orb
ArtTile_Nem_TrapDoor	= $447;$492;$9240/$20	; trapdoor
ArtTile_Nem_SbzFloor	= $3F9;$7F20/$20	; collapsing floor
ArtTile_Nem_SpinPform	= $4DF;$9BE0/$20	; small	spinning platform
ArtTile_Nem_LzSwitch	= $50F;$A1E0/$20	; switch
ArtTile_Nem_SbzFloor2	= $3F5;$7EA0/$20	; collapsing floor
ArtTile_Nem_SbzBlock	= $53F;$4C3;$9860/$20	; vanishing block
ArtTile_Nem_Bomb	= $400;$8000/$20	; bomb enemy

; SLZ
ArtTile_Nem_SeesawSLZ	=	$6E80/$20
ArtTile_Nem_SlzFire		=	$448
ArtTile_Nem_CollapsePlatform_SLZ	=	ArtTile_Nem_SLZCannon + $8
ArtTile_Nem_SLZCannon	=	$0543
ArtTile_Nem_SlzSpike	=	$55B
ArtTile_Nem_SLZPylon	=	$500
ArtTile_Nem_SLZSwing	=	$3DC

; SYZ
;SYZ has unused graphics at VRAM start that can be safely overwritten
ArtTile_Nem_RollerBadnik	=	1;$439
ArtTile_Nem_RollerBadnikPart2	=	$439;$4FF
ArtTile_ArtNem_BuzzBomber_SYZ	= $040E - $C
ArtTile_ArtNem_Crabmeat_SYZ		= $03CA - $C
ArtTile_ArtNem_SYZRoundBumper         = $0380
ArtTile_Nem_Yadrin		=		$520

ArtTile_Nem_LzSwitch_SYZ	=	$46D

; MZ
ArtTile_ArtNem_BuzzBomberMZ	=	$445
ArtTile_ArtNem_MZBatBadnik	=	$543
ArtTile_ArtNem_MZButton		=	$513

; LZ
ArtTile_ArtNem_WaterSurface_LZ	= $429 - $8
ArtTile_Nem_Burrobot	=	$2FA
ArtTile_Nem_LzSpikeBall		=	$1C6
ArtTile_Nem_LZWheels	=	$354
ArtTile_Nem_Jaws	=	$39C
ArtTile_ArtNem_SpikesS1_LZ	=	$0543
ArtTile_ArtNem_LZ_RopedPlatforms	=	$394 - $40
ArtTile_ArtNem_LZ_MovingBlock	=	$3BC
ArtTile_ArtNem_LZ_VerticalDoor	=	ArtTile_ArtNem_LZ_MovingBlock + $8
ArtTile_Nem_Orbinaut_LZ	= $0400	; orbinaut enemy

ArtTile_ArtNem_SYZ_VrtclSprngS1             = $04FF
ArtTile_ArtNem_SYZ_HrzntlSprngS1            = ArtTile_ArtNem_SYZ_VrtclSprngS1 + $14

; MTZ
ArtTile_ArtNem_Shellcracker           = $031C
ArtTile_ArtUnc_Lava                   = $0340
ArtTile_ArtUnc_MTZCylinder            = $034C
ArtTile_ArtUnc_MTZAnimBack_1          = $035C
ArtTile_ArtUnc_MTZAnimBack_2          = $0362
ArtTile_ArtNem_MtzSupernova           = $0368
ArtTile_ArtNem_MtzWheel               = $0378
ArtTile_ArtNem_MtzWheelIndent         = $03F0
ArtTile_ArtNem_LavaCup                = $03F9
ArtTile_ArtNem_BoltEnd_Rope           = $03FD
ArtTile_ArtNem_MtzSteam               = $0405
ArtTile_ArtNem_MtzSpikeBlock          = $0414
ArtTile_ArtNem_MtzSpike               = $041C
ArtTile_ArtNem_MtzMantis              = $043C
ArtTile_ArtNem_MtzAsstBlocks          = $0500
ArtTile_ArtNem_MtzLavaBubble          = $0536
ArtTile_ArtNem_MtzCog                 = $055F
ArtTile_ArtNem_MtzSpinTubeFlash       = $056B

ArtTile_ArtNem_MtzChainLift = ArtTile_ArtNem_MtzLavaBubble + 11

; WFZ
ArtTile_ArtNem_WfzScratch             = $0379
ArtTile_ArtNem_WfzTiltPlatforms       = $0393
ArtTile_ArtNem_WfzVrtclLazer          = $039F
ArtTile_ArtNem_WfzWallTurret          = $03AB
ArtTile_ArtNem_WfzHrzntlLazer         = $03C3
ArtTile_ArtNem_WfzConveyorBeltWheel   = $03EA
ArtTile_ArtNem_WfzHook                = $03FA
ArtTile_ArtNem_WfzHook_Fudge          = ArtTile_ArtNem_WfzHook + 4 ; Bad mappings...
ArtTile_ArtNem_WfzBeltPlatform        = $040E
ArtTile_ArtNem_WfzGunPlatform         = $041A
ArtTile_ArtNem_WfzUnusedBadnik        = $0450
ArtTile_ArtNem_WfzLaunchCatapult      = $045C
ArtTile_ArtNem_WfzSwitch              = $0461
ArtTile_ArtNem_WfzThrust              = $0465
ArtTile_ArtNem_WfzFloatingPlatform    = $046D
ArtTile_ArtNem_BreakPanels            = $048C

; SCZ
ArtTile_ArtNem_Turtloid               = $038A
ArtTile_ArtNem_Nebula                 = $036E

; HTZ
ArtTile_ArtNem_Rexon                  = $037E
ArtTile_ArtNem_HtzFireball1           = $039E
ArtTile_ArtNem_HtzRock                = $03B2
ArtTile_ArtNem_HtzSeeSaw              = $03C6
ArtTile_ArtNem_Sol                    = $03DE
ArtTile_ArtNem_HtzZipline             = $03E6
ArtTile_ArtNem_HtzFireball2           = $0416
ArtTile_ArtNem_HtzValveBarrier        = $0430
ArtTile_ArtUnc_HTZMountains           = $0500
ArtTile_ArtUnc_HTZClouds              = ArtTile_ArtUnc_HTZMountains + $18
ArtTile_ArtNem_Spiker                 = $0416

ArtTile_ArtUnc_PlantHTZP              = ArtTile_ArtNem_Spiker	;spikers are replaced with this plant in HTZ past
ArtTile_ArtUnc_PlantHTZP2             = ArtTile_ArtUnc_PlantHTZP + $C	;Second plant vram

ArtTile_ArtNem_DinobotHTZ			= $0520	;Dinobot, from HPZ. Used in HTZ time zones.
ArtTile_ArtNem_RhinobotHTZ			= $0550	;Rhinobot, from the beta.

; OOZ
ArtTile_ArtUnc_OOZPulseBall           = $02B6
ArtTile_ArtUnc_OOZSquareBall1         = $02BA
ArtTile_ArtUnc_OOZSquareBall2         = $02BE
ArtTile_ArtUnc_Oil1                   = $02C2
ArtTile_ArtUnc_Oil2                   = $02D2
ArtTile_ArtNem_OOZBurn                = $02E2
ArtTile_ArtNem_OOZElevator            = $02F4
ArtTile_ArtNem_SpikyThing             = $030C
ArtTile_ArtNem_BurnerLid              = $032C
ArtTile_ArtNem_StripedBlocksVert      = $0332
ArtTile_ArtNem_Oilfall                = $0336
ArtTile_ArtNem_Oilfall2               = $0346
ArtTile_ArtNem_BallThing              = $0354
ArtTile_ArtNem_LaunchBall             = $0368
ArtTile_ArtNem_OOZPlatform            = $039D
ArtTile_ArtNem_PushSpring             = $03C5
ArtTile_ArtNem_OOZSwingPlat           = $03E3
ArtTile_ArtNem_StripedBlocksHoriz     = $03FF
ArtTile_ArtNem_OOZFanHoriz            = $0403
ArtTile_ArtNem_Aquis                  = $0500
ArtTile_ArtNem_Octus                  = $0538
ArtTile_SCDFish_OOZ					  = ArtTile_ArtNem_Octus+$3A

ArtTile_ArtNem_OOZBridgeBadnik        = $02DA


; MCZ
ArtTile_ArtNem_Flasher                = $03A8
ArtTile_ArtNem_Minecart               = ArtTile_ArtNem_Flasher+8
ArtTile_ArtNem_Crawlton               = $03C0
ArtTile_ArtNem_Crate                  = $03D4
ArtTile_ArtNem_MCZCollapsePlat        = $03F4
ArtTile_ArtNem_VineSwitch             = $040E
ArtTile_ArtNem_VinePulley             = $041E
ArtTile_ArtNem_MCZGateLog             = $043C

ArtTile_ArtNem_MCZFBstomper           = $0380

; CNZ
ArtTile_ArtNem_Crawl                  = $0340
ArtTile_ArtNem_BigMovingBlock         = $036C
ArtTile_ArtNem_CNZSnake               = $037C
ArtTile_ArtNem_CNZBonusSpike          = $0380
ArtTile_ArtNem_CNZElevator            = $0384
ArtTile_ArtNem_CNZCage                = $0388
ArtTile_ArtNem_CNZHexBumper           = $0394
ArtTile_ArtNem_CNZRoundBumper         = $039A
ArtTile_ArtNem_CNZFlipper             = $03B2
ArtTile_ArtNem_CNZMiniBumper          = $03E6
ArtTile_ArtNem_CNZDiagPlunger         = $0402
ArtTile_ArtNem_CNZVertPlunger         = $0422

ArtTile_ArtNem_SCDSpringWheel_2	=	$538

; Specific to 1p CNZ
ArtTile_ArtUnc_CNZFlipTiles_1         = $0330
ArtTile_ArtUnc_CNZFlipTiles_2         = $0540
ArtTile_ArtUnc_CNZSlotPics_1          = $0550
ArtTile_ArtUnc_CNZSlotPics_2          = $0560
ArtTile_ArtUnc_CNZSlotPics_3          = $0570

; Specific to 2p CNZ
ArtTile_ArtUnc_CNZFlipTiles_1_2p      = $0330
ArtTile_ArtUnc_CNZFlipTiles_2_2p      = $0740
ArtTile_ArtUnc_CNZSlotPics_1_2p       = $0750
ArtTile_ArtUnc_CNZSlotPics_2_2p       = $0760
ArtTile_ArtUnc_CNZSlotPics_3_2p       = $0770

; CPZ
ArtTile_ArtUnc_CPZAnimBack            = $0370
ArtTile_ArtNem_CPZMetalThings         = $0373
ArtTile_ArtNem_ConstructionStripes_2  = $0394
ArtTile_ArtNem_CPZBooster             = $039C
ArtTile_ArtNem_CPZElevator            = $03A0
ArtTile_ArtNem_CPZAnimatedBits        = $03B0
ArtTile_ArtNem_CPZTubeSpring          = $03E0
ArtTile_ArtNem_CPZStairBlock          = $0418
ArtTile_ArtNem_CPZMetalBlock          = $0430
ArtTile_ArtNem_CPZDroplet             = $043C
ArtTile_ArtNem_Grabber                = $0500
ArtTile_ArtNem_Spiny                  = $052D
ArtTile_ArtNem_CPZFBDecor			  = $054D
ArtTile_ArtNem_CPZFBOrbinaut		  = $055F

ArtTile_ArtNem_BallBadnikVinzQ	=	ArtTile_ArtNem_CPZFBDecor

; DEZ
ArtTile_ArtUnc_DEZAnimBack            = $0326
ArtTile_ArtNem_ConstructionStripes_1  = $0328

; ARZ
ArtTile_ArtNem_ARZBarrierThing        = $03F8
ArtTile_ArtNem_Leaves                 = $0410
ArtTile_ArtNem_ArrowAndShooter        = $0417
ArtTile_ArtUnc_Waterfall3             = $0428
ArtTile_ArtUnc_Waterfall2             = $042C
ArtTile_ArtUnc_Waterfall1_1           = $0430
ArtTile_ArtNem_Whisp                  = $0500
ArtTile_ArtNem_Grounder               = $0509
ArtTile_ArtNem_ChopChop               = $053B
ArtTile_ArtUnc_Waterfall1_2           = $0557
ArtTile_ArtNem_BigBubbles             = $055B

;S2 unused
ArtTile_ArtNem_MZ_Platform            = $02B8
ArtTile_ArtUnc_HPZPulseOrb_1          = $02E8
ArtTile_ArtUnc_HPZPulseOrb_2          = $02F0
ArtTile_ArtUnc_HPZPulseOrb_3          = $02F8
ArtTile_ArtNem_HPZ_Bridge             = $0300
ArtTile_ArtNem_HPZ_Waterfall          = $0315
ArtTile_ArtNem_HPZPlatform            = $034A
ArtTile_ArtNem_HPZOrb                 = $035A
ArtTile_ArtNem_HPZ_Emerald            = $0392
ArtTile_ArtNem_Unknown                = $03FA


; PLCs
PLCID_Capsule = $81
PLCID_EhzBoss = $83

; ---------------------------------------------------------------------------
; Art tile stuff
flip_x              =      (1<<11)
flip_y              =      (1<<12)
palette_bit_0       =      5
palette_bit_1       =      6
;palette_line_0      =      (0<<13)
;palette_line_1      =      (1<<13)
;palette_line_2      =      (2<<13)
;palette_line_3      =      (3<<13)
high_priority_bit   =      7
;high_priority       =      (1<<15)
palette_mask        =      $6000
;tile_mask           =      $07FF
nontile_mask        =      $F800
;drawing_mask        =      $7FFF


;Player Animations S2
AniIDSonAni_Walk			= 0 ;   0
AniIDSonAni_Run				= 1 ;   1
AniIDSonAni_Roll			= 2 ;   2
AniIDSonAni_Roll2			= 3 ;   3
AniIDSonAni_Push			= 4 ;   4
AniIDSonAni_Wait			= 5 ;   5
AniIDSonAni_Balance			= 6 ;   6
AniIDSonAni_LookUp			= 7 ;   7
AniIDSonAni_Duck			= 8 ;   8
AniIDSonAni_Spindash		= 9 ;   9
AniIDSonAni_Blink			= 10 ;  $A
AniIDSonAni_GetUp			= 11 ;  $B
AniIDSonAni_Balance2		= 12 ;  $C
AniIDSonAni_Stop			= 13 ;  $D
AniIDSonAni_Float			= 14 ;  $E
AniIDSonAni_Float2			= 15 ;  $F
AniIDSonAni_Spring			= 16 ; $10
AniIDSonAni_Hang			= 17 ; $11
AniIDSonAni_Dash2			= 18 ; $12
AniIDSonAni_Dash3			= 19 ; $13
AniIDSonAni_Hang2			= 20 ; $14
AniIDSonAni_Bubble			= 21 ; $15
AniIDSonAni_DeathBW			= 22 ; $16
AniIDSonAni_Drown			= 23 ; $17
AniIDSonAni_Death			= 24 ; $18
AniIDSonAni_Hurt			= 25 ; $19
AniIDSonAni_Hurt2			= 26 ; $1A
AniIDSonAni_Slide			= 27 ; $1B
AniIDSonAni_Blank			= 28 ; $1C
AniIDSonAni_Balance3		= 29 ; $1D
AniIDSonAni_Balance4		= 30 ; $1E
AniIDSupSonAni_Transform	= 31 ; $1F
AniIDSonAni_Lying			= 32 ; $20
AniIDSonAni_LieDown			= 33 ; $21


;Equivalent Sound Effects
MusID_StopSFX = cmd_StopSFX
MusID_Stop = cmd_Stop
MusID_FadeOut = cmd_FadeOut

SndID_BossHit = sfx_BossHit

;Placeholder Sound Effects
;These are BAD and should be fixed!
;Ideally, the original sound effects should be ported to the sound driver to fix these.
SndID_Helicopter = sfx_Flying
MusID_Boss  =   mus_EndBoss