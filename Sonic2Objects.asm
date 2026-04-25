; ===========================================================================
; ----------------------------------------------------------------------------
; Object 06 - Rotating cylinder in MTZ, twisting spiral pathway in EHZ
; ----------------------------------------------------------------------------
; Sprite_214C4:
Obj06:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj06_Index(pc,d0.w),d1
	jsr	Obj06_Index(pc,d1.w)
    jmp Sprite_OnScreen_Test    ;old Sonic 1 era despawn code does not seem to work in S3K, so we use S3K equivalent of MarkObjGone.

; ===========================================================================
; off_214F4:
Obj06_Index:	offsetTable
		offsetTableEntry.w Obj06_Init		; 0
		offsetTableEntry.w Obj06_Spiral		; 2
		offsetTableEntry.w Obj06_Cylinder	; 4
; ===========================================================================
; loc_214FA:
Obj06_Init:
	addq.b	#2,routine(a0) ; => Obj06_Spiral
	move.b	#$D0,width_pixels(a0)
	tst.b	subtype(a0)
	bpl.s	Obj06_Spiral
	addq.b	#2,routine(a0) ; => Obj06_Cylinder
	bra.w	Obj06_Cylinder

; ===========================================================================
; spiral pathway from EHZ
; loc_21512:
Obj06_Spiral:
	lea	(MainCharacter).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	bsr.s	+
	lea	(Sidekick).w,a1 ; a1=character
	addq.b	#1,d6
+	;this runs for both characters, uses standing bits, like in SolidObject and whatnot
	btst	d6,status(a0)	;is player standing on us?
	bne.w	Obj06_Spiral_PlayerOnUs		;if yes, branch
	btst	#1,status(a1)	;is player in the air?
	bne.w	return_215BE	;if they are in the air, rts
	btst	#3,status(a1)	;is players' standing on object flag set?
	bne.s	loc_21580		;if yes, branch

	move.w	x_pos(a1),d0	;get player x pos
	sub.w	x_pos(a0),d0	;relative to our own
	tst.w	x_vel(a1)		;is there x vel 0?
	bmi.s	loc_21556		;if negative, branch to other direction checks
	cmpi.w	#-$C0,d0		;is player too slow?
	bgt.s	return_215BE	;rts
	cmpi.w	#-$D0,d0		;is player too fast?
	blt.s	return_215BE	;rts
	bra.s	loc_21562
; ---------------------------------------------------------------------------

loc_21556:
	cmpi.w	#$C0,d0		;is player too slow?
	blt.s	return_215BE	;rts
	cmpi.w	#$D0,d0		;is player too fast?
	bgt.s	return_215BE	;rts

;where actual sticking to spiral code runs it seems
loc_21562:
	move.w	y_pos(a1),d1	;get player y pos
	sub.w	y_pos(a0),d1	;relative to us
	subi.w	#$10,d1			;shift up by $10
	cmpi.w	#$30,d1			;is it $30?
	bhs.s	return_215BE	;if higher, rts
	tst.b	obj_control(a1)	;is player under object control lock?
	bne.s	return_215BE	;if yes, rts
	jsr	RideObject_SetRide_S2Compat	;run part of SolidObject code, presumably to make player 'stand' on us
	rts
; ---------------------------------------------------------------------------
;runs when player is standing on an object already, but not us
;looks very similar to above checks, but with some stuff missing.
loc_21580:
	move.w	x_pos(a1),d0    ;get player x pos
	sub.w	x_pos(a0),d0    ;relative to us
	tst.w	x_vel(a1)       ;is player x_vel 0?
	bmi.s	loc_2159C       ;if negative, branch to other direction checks.
	cmpi.w	#-$B0,d0        ;are we too slow?
	bgt.s	return_215BE    ;if yes, rts
	cmpi.w	#-$C0,d0        ;are we too fast?
	blt.s	return_215BE    ;if yes, rts
	bra.s	loc_215A8       ;
; ---------------------------------------------------------------------------

loc_2159C:
	cmpi.w	#$B0,d0
	blt.s	return_215BE
	cmpi.w	#$C0,d0
	bgt.s	return_215BE

;Seems to be how we remount the spiral when transfering between them
loc_215A8:
	move.w	y_pos(a1),d1    ;get player y pos
	sub.w	y_pos(a0),d1    ;relative to us
	subi.w	#$10,d1         ;subtract $10 (push up by a block)
	cmpi.w	#$30,d1         ;is d1 $30?
	bhs.s	return_215BE    ;if player y position is equal to or greater then $30 (too low), rts
	jsr	RideObject_SetRide_S2Compat  ;ride spiral

return_215BE:
	rts
; ---------------------------------------------------------------------------

Obj06_Spiral_PlayerOnUs:
	mvabs.w	inertia(a1),d0	;abs value player inertia
	cmpi.w	#$600,d0
	blo 	Obj06_Spiral_CharacterFallsOff_whenTooSlow	;if less then $600, fall off
	btst	#1,status(a1)			
	bne 	Obj06_Spiral_CharacterFallsOff_whenJumping	;if player is midair (jumped), fall off object.
	move.w	x_pos(a1),d0	;get player x pos
	sub.w	x_pos(a0),d0	;relative to ourself
	addi.w	#$D0,d0			;offset by $D0
	bmi 	Obj06_Spiral_CharacterFallsOff	;if negative, I'm guessing this means we are off the left edge, so fall off.
	cmpi.w	#$1A0,d0		;is position after offset $1A0?
	blo 	Obj06_Spiral_MoveCharacter	;if less then, keep moving character on spiral
	;otherwise, fall through to fall off (check for right edge)

;For some reason, this code needs to be changed in S3K.
;The original code causes the player to fall off the spiral when transfering between 2 spiral objects.
;Since the subtypes go almost entirely unused, I've used them here to fix this problem.
Obj06_Spiral_CharacterFallsOff:
    moveq   #0,d1
    move.b  subtype(a0),d1  ;get subtype in d1

    tst.w  d1   ;is subtype 0?
    beq.s   Obj06_Spiral_CharacterFallsOff_whenTooSlow  ;if 0, run normal falling off code.

    cmp.w   #2,d1   ;is subtype 2? (left side subtype)
    beq.s   Obj06_Spiral_CharacterFallsOff_LeftSideSubtype

    cmp.w   #3,d1   ;is subtype 3? (Connected on both sides subtype?)
    beq.s   Obj06_Spiral_CharacterFallsOff_AfterClearingPlayerStandingFlag  ;if yes, ONLY run the code that connects us to other spirals.

    ;subtype 1 and invalid subtypes fall down to right side code.

;Obj06_Spiral_CharacterFallsOff_RightSideSubtype:
    cmpi.w	#$1A0,d0    ;did we fall off right side?
    blt.s   Obj06_Spiral_CharacterFallsOff_whenTooSlow  ;if not, run normal code.
    bra     Obj06_Spiral_CharacterFallsOff_AfterClearingPlayerStandingFlag  ;if we DID fall off the right side, and have right side subtype, don't clear standing flag.

Obj06_Spiral_CharacterFallsOff_LeftSideSubtype:
    subi.w	#$D0,d0			;
    addi.w	#$D0,d0			;repeat the operation for the left side check
    bpl.s   Obj06_Spiral_CharacterFallsOff_whenTooSlow  ;if we did not fall off the left side, run normal code.
    bra     Obj06_Spiral_CharacterFallsOff_AfterClearingPlayerStandingFlag  ;if we DID fall off the right side, and have right side subtype, don't clear standing flag.

Obj06_Spiral_CharacterFallsOff_whenJumping:
Obj06_Spiral_CharacterFallsOff_whenTooSlow:
	bclr	#3,status(a1)	;clear players stood on object flag

Obj06_Spiral_CharacterFallsOff_AfterClearingPlayerStandingFlag:
	bclr	d6,status(a0)	;clear our own flag for player standing on us
	move.b	#0,flips_remaining(a1)	;reset flips counter for the player
	move.b	#4,flip_speed(a1)	;reset flips speed for the player
	rts

; ---------------------------------------------------------------------------
; loc_21602:
Obj06_Spiral_MoveCharacter:
	btst	#3,status(a1)	;is standing on object flag set?
	beq		Obj06_Spiral_MoveCharacter_rts	;if not, rts. Seems to be some kind of failsafe.
	bsr.s	Obj06_Spiral_MoveCharacter_readcosinetable	;calculate cosine based on player x pos relative to ourself and put that in d1.
	ext.w	d1	;extend to word
	move.w	y_pos(a0),d2	;get our y pos in d2
	add.w	d1,d2			;add cosine of player x to our y pos
	moveq	#0,d1
	move.b	y_radius(a1),d1	;get player y_radius (usually only meaningfully changes when rolling, or playing as tails)
	subi.w	#$13,d1			;subtract offset
	sub.w	d1,d2			;subtract y_radius offset from new y pos value
	move.w	d2,y_pos(a1)	;push to players y pos
	lsr.w	#3,d0			;divide x pos offset by 8
	andi.w	#$3F,d0			;limit between 0 and $3F (63)
	move.b	Obj06_FlipAngleTable(pc,d0.w),flip_angle(a1)	;set players flip angle value based on that.

Obj06_Spiral_MoveCharacter_rts:
	rts

; ===========================================================================
; byte_21634:
; sloopdirtbl:
Obj06_FlipAngleTable:
	dc.b	$00,$00
	dc.b	$01,$01,$16,$16,$16,$16,$2C,$2C
	dc.b	$2C,$2C,$42,$42,$42,$42,$58,$58
	dc.b	$58,$58,$6E,$6E,$6E,$6E,$84,$84
	dc.b	$84,$84,$9A,$9A,$9A,$9A,$B0,$B0
	dc.b	$B0,$B0,$C6,$C6,$C6,$C6,$DC,$DC
	dc.b	$DC,$DC,$F2,$F2,$F2,$F2,$01,$01
	dc.b	$00,$00

;Stupid stuff that tries to work around AS tomfoolery
;For somereason, it randomly says this is out of range a LOT
Obj06_Spiral_MoveCharacter_readcosinetable:
	move.b	Obj06_CosineTable(pc,d0.w),d1
	rts

; byte_21668:
; slooptbl:
Obj06_CosineTable:
	dc.b	 32, 32, 32, 32, 32, 32, 32, 32
	dc.b	 32, 32, 32, 32, 32, 32, 32, 32

	dc.b	 32, 32, 32, 32, 32, 32, 32, 32
	dc.b	 32, 32, 32, 32, 32, 32, 31, 31
	dc.b	 31, 31, 31, 31, 31, 31, 31, 31
	dc.b	 31, 31, 31, 31, 31, 30, 30, 30

	dc.b	 30, 30, 30, 30, 30, 30, 29, 29
	dc.b	 29, 29, 29, 28, 28, 28, 28, 27
	dc.b	 27, 27, 27, 26, 26, 26, 25, 25
	dc.b	 25, 24, 24, 24, 23, 23, 22, 22

	dc.b	 21, 21, 20, 20, 19, 18, 18, 17
	dc.b	 16, 16, 15, 14, 14, 13, 12, 12
	dc.b	 11, 10, 10,  9,  8,  8,  7,  6
	dc.b	  6,  5,  4,  4,  3,  2,  2,  1

	dc.b	  0, -1, -2, -2, -3, -4, -4, -5
	dc.b	 -6, -7, -7, -8, -9, -9,-10,-10
	dc.b	-11,-11,-12,-12,-13,-14,-14,-15
	dc.b	-15,-16,-16,-17,-17,-18,-18,-19

	dc.b	-19,-19,-20,-21,-21,-22,-22,-23
	dc.b	-23,-24,-24,-25,-25,-26,-26,-27
	dc.b	-27,-28,-28,-28,-29,-29,-30,-30
	dc.b	-30,-31,-31,-31,-32,-32,-32,-33

	dc.b	-33,-33,-33,-34,-34,-34,-35,-35
	dc.b	-35,-35,-35,-35,-35,-35,-36,-36
	dc.b	-36,-36,-36,-36,-36,-36,-36,-37
	dc.b	-37,-37,-37,-37,-37,-37,-37,-37

	dc.b	-37,-37,-37,-37,-37,-37,-37,-37
	dc.b	-37,-37,-37,-37,-37,-37,-37,-37
	dc.b	-37,-37,-37,-37,-36,-36,-36,-36
	dc.b	-36,-36,-36,-35,-35,-35,-35,-35

	dc.b	-35,-35,-35,-34,-34,-34,-33,-33
	dc.b	-33,-33,-32,-32,-32,-31,-31,-31
	dc.b	-30,-30,-30,-29,-29,-28,-28,-28
	dc.b	-27,-27,-26,-26,-25,-25,-24,-24

	dc.b	-23,-23,-22,-22,-21,-21,-20,-19
	dc.b	-19,-18,-18,-17,-16,-16,-15,-14
	dc.b	-14,-13,-12,-11,-11,-10, -9, -8
	dc.b	 -7, -7, -6, -5, -4, -3, -2, -1

	dc.b	  0,  1,  2,  3,  4,  5,  6,  7
	dc.b	  8,  8,  9, 10, 10, 11, 12, 13
	dc.b	 13, 14, 14, 15, 15, 16, 16, 17
	dc.b	 17, 18, 18, 19, 19, 20, 20, 21

	dc.b	 21, 22, 22, 23, 23, 24, 24, 24
	dc.b	 25, 25, 25, 25, 26, 26, 26, 26
	dc.b	 27, 27, 27, 27, 28, 28, 28, 28
	dc.b	 28, 28, 29, 29, 29, 29, 29, 29

	dc.b	 29, 30, 30, 30, 30, 30, 30, 30
	dc.b	 31, 31, 31, 31, 31, 31, 31, 31
	dc.b	 31, 31, 32, 32, 32, 32, 32, 32
	dc.b	 32, 32, 32, 32, 32, 32, 32, 32

	dc.b	 32, 32, 32, 32, 32, 32, 32, 32
	dc.b	 32, 32, 32, 32, 32, 32, 32, 32

; ===========================================================================
; rotating meshed cage from MTZ
; loc_21808:
Obj06_Cylinder:
	lea	(MainCharacter).w,a1 ; a1=character
	lea	(MTZCylinder_Angle_Sonic).w,a2
	moveq	#p1_standing_bit,d6
	bsr.s	+
	lea	(Sidekick).w,a1 ; a1=character
	lea	(MTZCylinder_Angle_Tails).w,a2
	addq.b	#1,d6
+
	btst	d6,status(a0)
	bne.w	loc_2188C
	move.w	x_pos(a1),d0
	sub.w	x_pos(a0),d0
	cmpi.w	#-$C0,d0
	blt.s	return_2188A
	cmpi.w	#$C0,d0
	bge.s	return_2188A
	move.w	y_pos(a0),d0
	addi.w	#$3C,d0
	move.w	y_pos(a1),d2
	move.b	y_radius(a1),d1
	ext.w	d1
	add.w	d2,d1
	addq.w	#4,d1
	sub.w	d1,d0
	bhi.s	return_2188A
	cmpi.w	#-$10,d0
	blo.s	return_2188A
	cmpi.b	#6,routine(a1)
	bhs.s	return_2188A
	add.w	d0,d2
	addq.w	#3,d2
	move.w	d2,y_pos(a1)
	move.b	#1,flip_turned(a1) ; face the other way
	jsr	RideObject_SetRide_S2Compat
	move.w	#AniIDSonAni_Run,anim(a1)
	move.b	#0,(a2)
	tst.w	inertia(a1)
	bne.s	return_2188A
	move.w	#1,inertia(a1)

return_2188A:
	rts
; ===========================================================================

loc_2188C:
	btst	#1,status(a1)
	bne.s	loc_218C6
	move.w	x_pos(a1),d0
	sub.w	x_pos(a0),d0
	addi.w	#$C0,d0
	bmi.s	loc_218A8
	cmpi.w	#$180,d0
	blo.s	loc_218E0

loc_218A8:
	bclr	#3,status(a1)
	bclr	d6,status(a0)
	move.b	#0,flips_remaining(a1)
	move.b	#4,flip_speed(a1)
	bset	#1,status(a1)
	rts
; ---------------------------------------------------------------------------
loc_218C6:
	move.b	(a2),d0
	addi.b	#$20,d0
	cmpi.b	#$40,d0
	bhs.s	+
	asr	y_vel(a1)
	bra.s	loc_218A8
; ---------------------------------------------------------------------------
+	move.w	#0,y_vel(a1)
	bra.s	loc_218A8
; ===========================================================================

loc_218E0:
	btst	#3,status(a1)
	beq.s	return_2188A
	move.b	(a2),d0
	jsr	(CalcSine).l
	muls.w	#$2800,d1
	swap	d1
	move.w	y_pos(a0),d2
	add.w	d1,d2
	moveq	#0,d1
	move.b	y_radius(a1),d1
	subi.w	#$13,d1
	sub.w	d1,d2
	move.w	d2,y_pos(a1)
	move.b	(a2),d0
	move.b	d0,flip_angle(a1)
	addq.b	#4,(a2)
	tst.w	inertia(a1)
	bne.s	return_2191E
	move.w	#1,inertia(a1)

return_2191E:
	rts
; ===========================================================================


;Slightly modified to more closely match Sonic 2s' behavior here.
;Hopefully will fix EHZ spirals not chaining together?
RideObject_SetRide_S2Compat:
		btst	#Status_OnObj,status(a1)
		beq.s	loc_1E4A0_RideObject_SetRide_S2Compat
		movea.w	interact(a1),a3
		bclr	d6,status(a3)

loc_1E4A0_RideObject_SetRide_S2Compat:
		move.w	a0,interact(a1)
		move.b	#0,angle(a1)
		move.w	#0,y_vel(a1)
		move.w	x_vel(a1),ground_vel(a1)

        btst    #Status_InAir,status(a1)    ;is player in the air?
        beq.s   RideObject_SetRide_S2Compat_NotInAir    ;if not, branch

		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(Player_TouchFloor).l
		movea.l	(sp)+,a0

RideObject_SetRide_S2Compat_NotInAir:
	bset	#Status_OnObj,status(a1)    ;set walking on object flag for player
	bclr	#Status_InAir,status(a1)    ;clear in air status
	bset	d6,status(a0)

    rts
; End of function RideObject_SetRide


;hacky replacement code for a signpost.
;Please fix x3
Pacca_TemporarySignpost:
	tst.b	(Apparent_act).w	;are we in act 1?
	beq.s	+	;if yes, run signpost code
	jmp	DeleteObject	;if not in Act 1, we are an S2 2 player mode signpost. Those aren't supposed to work!
+
    move.w  (MainCharacter + x_pos).w,d0    ;get player x pos
    move.w  x_pos(a0),d1    ;get our x pos
    sub.w   d0,d1   ;get the difference
    tst.w   d1  ;is the difference 0?
    bmi.s   +   ;if positive (player is past our position), branch
    rts ;return without despawning, gross x3

+
    move.b	#1,(Restart_level_flag).w   ;restart level
    add.b   #1,(Current_act).w  ;go to act 2 (lol)
    move.b  (Current_act).w,(Apparent_act).w    ;^ for apparent act
    clr.b   (Last_star_post_hit).w  ;clear checkpoints.
    rts

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 4B - Buzzer (Buzz bomber) from EHZ
; ----------------------------------------------------------------------------
; OST Variables:
Obj4B_parent		= objoff_32;objoff_2A	; long
Obj4B_move_timer	= objoff_36;objoff_2E	; word
Obj4B_turn_delay	= objoff_38;objoff_30	; word
Obj4B_shooting_flag	= objoff_3A;objoff_32	; byte
Obj4B_shot_timer	= objoff_3E;objoff_34	; word

Obj_Buzzer:
Obj4B:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj4B_Index(pc,d0.w),d1
	jmp	Obj4B_Index(pc,d1.w)
; ===========================================================================
; off_2D076:
Obj4B_Index:	offsetTable
		offsetTableEntry.w Obj4B_Init	; 0
		offsetTableEntry.w Obj4B_Main	; 2
		offsetTableEntry.w Obj4B_Flame	; 4
		offsetTableEntry.w Obj4B_Projectile	; 6
; ===========================================================================
; loc_2D07E:
Obj4B_Projectile:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	jsr	(ObjectMove).l
	lea	(Ani_obj4B).l,a1
	jsr	(AnimateSprite).l
	jmp	(MarkObjGone_P1).l
; ===========================================================================
; loc_2D090:
Obj4B_Flame:
	movea.l	Obj4B_parent(a0),a1 ; a1=object
	tst.l	code(a1)	;is parent object deleted?
	beq		JmpTo49_DeleteObject	; branch, if object slot is empty. This check is incomplete and very unreliable; check Obj50_Wing to see how it should be done
	tst.w	Obj4B_turn_delay(a1)
	bmi.s	+		; branch, if parent isn't currently turning around
	rts

JmpTo49_DeleteObject:
	jmp	DeleteObject

; ---------------------------------------------------------------------------
+	; follow parent object
	move.w	x_pos(a1),x_pos(a0)
	move.w	y_pos(a1),y_pos(a0)
	move.b	status(a1),status(a0)
	move.b	render_flags(a1),render_flags(a0)
	lea	(Ani_obj4B).l,a1
	jsr	(AnimateSprite).l
	jmp	(MarkObjGone_P1).l
; ===========================================================================
; loc_2D0C8:
Obj4B_Init:
	;jsr	S2CDR_EnemySpawnHook
	move.l	#Obj4B_MapUnc_2D2EA,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a0)
	;jsr	(Adjust2PArtPointer).l
	ori.b	#4,render_flags(a0)
	move.b	#$A,collision_flags(a0)
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called. Thankfully only needs to be called once at init.
	move.w	#4*$80,priority(a0)
	move.b	#$10,width_pixels(a0)
	move.b	#$10,y_radius(a0)
	move.b	#$18,x_radius(a0)
	move.w	#3*$80,priority(a0)
	addq.b	#2,routine(a0)	; => Obj4B_Main

	; load exhaust flame object
	jsr	(SingleObjLoad2).l
	bne.s	+	; rts

	move.l	#Obj4B,code(a1) ; load obj4B
	move.b	#4,routine(a1)	; => Obj4B_Flame
	move.l	#Obj4B_MapUnc_2D2EA,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a1)
	;jsrto	(Adjust2PArtPointer2).l, JmpTo7_Adjust2PArtPointer2
	move.w	#4*$80,priority(a1)
	move.b	#$10,width_pixels(a1)
	move.b	status(a0),status(a1)
	move.b	render_flags(a0),render_flags(a1)
	move.b	#1,anim(a1)
	move.l	a0,Obj4B_parent(a1)
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
	move.w	#$100,Obj4B_move_timer(a0)
	move.w	#-$100,x_vel(a0)
	btst	#0,render_flags(a0)
	beq.s	+	; rts
	neg.w	x_vel(a0)
+
	rts
; ===========================================================================
; loc_2D174:
Obj4B_Main:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	Obj4B_Buzzer_States(pc,d0.w),d1
	jsr	Obj4B_Buzzer_States(pc,d1.w)
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	lea	(Ani_obj4B).l,a1
	jsr	(AnimateSprite).l
	jmp	(MarkObjGone_P1).l
; ===========================================================================
; off_2D190:
Obj4B_Buzzer_States:	offsetTable
		offsetTableEntry.w Obj4B_Roaming	; 0
		offsetTableEntry.w Obj4B_Shooting	; 2
; ===========================================================================
; loc_2D194:
Obj4B_Roaming:
	bsr.w	Obj4B_ChkPlayers
	subq.w	#1,Obj4B_turn_delay(a0)
	move.w	Obj4B_turn_delay(a0),d0
	cmpi.w	#$F,d0
	beq.s	Obj4B_TurnAround
	tst.w	d0
	bpl.s	return_2D1B8
	subq.w	#1,Obj4B_move_timer(a0)
	bgt		JmpTo21_ObjectMove
	move.w	#$1E,Obj4B_turn_delay(a0)

return_2D1B8:
	rts

JmpTo21_ObjectMove:
	jmp	ObjectMove
; ---------------------------------------------------------------------------
; loc_2D1BA:
Obj4B_TurnAround:
	sf	Obj4B_shooting_flag(a0)	; reenable shooting
	neg.w	x_vel(a0)		; reverse movement direction
	bchg	#0,render_flags(a0)
	bchg	#0,status(a0)
	move.w	#$100,Obj4B_move_timer(a0)
	rts
; ===========================================================================
; Start of subroutine Obj4B_ChkPlayers
; sub_2D1D6:
Obj4B_ChkPlayers:
	tst.b	Obj4B_shooting_flag(a0)
	bne.w	return_2D232	; branch, if shooting is disabled
	move.w	x_pos(a0),d0
	lea	(MainCharacter).w,a1 ; a1=character
	btst	#0,(Vint_runcount+3).w
	beq.s	+		; target Sidekick on uneven frames
	lea	(Sidekick).w,a1 ; a1=character
+
	sub.w	x_pos(a1),d0	; get object's distance to player
	move.w	d0,d1		; save value for later
	bpl.s	+		; branch, if it was positive
	neg.w	d0		; get absolute value
+
	; test if player is inside an 8 pixel wide strip
	cmpi.w	#$28,d0
	blt.s	return_2D232
	cmpi.w	#$30,d0
	bgt.s	return_2D232

	tst.w	d1			; test sign of distance
	bpl.s	Obj4B_PlayerIsLeft	; branch, if player is left from object
	btst	#0,render_flags(a0)
	beq.s	return_2D232		; branch, if object is facing right
	bra.s	Obj4B_ReadyToShoot
; ---------------------------------------------------------------------------
; loc_2D216:
Obj4B_PlayerIsLeft:
	btst	#0,render_flags(a0)
	bne.s	return_2D232	; branch, if object is facing left

; loc_2D21E:
Obj4B_ReadyToShoot:
	st	Obj4B_shooting_flag(a0)		; disable shooting
	addq.b	#2,routine_secondary(a0)	; => Obj4B_Shooting
	move.b	#3,anim(a0)		; play shooting animation
	move.w	#$32,Obj4B_shot_timer(a0)

return_2D232:
	rts
; End of subroutine Obj4B_ChkPlayers
; ===========================================================================
; loc_2D234:
Obj4B_Shooting:
	move.w	Obj4B_shot_timer(a0),d0	; get timer value
	subq.w	#1,d0			; decrement
	blt.s	Obj4B_DoneShooting	; branch, if timer has expired
	move.w	d0,Obj4B_shot_timer(a0)	; update timer value
	cmpi.w	#$14,d0			; has timer reached a certain value?
	beq.s	Obj4B_ShootProjectile	; if yes, branch
	rts
; ---------------------------------------------------------------------------
; loc_2D248:
Obj4B_DoneShooting:
	subq.b	#2,routine_secondary(a0)	; => Obj4B_Roaming
	rts
; ---------------------------------------------------------------------------
; loc_2D24E
Obj4B_ShootProjectile:
	jsr	(SingleObjLoad2).l	; Find next open object space
	bne.s	+

	_move.l	#Obj4B,code(a1) ; load obj4B
	move.b	#6,routine(a1)	; => Obj4B_Projectile
	move.l	#Obj4B_MapUnc_2D2EA,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_Buzzer,0,0),art_tile(a1)
	;jsrto	(Adjust2PArtPointer2).l, JmpTo7_Adjust2PArtPointer2
	move.w	#4*$80,priority(a1)
	move.b	#$98,collision_flags(a1)
	move.b	#shield_reaction_bounce,shield_reaction(a1)	;Made projectiles bounce off shields for consistency.
	move.b	#$10,width_pixels(a1)
	move.b	status(a0),status(a1)
	move.b	render_flags(a0),render_flags(a1)
	move.b	#2,anim(a1)
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
	addi.w	#$18,y_pos(a1)	; align vertically with stinger
	move.w	#$D,d0		; absolute horizontal offset for stinger
	move.w	#$180,y_vel(a1)
	move.w	#-$180,x_vel(a1)
	btst	#0,render_flags(a1)	; is object facing left?
	beq.s	+			; if not, branch
	neg.w	x_vel(a1)	; move in other direction
	neg.w	d0		; make offset negative
+
	add.w	d0,x_pos(a1)	; align horizontally with stinger
	rts
; ===========================================================================
; animation script
; off_2D2CE:
Ani_obj4B:	offsetTable
		offsetTableEntry.w byte_2D2D6	; 0
		offsetTableEntry.w byte_2D2D9	; 1
		offsetTableEntry.w byte_2D2DD	; 2
		offsetTableEntry.w byte_2D2E1	; 3
byte_2D2D6:	dc.b	$0F, $00, $FF
byte_2D2D9:	dc.b	$02, $03, $04, $FF
byte_2D2DD:	dc.b	$03, $05, $06, $FF
byte_2D2E1:	dc.b	$09, $01, $01, $01, $01, $01, $FD, $00
	even
; ----------------------------------------------------------------------------
; sprite mappings -- Buzz Bomber Sprite Table
; ----------------------------------------------------------------------------
; MapUnc_2D2EA: SprTbl_Buzzer:
Obj4B_MapUnc_2D2EA:	BINCLUDE "General/SpritesS2/Buzzer/mappings.bin"


; ===========================================================================
; ----------------------------------------------------------------------------
; Object 5C - Masher (jumping piranha fish badnik) from EHZ
; ----------------------------------------------------------------------------
; OST Variables:
Obj5C_initial_y_pos	= objoff_30	; word

Obj_Chopper:
Obj_Masher:
Obj5C:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj5C_Index(pc,d0.w),d1
	jsr	Obj5C_Index(pc,d1.w)
	jmp	(MarkObjGone).l
; ===========================================================================
; off_2D3A6:
Obj5C_Index:	offsetTable
		offsetTableEntry.w Obj5C_Init	; 0
		offsetTableEntry.w Obj5C_Main	; 2
; ===========================================================================
; loc_2D3AA:
Obj5C_Init:
	;jsr	S2CDR_EnemySpawnHook
	addq.b	#2,routine(a0)
	move.b	#4,render_flags(a0)
	move.w	#4*$80,priority(a0)
	move.b	#9,collision_flags(a0)
	move.b	#$10,width_pixels(a0)
	move.w	y_pos(a0),Obj5C_initial_y_pos(a0)	; set initial (and lowest) y position

	move.w	#-$700,y_vel(a0) ; set vertical speed
	move.w	#make_art_tile(ArtTile_ArtNem_Chopper,0,0),art_tile(a0)	;make it load chopper art
	move.l	#Chopper_map,mappings(a0)

	BranchIfS1	obj5C_init_GHZ

	move.w	#-$400,y_vel(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Masher,0,0),art_tile(a0)
	move.l	#Obj5C_MapUnc_2D442,mappings(a0)

obj5C_init_GHZ:

; loc_2D3E4:
Obj5C_Main:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	lea	(Ani_obj5C).l,a1
	jsr	(AnimateSprite).l
	jsr	(ObjectMove).l
	addi.w	#$18,y_vel(a0)	; apply gravity
	move.w	Obj5C_initial_y_pos(a0),d0
	cmp.w	y_pos(a0),d0	; has object reached its initial y position?
	bhs.s	+		; if not, branch
	move.w	d0,y_pos(a0)
	BranchIfS1	obj5C_jump_GHZ		;if in S1 zone, use S1 GHZ settings
	move.w	#-$500,y_vel(a0)	; jump
	bra.s	+
obj5C_jump_GHZ:
	move.w	#-$700,y_vel(a0) ; set vertical speed
+
	move.b	#1,anim(a0)	;use animation 1 (slow chomp)

	subi.w	#$C0,d0		;adjust initial pos
	cmp.w	y_pos(a0),d0	;compare to y_pos
	bhs.s	+	; rts
	move.b	#0,anim(a0)	;animation 0 (fast chomp)
	tst.w	y_vel(a0)	; is object falling?
	bmi.s	+	; rts	; if not, branch
	move.b	#2,anim(a0)	; use closed mouth animation
+
	;cmp.b	#FutureBadID,(Time_Zone).w	;are we in bad future?
	;bne.s	+	;if not, branch
	;add.b	#3,anim(a0)	;if in bad future, use the bad future animations with the broken jaw!
;+

	rts
; ===========================================================================
; animation script
; off_2D430:
Ani_obj5C:	offsetTable
		offsetTableEntry.w byte_2D436	; 0 ;fast chomp 
		offsetTableEntry.w byte_2D43A	; 1 ;slow chomp
		offsetTableEntry.w byte_2D43E	; 2
		offsetTableEntry.w byte_2D436_BF	; 3
		offsetTableEntry.w byte_2D43A_BF	; 4
		offsetTableEntry.w byte_2D43E_BF	; 5

byte_2D436:	dc.b   7,  0,  1,$FF	;fast chomp 
byte_2D43A:	dc.b   3,  0,  1,$FF	;slow chomp
byte_2D43E:	dc.b   7,  0,$FF		;idle
byte_2D436_BF:	dc.b   7,  2,  1,$FF	;fast chomp (broken)
byte_2D43A_BF:	dc.b   3,  2,  1,$FF	;slow chomp (broken)
byte_2D43E_BF:	dc.b   7,  2,$FF		;idle (broken)
	even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj5C_MapUnc_2D442:	BINCLUDE "General\SpritesS2\Masher\mappings.bin"
	even

Chopper_map:;	BINCLUDE	"mappings\sprite\Sonic1\s1chopper.bin"
	even