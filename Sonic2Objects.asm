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
    jmp	MarkObjGone3	;potentially despawn, but without drawing a sprite.

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


; ===========================================================================
; ----------------------------------------------------------------------------
; Object 9D - Coconuts (monkey badnik) from EHZ
; ----------------------------------------------------------------------------
; OST Variables:
Obj9D_timer		= objoff_31	; byte
Obj9D_climb_table_index	= objoff_32	; word
Obj9D_attack_timer	= objoff_38	; byte	; time player needs to spend close to object before it attacks
; Sprite_37BFA:
Obj_Coconuts:
Obj9D:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj9D_Index(pc,d0.w),d1
	jmp	Obj9D_Index(pc,d1.w)
; ===========================================================================
; off_37C08:
Obj9D_Index:	offsetTable
		offsetTableEntry.w Obj9D_Init		; 0
		offsetTableEntry.w Obj9D_Idle		; 2
		offsetTableEntry.w Obj9D_Climbing	; 4
		offsetTableEntry.w Obj9D_Throwing	; 6
; ===========================================================================
; loc_37C10:
Obj9D_Init:
	;jsr	S2CDR_EnemySpawnHook
	bsr.w	LoadSubObject
	move.b	#$10,Obj9D_timer(a0)
	rts
; ===========================================================================
; loc_37C1C: Obj9D_Main:
Obj9D_Idle:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	bsr		Obj_GetOrientationToPlayer
	bclr	#0,render_flags(a0)	; face right
	bclr	#0,status(a0)
	tst.w	d0		; is player to object's left?
	beq.s	+		; if not, branch
	bset	#0,render_flags(a0)	; face left
	bset	#0,status(a0)
+
	addi.w	#$60,d2
	cmpi.w	#$C0,d2
	bcc.s	+	; branch, if distance to player is greater than 60 in either direction
	tst.b	Obj9D_attack_timer(a0)	; wait for a bit before attacking
	beq.s	Obj9D_StartThrowing	; branch, when done waiting
	subq.b	#1,Obj9D_attack_timer(a0)
+
	subq.b	#1,Obj9D_timer(a0)	; wait for a bit...
	bmi.s	Obj9D_StartClimbing	; branch, when done waiting
	jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------

Obj9D_StartClimbing:
	addq.b	#2,routine(a0)	; => Obj9D_Climbing
	bsr.w	Obj9D_SetClimbingDirection
	jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
; loc_37C66:
Obj9D_StartThrowing:
	move.b	#6,routine(a0)	; => Obj9D_Throwing
	move.b	#1,mapping_frame(a0)	; display first throwing frame
	move.b	#8,Obj9D_timer(a0)	; set time to display frame
	move.b	#$20,Obj9D_attack_timer(a0)	; reset timer
	jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
; loc_37C82:
Obj9D_SetClimbingDirection:
	move.w	Obj9D_climb_table_index(a0),d0
	cmpi.w	#$C,d0
	blo.s	+	; branch, if index is less than $C
	moveq	#0,d0	; otherwise, reset to 0
+
	lea	Obj9D_ClimbData(pc,d0.w),a1
	addq.w	#2,d0
	move.w	d0,Obj9D_climb_table_index(a0)
	move.b	(a1)+,y_vel(a0)	; climbing speed
	move.b	(a1)+,Obj9D_timer(a0) ; time to spend moving at this speed
	rts
; ===========================================================================
; byte_37CA2:
Obj9D_ClimbData:
	dc.b  -1,$20
	dc.b   1,$18	; 2
	dc.b  -1,$10	; 4
	dc.b   1,$28	; 6
	dc.b  -1,$20	; 8
	dc.b   1,$10	; 10
; ===========================================================================
; loc_37CAE: Obj09_Climbing:
Obj9D_Climbing:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	subq.b	#1,Obj9D_timer(a0)
	beq.s	Obj9D_StopClimbing	; branch, if done moving
	jsr	(ObjectMove).l	; else, keep moving
	lea	(Ani_obj09).l,a1
	jsr	(AnimateSprite).l
	jmp	(MarkObjGone).l
; ===========================================================================
; loc_37CC6:
Obj9D_StopClimbing:
	subq.b	#2,routine(a0)	; => Obj9D_Idle
	move.b	#$10,Obj9D_timer(a0)	; time to remain idle
	jmp	(MarkObjGone).l
; ===========================================================================
; loc_37CD4: Obj09_Throwing:
Obj9D_Throwing:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	Obj9D_ThrowingStates(pc,d0.w),d1
	jsr	Obj9D_ThrowingStates(pc,d1.w)
	jmp	(MarkObjGone).l
; ===========================================================================
; off_37CE6:
Obj9D_ThrowingStates:	offsetTable
		offsetTableEntry.w Obj9D_ThrowingHandRaised	; 0
		offsetTableEntry.w Obj9D_ThrowingHandLowered	; 2
; ===========================================================================
; loc_37CEA:
Obj9D_ThrowingHandRaised:
	subq.b	#1,Obj9D_timer(a0)	; wait for a bit...
	bmi.s	+
	rts
; ---------------------------------------------------------------------------
+	addq.b	#2,routine_secondary(a0)	; => Obj9D_ThrowingHandLowered
	move.b	#8,Obj9D_timer(a0)
	move.b	#2,mapping_frame(a0)	; display second throwing frame
	bra.w	Obj9D_CreateCoconut
; ===========================================================================
; loc_37D06:
Obj9D_ThrowingHandLowered:
	subq.b	#1,Obj9D_timer(a0)	; wait for a bit...
	bmi.s	+
	rts
; ---------------------------------------------------------------------------
+	clr.b	routine_secondary(a0)	; reset routine counter for next time
	move.b	#4,routine(a0) ; => Obj9D_Climbing
	move.b	#8,Obj9D_timer(a0)	; this gets overwrittten by the next subroutine...
	bra.w	Obj9D_SetClimbingDirection
; ===========================================================================
; loc_37D22:
Obj9D_CreateCoconut:
	jsr	(SingleObjLoad).l
	bne.s	return_37D74		; branch, if no free slots
	move.l	#Obj_ProjectileS2,code(a1) ; load obj98
	move.b	#3,mapping_frame(a1)
	move.b	#$20,subtype(a1) ; <== Obj9D_SubObjData2
	move.w	x_pos(a0),x_pos(a1)	; align with parent object
	move.w	y_pos(a0),y_pos(a1)
	addi.w	#-$D,y_pos(a1)		; offset slightly upward
	moveq	#0,d0		; use rightfacing data
	btst	#0,render_flags(a0)	; is object facing left?
	bne.s	+		; if yes, branch
	moveq	#4,d0		; use leftfacing data
+
	lea	Obj9D_ThrowData(pc,d0.w),a2
	move.w	(a2)+,d0
	add.w	d0,x_pos(a1)	; offset slightly left or right depending on object's direction
	move.w	(a2)+,x_vel(a1)	; set projectile speed
	move.w	#-$100,y_vel(a1)
	lea_	Obj98_CoconutFall,a2 ; set the routine used to move the projectile
	move.l	a2,Obj_ProjectileS2_CodePointer(a1)

return_37D74:
	rts
; ===========================================================================
; word_37D76:
Obj9D_ThrowData:
	dc.w   -$B,  $100	; 0
	dc.w	$B, -$100	; 4
; off_37D7E:
Obj9D_SubObjData:
	subObjData Obj9D_Obj98_MapUnc_37D96,make_art_tile(ArtTile_ArtNem_Coconuts,0,0),4,5,$C,9
; off_37782:
Obj9D_SubObjData2:
	subObjData Obj9D_Obj98_MapUnc_37D96,make_art_tile(ArtTile_ArtNem_Coconuts,0,0),$84,4,8,$8B

; animation script
; off_37D88:
Ani_obj09:	offsetTable
		offsetTableEntry.w byte_37D8C	; 0
		offsetTableEntry.w byte_37D90	; 1
byte_37D8C:	dc.b   5,  0,  1,$FF
byte_37D90:	dc.b   9,  1,  2,  1,$FF
		even
; ------------------------------------------------------------------------
; sprite mappings
; ------------------------------------------------------------------------
Obj9D_Obj98_MapUnc_37D96:	INCLUDE "LevelsS2\EHZ\Misc Object Data\Map - Coconuts.asm"

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 98 - Projectile with optional gravity (EHZ coconut, CPZ spiny, etc.)
; ----------------------------------------------------------------------------

;formerly objoff_2A, which conflicts with S3Ks object ram layout.
;Any object that attempts to summon Obj98 needs to have this swapped in for objoff_2A.
Obj_ProjectileS2_CodePointer	=	objoff_32

; Sprite_376E8:
Obj_ProjectileS2:
Obj98:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj98_Index(pc,d0.w),d1
	jmp	Obj98_Index(pc,d1.w)
; ===========================================================================
; off_376F6: Obj98_States:
Obj98_Index:	offsetTable
		offsetTableEntry.w Obj98_Init	; 0
		offsetTableEntry.w Obj98_Main	; 2
; ===========================================================================
; loc_376FA:
Obj98_Init: ;;
	bra.w	LoadSubObject
; ===========================================================================
; loc_376FE:
Obj98_Main:
	tst.b	render_flags(a0)		;is render flags 0?
	bpl		JmpTo65_DeleteObject	;if positive (means on screen flag is NOT set on bit 7), delete self.
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	movea.l	Obj_ProjectileS2_CodePointer(a0),a1
	jsr	(a1)	; dynamic call! to Obj98_NebulaBombFall, Obj98_TurtloidShotMove, Obj98_CoconutFall, Obj98_CluckerShotMove, Obj98_SpinyShotFall, or Obj98_WallTurretShotMove, assuming the code hasn't been changed
	jmp	(MarkObjGone).l

JmpTo65_DeleteObject:
	jmp	(DeleteObject).l

; ===========================================================================
; for obj99
; loc_37710:
Obj98_NebulaBombFall:
	bchg	#palette_bit_0,art_tile(a0) ; bypass the animation system and make it blink
	jmp	(ObjectMoveAndFall).l

; ===========================================================================
; for obj9A
; loc_3771A:
Obj98_TurtloidShotMove:
	jsr	(ObjectMove).l
	lea	(Ani_TurtloidShot).l,a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for obj9D
; loc_37728:
Obj98_CoconutFall:
	addi.w	#$20,y_vel(a0) ; apply gravity (less than normal)
	jsr	(ObjectMove).l
	rts

; ===========================================================================
; for objAE
; loc_37734:
Obj98_CluckerShotMove:
	jsr	(ObjectMove).l
	lea	(Ani_CluckerShot).l,a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for objA6
; loc_37742:
Obj98_SpinyShotFall:
	addi.w	#$20,y_vel(a0) ; apply gravity (less than normal)

Obj98_SpinyShotFall_MetalKnuckles:
	jsr	(ObjectMove).l
	lea	(Ani_SpinyShot).l,a1
	jmp	(AnimateSprite).l

; ===========================================================================
; for objB8
; loc_37756:
Obj98_WallTurretShotMove:
	jsr	(ObjectMove).l
	lea	(Ani_WallTurretShot).l,a1
	jmp	(AnimateSprite).l

; animation script
; off_37B50: TurtloidShotAniData:
Ani_TurtloidShot: offsetTable
		offsetTableEntry.w +
+		dc.b   1,  4,  5,$FF
		even

; off_38CC4
Ani_SpinyShot:	offsetTable
		offsetTableEntry.w +	; 0
+		dc.b   3,  6,  7,$FF
		even

; animation script
; off_395A8
Ani_CluckerShot:offsetTable
		offsetTableEntry.w +	; 0
+		dc.b   3, $D, $E, $F,$10,$11,$12,$13,$14,$FF
		even

; animation script
; off_3BA40:
Ani_WallTurretShot: offsetTable
		offsetTableEntry.w +	; 0
+		dc.b   2,  3,  4,$FF
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Get Orientation To Player
; Returns the horizontal and vertical distances of the closest player object.
;
; input variables:
;  a0 = object
;
; returns:
;  a1 = address of closest player character
;  d0 = 0 if player is left from object, 2 if right
;  d1 = 0 if player is above object, 2 if below
;  d2 = closest character's horizontal distance to object
;  d3 = closest character's vertical distance to object
;
; writes:
;  d0, d1, d2, d3, d4, d5
;  a1
;  a2 = sidekick
; ---------------------------------------------------------------------------
;loc_366D6:
Obj_GetOrientationToPlayer:
	moveq	#0,d0
	moveq	#0,d1
	lea	(MainCharacter).w,a1 ; a1=character
	move.w	x_pos(a0),d2
	sub.w	x_pos(a1),d2
	mvabs.w	d2,d4	; absolute horizontal distance to main character
	lea	(Sidekick).w,a2 ; a2=character
	move.w	x_pos(a0),d3
	sub.w	x_pos(a2),d3
	mvabs.w	d3,d5	; absolute horizontal distance to sidekick
	cmp.w	d5,d4	; get shorter distance
	bls.s	+	; branch, if main character is closer
	; if sidekick is closer
	movea.l	a2,a1
	move.w	d3,d2
+
	tst.w	d2	; is player to enemy's left?
	bpl.s	+	; if not, branch
	addq.w	#2,d0
+
	move.w	y_pos(a0),d3
	sub.w	y_pos(a1),d3	; vertical distance to closest character
	bhs.s	+	; branch, if enemy is under
	addq.w	#2,d1
+
	rts

; ---------------------------------------------------------------------------
; LoadSubObject
; loads information from a sub-object into this object a0
; I'm personally not fond of this system, but porting it is a lot easier then dismantling it x3
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_365F4:
LoadSubObject:
	moveq	#0,d0
	move.b	subtype(a0),d0
; loc_365FA:
LoadSubObject_Part2:
	move.w	SubObjData_Index(pc,d0.w),d0
	lea	SubObjData_Index(pc,d0.w),a1
; loc_36602:
LoadSubObject_Part3:
	move.l	(a1)+,mappings(a0)
	move.w	(a1)+,art_tile(a0)
	;jsr	(Adjust2PArtPointer).l
	move.b	(a1)+,d0
	or.b	d0,render_flags(a0)
	moveq	#0,d0	;clear d0

	move.b	(a1)+,d0	;load Sonic 2 format priority byte in d0
	lsl.w	#7,d0	;multiply by $80 (convert to S3K style priority word)
	move.w	d0,priority(a0)	;Load converted priority word.

	move.b	(a1)+,width_pixels(a0)
	move.b	(a1),collision_flags(a0)
	addq.b	#2,routine(a0)
	rts

; ===========================================================================
; table that maps from the subtype ID to which address to load the data from
; the format of the data there is
;	dc.l Pointer_To_Sprite_Mappings
;	dc.w VRAM_Location
;	dc.b render_flags, priority, width_pixels, collision_flags
; 
; for whatever reason, only Obj8C and later have entries in this table

; off_36628:
SubObjData_Index: offsetTable
	offsetTableEntry.w Obj8C_SubObjData	; $0
	offsetTableEntry.w Obj8D_SubObjData	; $2
	offsetTableEntry.w Obj90_SubObjData	; $4
	offsetTableEntry.w Obj90_SubObjData2	; $6
	offsetTableEntry.w Obj91_SubObjData	; $8
	offsetTableEntry.w Obj92_SubObjData	; $A
	offsetTableEntry.w Invalid_SubObjData	; $C
	offsetTableEntry.w Obj94_SubObjData	; $E
	offsetTableEntry.w Obj94_SubObjData2	; $10
	offsetTableEntry.w Obj99_SubObjData2	; $12
	offsetTableEntry.w Obj99_SubObjData	; $14
	offsetTableEntry.w Obj9A_SubObjData	; $16
	offsetTableEntry.w Obj9B_SubObjData	; $18
	offsetTableEntry.w Obj9C_SubObjData	; $1A
	offsetTableEntry.w Obj9A_SubObjData2	; $1C
	offsetTableEntry.w Obj9D_SubObjData	; $1E
	offsetTableEntry.w Obj9D_SubObjData2	; $20
	offsetTableEntry.w Obj9E_SubObjData	; $22
	offsetTableEntry.w Obj9F_SubObjData	; $24
	offsetTableEntry.w ObjA0_SubObjData	; $26
	offsetTableEntry.w ObjA1_SubObjData	; $28
	offsetTableEntry.w ObjA2_SubObjData	; $2A
	offsetTableEntry.w ObjA3_SubObjData	; $2C
	offsetTableEntry.w ObjA4_SubObjData	; $2E
	offsetTableEntry.w ObjA4_SubObjData2	; $30
	offsetTableEntry.w ObjA5_SubObjData	; $32
	offsetTableEntry.w ObjA6_SubObjData	; $34
	offsetTableEntry.w ObjA7_SubObjData	; $36
	offsetTableEntry.w ObjA7_SubObjData2	; $38
	offsetTableEntry.w ObjA8_SubObjData	; $3A
	offsetTableEntry.w ObjA8_SubObjData2	; $3C
	offsetTableEntry.w ObjA7_SubObjData3	; $3E
	offsetTableEntry.w ObjAC_SubObjData	; $40
	offsetTableEntry.w ObjAD_SubObjData	; $42
	offsetTableEntry.w ObjAD_SubObjData2	; $44
	offsetTableEntry.w ObjAD_SubObjData3	; $46
	offsetTableEntry.w ObjAF_SubObjData2	; $48
	offsetTableEntry.w ObjAF_SubObjData	; $4A
	offsetTableEntry.w ObjB0_SubObjData	; $4C
	offsetTableEntry.w ObjB1_SubObjData	; $4E
	offsetTableEntry.w ObjB2_SubObjData	; $50
	offsetTableEntry.w ObjB2_SubObjData	; $52
	offsetTableEntry.w ObjB2_SubObjData	; $54
	offsetTableEntry.w ObjBC_SubObjData2	; $56
	offsetTableEntry.w ObjBC_SubObjData2	; $58
	offsetTableEntry.w ObjB3_SubObjData	; $5A
	offsetTableEntry.w ObjB2_SubObjData2	; $5C
	offsetTableEntry.w ObjB3_SubObjData	; $5E
	offsetTableEntry.w ObjB3_SubObjData	; $60
	offsetTableEntry.w ObjB3_SubObjData	; $62
	offsetTableEntry.w ObjB4_SubObjData	; $64
	offsetTableEntry.w ObjB5_SubObjData	; $66
	offsetTableEntry.w ObjB5_SubObjData	; $68
	offsetTableEntry.w ObjB6_SubObjData	; $6A
	offsetTableEntry.w ObjB6_SubObjData	; $6C
	offsetTableEntry.w ObjB6_SubObjData	; $6E
	offsetTableEntry.w ObjB6_SubObjData	; $70
	offsetTableEntry.w ObjB7_SubObjData	; $72
	offsetTableEntry.w ObjB8_SubObjData	; $74
	offsetTableEntry.w ObjB9_SubObjData	; $76
	offsetTableEntry.w ObjBA_SubObjData	; $78
	offsetTableEntry.w ObjBA_SubObjData	; $7A
	offsetTableEntry.w ObjBC_SubObjData2	; $7C
	offsetTableEntry.w ObjBD_SubObjData	; $7E
	offsetTableEntry.w ObjBD_SubObjData	; $80
	offsetTableEntry.w ObjBE_SubObjData	; $82
	offsetTableEntry.w ObjBE_SubObjData2	; $84
	offsetTableEntry.w ObjC0_SubObjData	; $86
	offsetTableEntry.w ObjC1_SubObjData	; $88
	offsetTableEntry.w ObjC2_SubObjData	; $8A
	offsetTableEntry.w Invalid_SubObjData2	; $8C
	offsetTableEntry.w ObjB8_SubObjData2	; $8E
	offsetTableEntry.w ObjC3_SubObjData	; $90
	offsetTableEntry.w ObjC5_SubObjData	; $92
	offsetTableEntry.w ObjC5_SubObjData2	; $94
	offsetTableEntry.w ObjC5_SubObjData3	; $96
	offsetTableEntry.w ObjC5_SubObjData3	; $98
	offsetTableEntry.w ObjC5_SubObjData3	; $9A
	offsetTableEntry.w ObjC5_SubObjData3	; $9C
	offsetTableEntry.w ObjC5_SubObjData3	; $9E
	offsetTableEntry.w ObjC6_SubObjData2	; $A0
	offsetTableEntry.w ObjC5_SubObjData4	; $A2
	offsetTableEntry.w ObjAF_SubObjData3	; $A4
	offsetTableEntry.w ObjC6_SubObjData3	; $A6
	offsetTableEntry.w ObjC6_SubObjData4	; $A8
	offsetTableEntry.w ObjC6_SubObjData	; $AA
	offsetTableEntry.w ObjC8_SubObjData	; $AC

Invalid_SubObjData:
Invalid_SubObjData2:

Obj8C_SubObjData:
	;subObjData Obj8C_MapUnc_36A4E,make_art_tile(ArtTile_ArtNem_Whisp,1,1),4,4,$C,$B

; off_36CC4:
Obj8D_SubObjData:
	;subObjData Obj8D_MapUnc_36CF0,make_art_tile(ArtTile_ArtNem_Grounder,1,1),4,5,$10,2
; off_36CCE:
Obj90_SubObjData:
	;subObjData Obj90_MapUnc_36D00,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),$84,4,$10,0
; off_36CD8:
Obj90_SubObjData2:
	;subObjData Obj90_MapUnc_36CFA,make_art_tile(ArtTile_ArtNem_Grounder,1,1),$84,4,8,0
; off_36EE6:
Obj91_SubObjData:
	;subObjData Obj91_MapUnc_36EF6,make_art_tile(ArtTile_ArtNem_ChopChop,1,0),4,4,$10,2
; off_3707C:
Obj92_SubObjData:
	;subObjData Obj92_Obj93_MapUnc_37092,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),4,4,$10,$12
; off_3766E:
Obj94_SubObjData:
	;subObjData Obj94_Obj98_MapUnc_37678,make_art_tile(ArtTile_ArtNem_Rexon,3,0),4,4,$10,0
; off_37764:
Obj94_SubObjData2:
	;subObjData Obj94_Obj98_MapUnc_37678,make_art_tile(ArtTile_ArtNem_Rexon,1,0),$84,4,4,$98
; off_3776E:
Obj99_SubObjData:
	;subObjData Obj99_Obj98_MapUnc_3789A,make_art_tile(ArtTile_ArtNem_Nebula,1,1),$84,4,8,$8B
; off_37778:
Obj9A_SubObjData2:
	;subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),$84,4,4,$98
; off_37B32:
Obj9A_SubObjData:
	;subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),4,5,$18,0
; off_37B3C:
Obj9B_SubObjData:
	;subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),4,4,$C,$1A
; off_37B46:
Obj9C_SubObjData:
	;subObjData Obj9A_Obj98_MapUnc_37B62,make_art_tile(ArtTile_ArtNem_Turtloid,0,0),4,5,8,0
; off_37FE8:
Obj9E_SubObjData:
	;subObjData Obj9E_MapUnc_37FF2,make_art_tile(ArtTile_ArtNem_Crawlton,1,0),4,4,$80,$B
; off_3778C:
ObjA4_SubObjData2:
	;subObjData ObjA4_Obj98_MapUnc_38A96,make_art_tile(ArtTile_ArtNem_MtzSupernova,0,1),$84,5,4,$98
; off_37796:
ObjA6_SubObjData:
	;subObjData ObjA5_ObjA6_Obj98_MapUnc_38CCA,make_art_tile(ArtTile_ArtNem_Spiny,1,0),$84,5,4,$98
; off_377A0:
ObjA7_SubObjData3:
	;subObjData ObjA7_ObjA8_ObjA9_Obj98_MapUnc_3921A,make_art_tile(ArtTile_ArtNem_Grabber,1,1),$84,4,4,$98
; off_377AA:
ObjAD_SubObjData3:
	;subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),$84,5,4,$98
; off_377B4:
ObjAF_SubObjData:
	;subObjData ObjAF_Obj98_MapUnc_39E68,make_art_tile(ArtTile_ArtNem_CNZBonusSpike,1,0),$84,5,4,$98
; off_377BE:
ObjB8_SubObjData2:
	;subObjData ObjB8_Obj98_MapUnc_3BA46,make_art_tile(ArtTile_ArtNem_WfzWallTurret,0,0),$84,3,4,$98

ObjC3_SubObjData:
	;subObjData Obj27_MapUnc_21120,make_art_tile(ArtTile_ArtNem_Explosion,0,0),4,5,$C,0

ObjC5_SubObjData:		; Laser Case
	;subObjData ObjC5_MapUnc_3CCD8,make_art_tile(ArtTile_ArtNem_WFZBoss,0,0),4,4,$20,0
; off_3CC8A:
ObjC5_SubObjData2:		; Laser Walls
	;subObjData ObjC5_MapUnc_3CCD8,make_art_tile(ArtTile_ArtNem_WFZBoss,0,0),4,1,8,0
; off_3CC94:
ObjC5_SubObjData3:		; Platforms, platform releaser, laser and laser shooter
	;subObjData ObjC5_MapUnc_3CCD8,make_art_tile(ArtTile_ArtNem_WFZBoss,0,0),4,5,$10,0
; off_3CC9E:
ObjC6_SubObjData2:		; Robotnik
	;subObjData ObjC6_MapUnc_3D0EE,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),4,5,$20,0
; off_3CCA8:
ObjC5_SubObjData4:		; Robotnik platform
	;subObjData ObjC5_MapUnc_3CEBC,make_art_tile(ArtTile_ArtNem_WfzFloatingPlatform,1,1),4,5,$20,0

ObjC6_SubObjData3:
	;subObjData ObjC6_MapUnc_3D0EE,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),4,5,$18,0
; off_3D0BC:
ObjC6_SubObjData4:
	;subObjData ObjC6_MapUnc_3D1DE,make_art_tile(ArtTile_ArtNem_ConstructionStripes_1,1,0),4,1,8,0
; off_3D0C6:
ObjC6_SubObjData:
	;subObjData ObjC6_MapUnc_3D0EE,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),4,5,4,0

ObjC7_SubObjData:
	;subObjData ObjC7_MapUnc_3E5F8,make_art_tile(ArtTile_ArtNem_DEZBoss,0,0),4,4,$38,$00


ObjC8_SubObjData:
	;subObjData ObjC8_MapUnc_3D450,make_art_tile(ArtTile_ArtNem_Crawl,0,1),4,3,$10,$D7

ObjC1_SubObjData:
	;subObjData ObjC1_MapUnc_3C280,make_art_tile(ArtTile_ArtNem_BreakPanels,3,1),4,4,$40,$E1

ObjB7_SubObjData:
	;subObjData ObjB7_MapUnc_3B8E4,make_art_tile(ArtTile_ArtNem_WfzVrtclLazer,2,1),4,4,$18,$A9

Obj99_SubObjData2:
	;subObjData Obj99_Obj98_MapUnc_3789A,make_art_tile(ArtTile_ArtNem_Nebula,1,1),4,4,$10,6
; off_382F0:
Obj9F_SubObjData:
	;subObjData Obj9F_MapUnc_38314,make_art_tile(ArtTile_ArtNem_Shellcracker,0,0),4,5,$18,$A
; off_382FA:
ObjA0_SubObjData:
	;subObjData Obj9F_MapUnc_38314,make_art_tile(ArtTile_ArtNem_Shellcracker,0,0),4,4,$C,$9A
ObjA1_SubObjData:
	;subObjData ObjA1_MapUnc_385E2,make_art_tile(ArtTile_ArtNem_MtzMantis,1,0),4,5,$10,6
; off_385CA:
ObjA2_SubObjData:
	;subObjData ObjA1_MapUnc_385E2,make_art_tile(ArtTile_ArtNem_MtzMantis,1,0),4,4,$10,$9A
; off_388AC:
ObjA3_SubObjData:
	;subObjData ObjA3_MapUnc_388F0,make_art_tile(ArtTile_ArtNem_Flasher,0,1),4,4,$10,6
ObjA4_SubObjData:
	;subObjData ObjA4_Obj98_MapUnc_38A96,make_art_tile(ArtTile_ArtNem_MtzSupernova,0,1),4,4,$10,$B
ObjA5_SubObjData:
	;subObjData ObjA5_ObjA6_Obj98_MapUnc_38CCA,make_art_tile(ArtTile_ArtNem_Spiny,1,0),4,4,8,$B
; off_391EC:
ObjA7_SubObjData:
	;subObjData ObjA7_ObjA8_ObjA9_Obj98_MapUnc_3921A,make_art_tile(ArtTile_ArtNem_Grabber,1,1),4,4,$10,$B
; off_391F6:
ObjA7_SubObjData2:
	;subObjData ObjA7_ObjA8_ObjA9_Obj98_MapUnc_3921A,make_art_tile(ArtTile_ArtNem_Grabber,1,1),4,1,$10,$D7
; off_39200:
ObjA8_SubObjData:
	;subObjData ObjA7_ObjA8_ObjA9_Obj98_MapUnc_3921A,make_art_tile(ArtTile_ArtNem_Grabber,1,1),4,4,4,0
; off_3920A:
ObjA8_SubObjData2:
	;subObjData ObjAA_MapUnc_39228,make_art_tile(ArtTile_ArtNem_Grabber,1,1),4,5,4,0
; off_393C2:
ObjAC_SubObjData:
	;subObjData ObjAC_MapUnc_393CC,make_art_tile(ArtTile_ArtNem_Balkrie,0,0),4,4,$20,8
ObjAD_SubObjData:
	;subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),4,4,$18,0
ObjAD_SubObjData2:
	;subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),4,5,$10,0
; off_39DCE:
ObjAF_SubObjData2:
	;subObjData ObjAF_Obj98_MapUnc_39E68,make_art_tile(ArtTile_ArtNem_SilverSonic,1,0),4,4,$10,$1A
; off_39DD8:
ObjAF_SubObjData3:
	;subObjData ObjAF_MapUnc_3A08C,make_art_tile(ArtTile_ArtNem_DEZWindow,0,0),4,6,$10,0
; off_3A58A:
ObjB0_SubObjData:
	;subObjData ObjB1_MapUnc_3A5A6,make_art_tile(ArtTile_ArtUnc_Giant_Sonic,2,1),0,1,$10,0

; off_3A594:
ObjB1_SubObjData:
	;subObjData ObjB1_MapUnc_3A5A6,make_art_tile(ArtTile_ArtNem_Sega_Logo+2,0,0),0,2,8,0


; off_3AFC8:
ObjB2_SubObjData:
	;subObjData ObjB2_MapUnc_3AFF2,make_art_tile(ArtTile_ArtNem_Tornado,0,1),4,4,$60,0
; off_3AFD2:
ObjB2_SubObjData2:
	;subObjData ObjB2_MapUnc_3B292,make_art_tile(ArtTile_ArtNem_TornadoThruster,0,0),4,3,$40,0
; off_3BBFE:
ObjBC_SubObjData2:
	;subObjData ObjBC_MapUnc_3BC08,make_art_tile(ArtTile_ArtNem_WfzThrust,2,0),4,4,$10,0
; off_3B322:
ObjB3_SubObjData:
	;subObjData ObjB3_MapUnc_3B32C,make_art_tile(ArtTile_ArtNem_Clouds,2,0),4,6,$30,0
; off_3B3AC:
ObjB4_SubObjData:
	;subObjData ObjB4_MapUnc_3B3BE,make_art_tile(ArtTile_ArtNem_WfzVrtclPrpllr,1,1),4,4,4,$A8

; off_3B4DE:
ObjB5_SubObjData:
	;subObjData ObjB5_MapUnc_3B548,make_art_tile(ArtTile_ArtNem_WfzHrzntlPrpllr,1,1),4,4,$40,0
; off_3B818:
ObjB6_SubObjData:
	;subObjData ObjB6_MapUnc_3B856,make_art_tile(ArtTile_ArtNem_WfzTiltPlatforms,1,1),4,4,$10,0
; off_3BA36:
ObjB8_SubObjData:
	;subObjData ObjB8_Obj98_MapUnc_3BA46,make_art_tile(ArtTile_ArtNem_WfzWallTurret,0,0),4,4,$10,0
; off_3BB0E:
ObjB9_SubObjData:
	;subObjData ObjB9_MapUnc_3BB18,make_art_tile(ArtTile_ArtNem_WfzHrzntlLazer,2,1),4,1,$60,0
; off_3BB66:
ObjBA_SubObjData:
	;subObjData ObjBA_MapUnc_3BB70,make_art_tile(ArtTile_ArtNem_WfzConveyorBeltWheel,2,1),4,4,$10,0
; off_3BD24:
ObjBD_SubObjData:
	;subObjData ObjBD_MapUnc_3BD3E,make_art_tile(ArtTile_ArtNem_WfzBeltPlatform,3,1),4,4,$18,0
; off_3BE2C:
ObjBE_SubObjData:
	;subObjData ObjBE_MapUnc_3BE46,make_art_tile(ArtTile_ArtNem_WfzGunPlatform,3,1),4,4,$18,0
; off_3C08E:
ObjC0_SubObjData:
	;subObjData ObjC0_MapUnc_3C098,make_art_tile(ArtTile_ArtNem_WfzLaunchCatapult,1,0),4,4,$10,0
; off_3C3B8:
ObjC2_SubObjData:
	;subObjData ObjC2_MapUnc_3C3C2,make_art_tile(ArtTile_ArtNem_WfzSwitch,1,1),4,4,$10,0
; off_3BECE:
ObjBE_SubObjData2:
	;subObjData ObjBF_MapUnc_3BEE0,make_art_tile(ArtTile_ArtNem_WfzUnusedBadnik,3,1),4,4,4,4

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 1C - Bridge stake in Emerald Hill Zone and Hill Top Zone, falling oil in Oil Ocean Zone
; ----------------------------------------------------------------------------
; Sprite_111D4:
Obj_ZoneDecor_S1:
Obj_ZoneDecor_S2:
Obj1C:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj1C_Index(pc,d0.w),d1
	jmp	Obj1C_Index(pc,d1.w)
; ===========================================================================
; off_111E2:
Obj1C_Index:	offsetTable
		offsetTableEntry.w Obj1C_Init		; 0
		offsetTableEntry.w BranchTo_MarkObjGone	; 2
; ===========================================================================

objsubdecl macro frame, mapaddr,artaddr,width,priority
	dc.l frame<<24|mapaddr
	dc.w artaddr
	dc.b width, priority
    endm

Obj1C_InitData_S1:
	objsubdecl 0, Obj1C_MapUnc_SLZCannon,  make_art_tile(ArtTile_Nem_SLZCannon,0,0), 8, 2	;SLZ Fire Launchers
	objsubdecl 0, Obj1C_MapUnc_SLZCannon,  make_art_tile(ArtTile_Nem_SLZCannon,0,0), 8, 2	;SLZ fire launcher duplicate? (Likely unused)
	objsubdecl 0, Obj1C_MapUnc_SLZCannon,  make_art_tile(ArtTile_Nem_SLZCannon,0,0), 8, 2	;SLZ Fire (3 of them, lol)
	objsubdecl 1, Obj11_MapUnc_GHZ,  make_art_tile(ArtTile_ArtNem_GHZ_Bridge,0,0), 4, 1	;GHZ Bridge Posts

	;Scen_Values:
		;dc.l Map_Scen		; mappings address
		;dc.w $44D8		; VRAM setting
		;dc.b 0,	8, 2, 0		; frame, width,	priority, collision response

		;dc.l Map_Scen
		;dc.w $44D8
		;dc.b 0,	8, 2, 0

		;dc.l Map_Scen
		;dc.w $44D8
		;dc.b 0,	8, 2, 0

		;dc.l Map_Bri
		;dc.w $438E
		;dc.b 1,	$10, 1,	0
		;even

; dword_111E6:
Obj1C_InitData:
	objsubdecl 0, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,2,0), 4, 6				;0
	objsubdecl 1, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,2,0), 4, 6				;1
	objsubdecl 1, Map_EHZTensionBridge,  make_art_tile(ArtTile_ArtNem_EHZ_Bridge,2,0), 4, 1				;2
	objsubdecl 2, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,1,0), $10, 6			;3
	objsubdecl 3, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), 8, 4				;4
	objsubdecl 4, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), 8, 4				;5
	objsubdecl 1, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), $20, 1				;6
	objsubdecl 0, Obj1C_MapUnc_113D6, make_art_tile(ArtTile_ArtKos_LevelArt,2,0), 8, 1					;7
	objsubdecl 1, Obj1C_MapUnc_113D6, make_art_tile(ArtTile_ArtKos_LevelArt,2,0), 8, 1					;8
	objsubdecl 0, Obj1C_MapUnc_113EE, make_art_tile(ArtTile_ArtUnc_Waterfall3,2,0), 4, 4				;9
	objsubdecl 0, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;A
	objsubdecl 1, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;B
	objsubdecl 2, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;C
	objsubdecl 3, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;D
	objsubdecl 4, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;E
	objsubdecl 5, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4					;F
	objsubdecl 0, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), $18, 4				;10
	objsubdecl 1, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), $18, 4				;11
	objsubdecl 2, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4					;12
	objsubdecl 3, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4					;13
	objsubdecl 4, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4					;14

	;objsubdecl 1, Obj11_MapUnc_ARZ, make_art_tile(ArtTile_ArtNem_ARZBarrierThing,0,0), 4, 1				;15		;Custom Bridge post for ARZ alt
	;objsubdecl 0, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;16		;EHZ Future Techno Stuff.
	;objsubdecl 1, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;17		;EHZ Future Techno Stuff.
	;objsubdecl 2, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;18		;EHZ Future Techno Stuff.
	;objsubdecl 3, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;19		;EHZ Future Techno Stuff.
	;objsubdecl 4, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,1), 4, 0		;1A		;EHZ Future Techno Bush cover
	;objsubdecl 5, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,1), 4, 0		;1B		;EHZ Future Techno Bush cover 2
	;objsubdecl 6, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;1C		;EHZ Future Techno Flower (low priority)
	;objsubdecl 7, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,1), 4, 0		;1D		;EHZ Future Techno Flower (high priority)
	;objsubdecl 8, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;1E		;EHZ Future Techno Smol Pipe Top
	;objsubdecl 9, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;1F		;EHZ Future Techno Smol Pipe Bottom
	;objsubdecl $A, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;20		;EHZ Future Techno Smol Pipe 10 long
	;objsubdecl $B, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;21		;EHZ Future Techno Smol Pipe 9 long
	;objsubdecl $C, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;22		;EHZ Future Techno Smol Pipe 8 long
	;objsubdecl $D, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;23		;EHZ Future Techno Smol Pipe 7 long
	;objsubdecl $E, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;24		;EHZ Future Techno Smol Pipe 6 long
	;objsubdecl $F, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;25		;EHZ Future Techno Smol Pipe 5 long
	;objsubdecl $10, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;26		;EHZ Future Techno Smol Pipe 4 long
	;objsubdecl $11, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;27		;EHZ Future Techno Smol Pipe 3 long
	;objsubdecl $12, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;28		;EHZ Future Techno Smol Pipe 2 long
	;objsubdecl $13, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;29		;EHZ Future Techno Smol Pipe 1.5 long
	;objsubdecl $14, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;2A		;EHZ Future Techno Smol Greebling combo 1
	;objsubdecl $15, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;2B		;EHZ Future Techno Smol Greebling combo 2
	;objsubdecl $16, Obj1C_MapUnc_EHZF_Greebling, make_art_tile(ArtTile_ArtNem_EHZ_Future_Greebling,0,0), 4, 7		;2C		;EHZ Future Techno Smol Greebling combo 3
	;objsubdecl 0, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 32, 7		;2D		;MTZFG decor objects (grass pot)
	;objsubdecl 1, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 32, 0		;2E		;MTZFG decor objects (grass pot high priority)
	;objsubdecl 2, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 32+16, 7		;2F		;MTZFG decor objects (sprinkler)
	;objsubdecl 3, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 32+16, 7		;30		;MTZFG decor objects (sprinkler ceiling)
	;objsubdecl 4, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;31		;MTZFG decor objects (pipe segment)
	;objsubdecl 5, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;32		;MTZFG decor objects (pipe segment)
	;objsubdecl 6, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;33		;MTZFG decor objects (pipe segment)
	;objsubdecl 7, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;34		;MTZFG decor objects (pipe segment)
	;objsubdecl 8, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;35		;MTZFG decor objects (water spray)
	;objsubdecl 9, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;36		;MTZFG decor objects (sprinkler 2)
	;objsubdecl $A, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;37		;MTZFG decor objects (sprinkler 2 ceiling)
	;objsubdecl $A, Obj1C_MapUnc_MTZFG_Decor, make_art_tile(0,0,0), 16, 0		;38		;MTZFG decor objects (sprinkler 2 ceiling)
	;objsubdecl $D, Obj80_MapUnc_MTZ, make_art_tile(ArtTile_ArtNem_MtzChainLift,0,0), 48, 0		;39		;MTZ Chain Lift Base
	;objsubdecl 1, Map_EHZTensionBridge,  make_art_tile(ArtTile_ArtNem_EHZ_Bridge,3,0), 4, 1		;3A     ;EHZ Bad Future Bridge
	even

; byte_1128E:
Obj1C_Radii:
	dc.b   0
	dc.b   0	; 1
	dc.b   0	; 2
	dc.b   0	; 3
	dc.b   0	; 4
	dc.b   0	; 5
	dc.b   0	; 6
	dc.b   0	; 7
	dc.b   0	; 8
	dc.b   0	; 9
	dc.b   0	; 10
	dc.b   0	; 11
	dc.b   0	; 12
	dc.b $30	; 13
	dc.b $40	; 14
	dc.b $60	; 15
	dc.b   0	; 16
	dc.b   0	; 17
	dc.b $30	; 18
	dc.b $40	; 19
	dc.b $50	; 20
	dc.b   0	; 21	;$15
	dc.b   0	; $16
	dc.b   0	; $17
	dc.b   0	; $18
	dc.b   0	; $19
	dc.b   0	; $1A
	dc.b   0	; $1B
	even
; ===========================================================================
; loc_112A4:
Obj1C_Init:
	;cmp.b    #emerald_hill_zone_f_bad,(Current_zone).w    ;are we in EHZFB?
    ;bne.s    Obj1C_Init_SpawnNormally    ;if not, spawn normally
    ;cmp.b    #2,subtype(a0)    ;are we the bridge post subtype (I think its' 2?)?
    ;bne.s    Obj1C_Init_DeleteSelf    ;if not, delete self

    ;move.b #$3A,subtype(a0)    ;use new bridge post for bad future
    ;bra  Obj1C_Init_SpawnNormally
;Obj1C_Init_DeleteSelf:
    ;jmp    DeleteObject    ;despawn ourselves

Obj1C_Init_SpawnNormally:
	addq.b	#2,routine(a0)
	moveq	#0,d0
	move.b	subtype(a0),d0
	move.w	d0,d1
	lsl.w	#3,d0

	lea	Obj1C_InitData_S1(pc),a1	;Load S1 data
	BranchIfS1	Obj1C_Init_AfterLoadingData		;if sonic 1, use S1 data instead of S2 data

	lea	Obj1C_InitData(pc),a1	;Load S2 data

Obj1C_Init_AfterLoadingData:
	lea	(a1,d0.w),a1
	move.b	(a1),mapping_frame(a0)
	move.l	(a1)+,mappings(a0)
	move.w	(a1)+,art_tile(a0)
	;bsr.w	Adjust2PArtPointer
	ori.b	#4,render_flags(a0)
	move.b	(a1)+,width_pixels(a0)
	move.b	(a1)+,priority(a0)
	lea	Obj1C_Radii(pc),a1
	move.b	(a1,d1.w),d1
	beq.s	BranchTo_MarkObjGone	; if the radius is zero, branch
	move.b	d1,y_radius(a0)
	bset	#4,render_flags(a0)

BranchTo_MarkObjGone 
	jmp	MarkObjGone

;Mappings scatter throughout S2 used by Obj1C (ZoneDecor). Should be filled in as new zones and objects are implemented.
Obj1C_MapUnc_11552:
Obj1C_MapUnc_SLZCannon:
Obj11_MapUnc_GHZ:
Obj16_MapUnc_21F14:
Obj1C_MapUnc_113D6:
Obj1C_MapUnc_113EE:

Obj1C_MapUnc_11406
Obj1C_MapUnc_114AE

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 49 - Waterfall from EHZ
; ----------------------------------------------------------------------------
; Sprite_20B9E:
Obj_EHZ_Waterfall:
Obj49:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj49_Index(pc,d0.w),d1
	jmp	Obj49_Index(pc,d1.w)
; ===========================================================================
; off_20BAC:
Obj49_Index:	offsetTable
		offsetTableEntry.w Obj49_Init	; 0
		offsetTableEntry.w Obj49_ChkDel	; 2
; ===========================================================================
; loc_20BB0: Obj49_Main:
Obj49_Init:
	addq.b	#2,routine(a0)
	move.l	#Obj49_MapUnc_20C50,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_Waterfall,1,0),art_tile(a0)
	;jsr	(Adjust2PArtPointer).l
	move.b	#4,render_flags(a0)		;render in world space
	move.b	#$20,width_pixels(a0)
	move.w	x_pos(a0),objoff_30(a0)	;backup spawn x pos (but we never move??? And it's never referenced)
	move.b	#0*$80,priority(a0)		;high priority
	move.b	#$80,y_radius(a0)		;tall
	bset	#4,render_flags(a0)	;render in world space... again?
; loc_20BEA:
Obj49_ChkDel:
	;tst.w	(Two_player_mode).w
	;bne.s	+
	;sonic 1 era despawn code, gross
	;move.w	x_pos(a0),d0
	;andi.w	#$FF80,d0
	;sub.w	(Camera_X_pos_coarse).w,d0
	;cmpi.w	#$280,d0
	;bhi.w	JmpTo18_DeleteObject
	jsr	MarkObjGone3	;needed for S3K compat
;+
	move.w	x_pos(a0),d1		;get x pos in d1
	move.w	d1,d2				;save to d2
	subi.w	#$40,d1				;subtract $40 from x pos
	addi.w	#$40,d2				;add $40 to other x pos (so left and right edges?)
	move.b	subtype(a0),d3		;get subtype in d3
	move.b	#0,mapping_frame(a0)	;clear mapping frame (0 is upper waterfall edge/lip)
	move.w	(MainCharacter+x_pos).w,d0	;get player x pos in d0
	cmp.w	d1,d0				;is player x pos equal to left edge x pos?
	blo.s	loc_20C36			;if less, branch
	cmp.w	d2,d0				;is player x pos equal to right edge x pos?
	bhs.s	loc_20C36			;if higher, branch
	move.b	#1,mapping_frame(a0)	;use frame 1 instead of 0
	add.b	d3,mapping_frame(a0)	;add subtype as frame offset
	jmp	(DisplaySprite).l
; ===========================================================================

;if player 1 is not in bounds, check for player 2 instead.
loc_20C36:
	move.w	(Sidekick+x_pos).w,d0	;get player 2 x pos

	;pretty much the same bounds check as before
	cmp.w	d1,d0
	blo.s	Obj49_Display
	cmp.w	d2,d0
	bhs.s	Obj49_Display
	move.b	#1,mapping_frame(a0)
; loc_20C48:
Obj49_Display:
	add.b	d3,mapping_frame(a0)
	jmp	(DisplaySprite).l
; ===========================================================================
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj49_MapUnc_20C50:	INCLUDE "LevelsS2\EHZ\Misc Object Data\Map - Waterfall.asm"



; ===========================================================================
; ----------------------------------------------------------------------------
; Object 56 - EHZ boss
; the bottom part of the vehicle with the ability to fly is the parent object
; ----------------------------------------------------------------------------
; Sprite_2EF18:
Obj_EHZBoss:
Obj56:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj56_Index(pc,d0.w),d1
	jmp	Obj56_Index(pc,d1.w)
; ===========================================================================
; off_2EF26:
Obj56_Index:	offsetTable
		offsetTableEntry.w Obj56_Init	; 0 - Init
		offsetTableEntry.w loc_2F262	; 2 - Flying vehicle, bottom = main object
		offsetTableEntry.w loc_2F54E	; 4 - Propeller normal
		offsetTableEntry.w loc_2F5F6	; 6 - Vehicle on ground
		offsetTableEntry.w loc_2F664	; 8 - Wheels
		offsetTableEntry.w loc_2F7F4	; A - Spike
		offsetTableEntry.w loc_2F52A	; C - Propeller after defeat
		offsetTableEntry.w loc_2F8DA	; E - Flying vehicle, top
; ===========================================================================

; #7,status(ax) set via collision response routine (Touch_Enemy_Part2)
; 	when after a hit collision_property(ax) = hitcount has reached zero
; objoff_2A(ax) used as timer (countdown)
; objoff_2C(ax) tertiary rountine counter
; #0,objoff_2D(ax) set when robotnik is on ground
; #1,objoff_2D(ax) set when robotnik is active (moving back & forth)
; #2,objoff_2D(ax) set when robotnik is flying off after being defeated
;	#3,objoff_2D(ax) flag to separate spike from vehicle
; objoff_2E(ax)	y_position of wheels
;	objoff_34(ax) parent object
; objoff_3C(ax)	timer after defeat

Obj_EHZBoss_Timer = objoff_32	;objoff_2A
Obj_EHZBoss_Routine3 = objoff_48	;objoff_2C
Obj_EHZBoss_State = objoff_47	;objoff_2D	;Seems to be only a byte? Could put at an odd position.
Obj_EHZBoss_Wheel_y_pos = objoff_2E		;Seems to be fine here. I have not labeled them all x3
Obj_EHZBoss_Parent		=	objoff_34	;^
Obj_EHZBoss_DefeatTimer	=	objoff_44;objoff_3C	;Conflicts with routine_secondary in S3K!

; loc_2EF36:
Obj56_Init:
	move.l	#Obj56_MapUnc_2FAF8,mappings(a0)	; main object
	move.w	#make_art_tile(ArtTile_ArtNem_Eggpod_1,1,0),art_tile(a0) ; vehicle with ability to fly, bottom part
	ori.b	#4,render_flags(a0)
	move.b	#$81,subtype(a0) 
	move.w	#$29D0,x_pos(a0)
	move.w	#$426,y_pos(a0)
	move.b	#$20,width_pixels(a0)
	move.b	#$14,y_radius(a0)
	move.w	#4*$80,priority(a0)
	move.b	#$F,collision_flags(a0)
	move.b	#8,collision_property(a0)	; hitcount
	addq.b	#2,routine(a0)
	move.w	x_pos(a0),objoff_30(a0)
	move.w	y_pos(a0),objoff_38(a0)
	;jsr	(Adjust2PArtPointer).l
	jsr	(SingleObjLoad2).l	; vehicle with ability to fly, top part
	bne.w	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; link top and bottom to each other
	move.l	a1,objoff_34(a0)	; i.e. addresses for cross references
	move.l	#Obj56_MapUnc_2FAF8,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_Eggpod_1,0,0),art_tile(a1)
	move.b	#4,render_flags(a1)
	move.b	#$20,width_pixels(a1)
	move.w	#4*$80,priority(a1)
	move.l	x_pos(a0),x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	move.b	#$E,routine(a1)
	move.b	#1,anim(a1)	; normal animation
	move.b	render_flags(a0),render_flags(a1)
+
	jsr	(SingleObjLoad2).l	; Vehicle on ground
	bne.s	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2FA58,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EHZBoss,0,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$30,width_pixels(a1)
	move.b	#$10,y_radius(a1)
	move.w	#3*$80,priority(a1)
	move.w	#$2AF0,x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	move.b	#6,routine(a1)
+
	bsr.w	loc_2F098
	subi_.w	#8,objoff_38(a0)
	move.w	#$2AF0,x_pos(a0)
	move.w	#$2F8,y_pos(a0)
	jsr	(SingleObjLoad2).l	; propeller normal
	bne.s	+	; rts

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2F970,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EggChoppers,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$40,width_pixels(a1)
	move.w	#3*$80,priority(a1)
	move.l	x_pos(a0),x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	move.w	#$1E,Obj_EHZBoss_Timer(a1)
	move.b	#4,routine(a1)
+
	rts
; ---------------------------------------------------------------------------

loc_2F098:
	jsr	(SingleObjLoad2).l	; first foreground wheel
	bne.s	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2FA58,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EHZBoss,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$10,width_pixels(a1)
	move.w	#2*$80,priority(a1)
	move.b	#$10,y_radius(a1)
	move.b	#$10,x_radius(a1)
	move.w	#$2AF0,x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	addi.w	#$1C,x_pos(a1)
	addi.w	#$C,y_pos(a1)
	move.b	#8,routine(a1)
	move.b	#4,mapping_frame(a1)
	move.b	#1,anim(a1)
	move.w	#$A,Obj_EHZBoss_Timer(a1)
	move.b	#0,subtype(a1) 
+
	jsr	(SingleObjLoad2).l	; second foreground wheel
	bne.s	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2FA58,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EHZBoss,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$10,width_pixels(a1)
	move.w	#2*$80,priority(a1)
	move.b	#$10,y_radius(a1)
	move.b	#$10,x_radius(a1)
	move.w	#$2AF0,x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	addi.w	#-$C,x_pos(a1)
	addi.w	#$C,y_pos(a1)
	move.b	#8,routine(a1)
	move.b	#4,mapping_frame(a1)
	move.b	#1,anim(a1)
	move.w	#$A,Obj_EHZBoss_Timer(a1)
	move.b	#1,subtype(a1) 
+
	jsr	(SingleObjLoad2).l	; background wheel
	bne.s	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2FA58,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EHZBoss,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$10,width_pixels(a1)
	move.w	#3*$80,priority(a1)
	move.b	#$10,y_radius(a1)
	move.b	#$10,x_radius(a1)
	move.w	#$2AF0,x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	addi.w	#-$2C,x_pos(a1)
	addi.w	#$C,y_pos(a1)
	move.b	#8,routine(a1)
	move.b	#6,mapping_frame(a1)
	move.b	#2,anim(a1)
	move.w	#$A,Obj_EHZBoss_Timer(a1)
	move.b	#2,subtype(a1) 
+
	jsr	(SingleObjLoad2).l	; Spike
	bne.s	+

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2FA58,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EHZBoss,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$20,width_pixels(a1)
	move.w	#2*$80,priority(a1)
	move.w	#$2AF0,x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	addi.w	#-$36,x_pos(a1)
	addi_.w	#8,y_pos(a1)
	move.b	#$A,routine(a1)
	move.b	#1,mapping_frame(a1)
	move.b	#0,anim(a1)
+
	rts
; ===========================================================================

loc_2F262:	; Obj56_VehicleMain:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_2F270(pc,d0.w),d1
	jmp	off_2F270(pc,d1.w)
; ---------------------------------------------------------------------------
off_2F270:	offsetTable
		offsetTableEntry.w loc_2F27C	; 0 - approaching diagonally
		offsetTableEntry.w loc_2F2A8	; 2 - final approaching stage (vertically/waiting)
		offsetTableEntry.w loc_2F304	; 4 - moving back and forth
		offsetTableEntry.w loc_2F336	; 6 - boss defeated, falling/lying on ground
		offsetTableEntry.w loc_2F374	; 8 - boss idle for $C frames
		offsetTableEntry.w loc_2F38A	; A - flying off, moving camera
; ===========================================================================

loc_2F27C:	; Obj56_VehicleMain_Sub0:
	move.b	#0,collision_flags(a0)
	cmpi.w	#$29D0,x_pos(a0)	; reached the point to unite with bottom vehicle?
	ble.s	loc_2F29A
	subi_.w	#1,x_pos(a0)
	addi_.w	#1,y_pos(a0)	; move diagonally down
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F29A:
	move.w	#$29D0,x_pos(a0)
	addq.b	#2,routine_secondary(a0)	; next routine
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F2A8:	; Obj56_VehicleMain_Sub2:
	moveq	#0,d0
	move.b	Obj_EHZBoss_Routine3(a0),d0	; tertiary routine
	move.w	off_2F2B6(pc,d0.w),d1
	jmp	off_2F2B6(pc,d1.w)
; ---------------------------------------------------------------------------
off_2F2B6:	offsetTable
		offsetTableEntry.w loc_2F2BA	; 0 - moving down to ground vehicle vertically
		offsetTableEntry.w loc_2F2E0	; 2 - not moving, delay until activation
; ---------------------------------------------------------------------------

loc_2F2BA:	; Obj56_VehicleMain_Sub2_0:
	cmpi.w	#$41E,y_pos(a0)
	bge.s	loc_2F2CC
	addi_.w	#1,y_pos(a0)	; move vertically (down)
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F2CC:
	addq.b	#2,Obj_EHZBoss_Routine3(a0)	; tertiary routine
	bset	#0,Obj_EHZBoss_State(a0)	; robotnik on ground (relevant for propeller)
	move.w	#$3C,Obj_EHZBoss_Timer(a0)	; timer for standing still
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F2E0:	; Obj56_VehicleMain_Sub2_2:
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; timer
	bpl.w	JmpTo35_DisplaySprite
	move.w	#-$200,x_vel(a0)
	addq.b	#2,routine_secondary(a0)
	move.b	#$F,collision_flags(a0)
	bset	#1,Obj_EHZBoss_State(a0)	; boss now active and moving
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F304:	; Obj56_VehicleMain_Sub4:
	bsr.w	loc_2F4A6	; routine to handle hits
	bsr.w	loc_2F484	; position check, sets direction
	move.w	objoff_2E(a0),d0	; y_position of wheels
	lsr.w	#1,d0
	subi.w	#$14,d0
	move.w	d0,y_pos(a0)	; set y_pos depending on wheels
	move.w	#0,objoff_2E(a0)
	move.l	x_pos(a0),d2
	move.w	x_vel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.l	d2,x_pos(a0)	; set x_pos depening on velocity
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F336:	; Obj56_VehicleMain_Sub6:
	subq.w	#1,Obj_EHZBoss_DefeatTimer(a0)	; timer set after defeat
	bmi.s	loc_2F35C	; if countdown finished
	bsr.w	Boss_LoadExplosion
	jsr	(ObjectMoveAndFall).l
	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.w	JmpTo35_DisplaySprite
	add.w	d1,y_pos(a0)
	move.w	#0,y_vel(a0)	; set to ground and stand still
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F35C:
	clr.w	x_vel(a0)
	addq.b	#2,routine_secondary(a0)
	move.w	#-$26,Obj_EHZBoss_DefeatTimer(a0)
	move.w	#$C,Obj_EHZBoss_Timer(a0)
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F374:	; Obj56_VehicleMain_Sub8:
	subq.w	#1,Obj_EHZBoss_Timer(a0)	; timer
	bpl.w	JmpTo35_DisplaySprite
	addq.b	#2,routine_secondary(a0)
	move.b	#0,Obj_EHZBoss_Routine3(a0)	; tertiary routine
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F38A:	; Obj56_VehicleMain_SubA:
	moveq	#0,d0
	move.b	Obj_EHZBoss_Routine3(a0),d0	; tertiary routine
	move.w	off_2F39C(pc,d0.w),d1
	jsr	off_2F39C(pc,d1.w)
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================
off_2F39C:	offsetTable
		offsetTableEntry.w loc_2F3A2	; 0 - initialize propellor
		offsetTableEntry.w loc_2F424	; 2 - waiting
		offsetTableEntry.w loc_2F442	; 4 - flying off
; ===========================================================================

loc_2F3A2:	; Obj56_VehicleMain_SubA_0:
	bclr	#0,Obj_EHZBoss_State(a0)	; robotnik off ground
	jsr	(SingleObjLoad2).l	; reload propeller after defeat
	bne.w	+	; rts

	move.l	#Obj_EHZBoss,code(a1) ; load obj56
	move.l	a0,objoff_34(a1)	; linked to main object
	move.l	#Obj56_MapUnc_2F970,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_EggChoppers,1,0),art_tile(a1)
	;jsr	(Adjust2PArtPointer2).l
	move.b	#4,render_flags(a1)
	move.b	#$20,width_pixels(a1)
	move.w	#3*$80,priority(a1)
	move.l	x_pos(a0),x_pos(a1)
	move.l	y_pos(a0),y_pos(a1)
	addi.w	#$C,y_pos(a1)
	move.b	status(a0),status(a1)
	move.b	render_flags(a0),render_flags(a1)
	move.b	#$C,routine(a1)	
	move.b	#2,anim(a1)
	move.w	#$10,Obj_EHZBoss_Timer(a1)	; timer
	move.w	#$32,Obj_EHZBoss_Timer(a0)	; timer
	addq.b	#2,Obj_EHZBoss_Routine3(a0)	; tertiary routine - increase
	jsr		(PlayLevelMusic).l ; play level Music
	move.b	#1,(Boss_defeated_flag).w
+
	rts
; ===========================================================================

loc_2F424:	; Obj56_VehicleMain_SubA_2:
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; timer
	bpl.s	+	; rts
	bset	#2,Obj_EHZBoss_State(a0)	; robotnik flying off
	move.w	#$60,Obj_EHZBoss_Timer(a0)	; timer
	addq.b	#2,Obj_EHZBoss_Routine3(a0)	; tertiary routine
	jsr	(LoadPLC_AnimalExplosion).l ; PLC_Explosion
+
	rts
; ===========================================================================

loc_2F442:	; Obj56_VehicleMain_SubA_4:
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; timer
	bpl.s	loc_2F45C
	bset	#0,status(a0)
	bset	#0,render_flags(a0)
	addq.w	#6,x_pos(a0)
	bra.s	loc_2F460
; ===========================================================================

loc_2F45C:
	subq.w	#1,y_pos(a0)

loc_2F460:
	cmpi.w	#$2AB0,(Camera_Max_X_pos).w
	bhs.s	loc_2F46E
	addq.w	#2,(Camera_Max_X_pos).w
	bra.s	return_2F482
; ===========================================================================

loc_2F46E:
	tst.b	render_flags(a0)
	bmi.s	return_2F482
	addq.w	#4,sp
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	jsr	(DeleteObject2).l
	jmp	(DeleteObject).l
; ===========================================================================

return_2F482:
	rts
; ===========================================================================

loc_2F484:	; shared routine, checks positions and sets direction
	move.w	x_pos(a0),d0
	cmpi.w	#$28A0,d0	; beyond left boundary?
	ble.s	loc_2F494
	cmpi.w	#$2B08,d0
	blt.s	return_2F4A4	; beyond right boundary?

loc_2F494:	; beyond boundary
	bchg	#0,status(a0)	; change direction
	bchg	#0,render_flags(a0)	; mirror sprite
	neg.w	x_vel(a0)	; change direction of velocity

return_2F4A4:
	rts
; ===========================================================================

loc_2F4A6:	; routine to handle hits
	cmpi.b	#6,routine_secondary(a0)	; is only called when value is 4?
	bhs.s	return_2F4EC	; thus unnecessary? (return if greater or equal than 6)
	tst.b	status(a0)
	bmi.s	loc_2F4EE	; sonic has just defeated the boss (i.e. bit 7 set)
	tst.b	collision_flags(a0)	; set to 0 when boss was hit by Touch_Enemy_Part2
	bne.s	return_2F4EC	; not 0, i.e. boss not hit
	tst.b	objoff_3E(a0)
	bne.s	loc_2F4D0	; boss already invincibile
	move.b	#$20,objoff_3E(a0)	; boss invincibility timer
	move.w	#SndID_BossHit,d0
	jsr	(PlaySound).l	; play boss hit sound

loc_2F4D0:
	lea	(Normal_palette_line2+2).w,a1
	moveq	#0,d0	; black
	tst.w	(a1)
	bne.s	loc_2F4DE	; already not black (i.e. white)?
	move.w	#$EEE,d0	; white

loc_2F4DE:
	move.w	d0,(a1)	; set respective color
	subq.b	#1,objoff_3E(a0)	; decrease boss invincibility timer
	bne.s	return_2F4EC
	move.b	#$F,collision_flags(a0)	; if invincibility ended, allow collision again

return_2F4EC:
	rts
; ===========================================================================

loc_2F4EE:	;	boss defeated
	moveq	#100,d0
	jsr	(AddPoints).l	; add 1000 points, reward for defeating boss
	move.b	#6,routine_secondary(a0)
	move.w	#0,x_vel(a0)
	move.w	#-$180,y_vel(a0)
	move.w	#$B3,Obj_EHZBoss_DefeatTimer(a0)	; timer
	bset	#3,Obj_EHZBoss_State(a0)	; flag to separate spike from vehicle
	movea.l	objoff_34(a0),a1 ; address top part
	move.b	#4,anim(a1)	; flying off animation
	move.b	#6,mapping_frame(a1)
	;move.b	#1,(Disable_Pause_Menu_Flag).w	;disable the pause menu so it doesn't muckup the art we're loading.
	;move.w	#1,(CapsuleGraphicsLoadFlag).w
	move.w	#PLCID_Capsule,d0
	jmp	(LoadPLC).l	; load egg prison
; ===========================================================================
	rts
; ===========================================================================

loc_2F52A:	; Obj56_PropellerReloaded:	; Propeller after defeat
	subi_.w	#1,y_pos(a0)	; move up
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; decrease timer
	bpl.w	JmpTo35_DisplaySprite
	move.b	#4,routine(a0)	; Propeller normal
	lea	(Ani_obj56_a).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F54E:	; Obj56_Propeller:	; Propeller normal
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_2F55C(pc,d0.w),d1
	jmp	off_2F55C(pc,d1.w)
; ---------------------------------------------------------------------------
off_2F55C:	offsetTable
		offsetTableEntry.w loc_2F560	; 0 - robotnik in air
		offsetTableEntry.w loc_2F5C6	; 2 - robotnik on ground
; ---------------------------------------------------------------------------

loc_2F560:	; Obj56_Propeller_Sub0
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	cmpi.l	#Obj_EHZBoss,code(a1)
	bne.w	JmpTo52_DeleteObject	; if boss non-existant
	btst	#0,Obj_EHZBoss_State(a1)	; is robotnik on ground?
	beq.s	loc_2F58E	; if not, branch
	move.b	#1,anim(a0)
	move.w	#$18,Obj_EHZBoss_Timer(a0)	; timer until deletion
	addq.b	#2,routine_secondary(a0)
	move.b	#MusID_StopSFX,d0
	jsr	(PlaySound).l
	bra.s	loc_2F5A0
; ---------------------------------------------------------------------------

loc_2F58E:	; not on ground
	move.b	(Vint_runcount+3).w,d0
	andi.b	#$1F,d0
	bne.s	loc_2F5A0
	move.b	#SndID_Helicopter,d0
	jsr	(PlaySound).l

loc_2F5A0:
	move.w	x_pos(a1),x_pos(a0)
	move.w	y_pos(a1),y_pos(a0)
	move.b	status(a1),status(a0)
	move.b	render_flags(a1),render_flags(a0)
	lea	(Ani_obj56_a).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F5C6:	; Obj56_Propeller_Sub2
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; timer
	bpl.s	loc_2F5E8
	cmpi.w	#-$10,Obj_EHZBoss_Timer(a0)
	ble.w	JmpTo52_DeleteObject
	move.w	#4*$80,priority(a0)
	addi_.w	#1,y_pos(a0)	; move down
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F5E8:
	lea	(Ani_obj56_a).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F5F6:	; Obj56_GroundVehicle:
	tst.b	routine_secondary(a0)
	bne.s	loc_2F626
; Obj56_GroundVehicle_Sub0:
	cmpi.w	#$28F0,(Camera_Min_X_pos).w
	blo.w	JmpTo35_DisplaySprite
	cmpi.w	#$29D0,x_pos(a0)
	ble.s	loc_2F618
	subi_.w	#1,x_pos(a0)
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F618:
	move.w	#$29D0,x_pos(a0)
	addq.b	#2,routine_secondary(a0)
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F626:	; Obj56_GroundVehicle_Sub2:
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	btst	#1,Obj_EHZBoss_State(a1)
	beq.w	JmpTo35_DisplaySprite	; boss not moving yet (inactive)
	btst	#2,Obj_EHZBoss_State(a1)	; robotnik flying off flag
	bne.w	JmpTo35_DisplaySprite
	move.w	x_pos(a1),x_pos(a0)
	move.w	y_pos(a1),y_pos(a0)
	addi_.w	#8,y_pos(a0)
	move.b	status(a1),status(a0)
	bmi.w	JmpTo35_DisplaySprite
	move.b	render_flags(a1),render_flags(a0)
	bra.w	JmpTo35_DisplaySprite
; ===========================================================================

loc_2F664:	; Obj56_Wheel:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	off_2F672(pc,d0.w),d1
	jmp	off_2F672(pc,d1.w)
; ---------------------------------------------------------------------------
off_2F672:	offsetTable
		offsetTableEntry.w loc_2F67C	; 0 - wheels moving towards start position
		offsetTableEntry.w loc_2F714	; 2 - standing still (boss inactive)
		offsetTableEntry.w loc_2F746	; 4 - normal mode (boss active)
		offsetTableEntry.w loc_2F7A6	; 6 - inactive while defeat
		offsetTableEntry.w loc_2F7D2	; 8 - wheels bouncing away after defeat
; ---------------------------------------------------------------------------

loc_2F67C:	; Obj56_Wheel_Sub0:
	cmpi.w	#$28F0,(Camera_Min_X_pos).w
	blo.w	JmpTo35_DisplaySprite
	move.w	#$100,y_vel(a0)
	cmpi.b	#1,subtype(a0)	; wheel number (0-2)
	bgt.s	loc_2F6B6	; background wheel
	beq.s	loc_2F6A6	; second foreground wheel
; ---------------------------------------------------------------------------
	cmpi.w	#$29EC,x_pos(a0)	; first foreground wheel
	ble.s	loc_2F6C6
	subi_.w	#1,x_pos(a0)
	bra.s	loc_2F6E8

loc_2F6A6:	; second foreground wheel
	cmpi.w	#$29C4,x_pos(a0)
	ble.s	loc_2F6D2
	subi_.w	#1,x_pos(a0)
	bra.s	loc_2F6E8

loc_2F6B6:	; background wheel
	cmpi.w	#$29A4,x_pos(a0)
	ble.s	loc_2F6DE
	subi_.w	#1,x_pos(a0)
	bra.s	loc_2F6E8
; ---------------------------------------------------------------------------

loc_2F6C6:	; first foreground wheel
	move.w	#$29EC,x_pos(a0)
	addq.b	#2,routine_secondary(a0)
	bra.s	loc_2F6E8

loc_2F6D2:	; second foreground wheel
	move.w	#$29C4,x_pos(a0)
	addq.b	#2,routine_secondary(a0)
	bra.s	loc_2F6E8

loc_2F6DE:	; background wheel
	move.w	#$29A4,x_pos(a0)
	addq.b	#2,routine_secondary(a0)
; ---------------------------------------------------------------------------

loc_2F6E8:	; routine for all wheels
	jsr	(ObjectMoveAndFall).l
	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.s	loc_2F6FA
	add.w	d1,y_pos(a0)	; reset on floor

loc_2F6FA:
	tst.b	routine_secondary(a0)
	beq.s	loc_2F706
	move.w	#-$200,x_vel(a0)	; if reached position, set velocity

loc_2F706:
	lea	(Ani_obj56_b).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F714:	; Obj56_Wheel_Sub2:
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	cmpi.l	#Obj_EHZBoss,code(a1)
	bne.w	JmpTo52_DeleteObject	; if boss non-existant
	btst	#1,Obj_EHZBoss_State(a1)
	beq.w	JmpTo35_DisplaySprite	; boss not moving yet (inactive)
	addq.b	#2,routine_secondary(a0)
	cmpi.w	#2*$80,priority(a0)
	bne		BranchTo_JmpTo35_DisplaySprite
	move.w	y_pos(a0),d0
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	add.w	d0,objoff_2E(a1)

BranchTo_JmpTo35_DisplaySprite 
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F746:	; Obj56_Wheel_Sub4:
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	cmpi.l	#Obj_EHZBoss,code(a1)
	bne.w	JmpTo52_DeleteObject	; if boss non-existant
	move.b	status(a1),status(a0)
	move.b	render_flags(a1),render_flags(a0)
	tst.b	status(a0)
	bpl.s	loc_2F768	; has sonic just defeated the boss (i.e. bit7 set)?
	addq.b	#2,routine_secondary(a0)	; if yes, Sub6

loc_2F768:
	bsr.w	loc_2F484	; position check, sets direction
	jsr	(ObjectMoveAndFall).l
	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.s	loc_2F77E
	add.w	d1,y_pos(a0)	; reset on floor

loc_2F77E:
	move.w	#$100,y_vel(a0)
	cmpi.w	#2*$80,priority(a0)
	bne		loc_2F798_S2
	move.w	y_pos(a0),d0
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	add.w	d0,objoff_2E(a1)

loc_2F798_S2:
	lea	(Ani_obj56_b).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F7A6:	; Obj56_Wheel_Sub6:
	subi_.w	#1,Obj_EHZBoss_Timer(a0)	; timer, initially set to $A (first delay until wheels rolling off)
	bpl.w	JmpTo35_DisplaySprite
	addq.b	#2,routine_secondary(a0)	; Sub8
	move.w	#$A,Obj_EHZBoss_Timer(a0)
	move.w	#-$300,y_vel(a0)	; first bounce higher
	cmpi.w	#2*$80,priority(a0)
	beq.w	JmpTo35_DisplaySprite
	neg.w	x_vel(a0)	; into other direction
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F7D2:	; Obj56_Wheel_Sub8:
	subq.w	#1,Obj_EHZBoss_Timer(a0)	; timer, initially set to $A (second delay until wheels rolling off)
	bpl.w	JmpTo35_DisplaySprite
	jsr	(ObjectMoveAndFall).l
	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.s	BranchTo_JmpTo36_MarkObjGone
	move.w	#-$200,y_vel(a0)	; negative velocity to have bouncing effect
	add.w	d1,y_pos(a0)	; reset on floor

BranchTo_JmpTo36_MarkObjGone 
	jmp	(MarkObjGone).l
; ===========================================================================

loc_2F7F4:	; Obj56_Spike:
	jsr		Add_SpriteToCollisionResponseList	;Collision only works if this is called every frame.
	tst.b	routine_secondary(a0)
	bne.s	loc_2F824
; Obj56_Spike_Sub0:
	cmpi.w	#$28F0,(Camera_Min_X_pos).w
	blo.w	JmpTo35_DisplaySprite
	cmpi.w	#$299A,x_pos(a0)
	ble.s	loc_2F816
	subi_.w	#1,x_pos(a0)
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F816:
	move.w	#$299A,x_pos(a0)
	addq.b	#2,routine_secondary(a0)
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F824:	; Obj56_Spike_Sub2:
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	cmpi.l	#Obj_EHZBoss,code(a1)
	bne.w	JmpTo52_DeleteObject	; if boss non-existant
	btst	#3,Obj_EHZBoss_State(a1)
	bne.s	loc_2F88A	; spike separated from vehicle
	bsr.w	loc_2F8AA
	btst	#1,Obj_EHZBoss_State(a1)
	beq.w	JmpTo35_DisplaySprite	; boss not moving yet (inactive)
	move.b	#$8B,collision_flags(a0)	; spike still linked to vehicle
	move.w	x_pos(a1),x_pos(a0)
	move.w	y_pos(a1),y_pos(a0)
	move.b	status(a1),status(a0)	; transfer positions
	move.b	render_flags(a1),render_flags(a0)
	addi.w	#$10,y_pos(a0)	; vertical offset
	move.w	#-$36,d0
	btst	#0,status(a0)
	beq.s	loc_2F878
	neg.w	d0

loc_2F878:
	add.w	d0,x_pos(a0)	; horizontal offset
	lea	(Ani_obj56_b).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F88A:	; spike separated from vehicle
	move.w	#-3,d0	; velocity of spike in pixels/frame
	btst	#0,status(a0)	; check direction
	beq.s	loc_2F898
	neg.w	d0

loc_2F898:
	add.w	d0,x_pos(a0)
	lea	(Ani_obj56_b).l,a1
	jsr	(AnimateSprite).l
	bra.w	JmpTo35_DisplaySprite
; ---------------------------------------------------------------------------

loc_2F8AA:
	cmpi.b	#1,collision_property(a1)	; hit counter, only 1 life left?
	beq.s	loc_2F8B4
	rts
; ---------------------------------------------------------------------------

loc_2F8B4:
	move.w	x_pos(a0),d0
	sub.w	(MainCharacter+x_pos).w,d0
	bpl.s	loc_2F8C8
	btst	#0,status(a1)	; sonic right from spike
	bne.s	loc_2F8D2	; spike facing right
	rts
; ---------------------------------------------------------------------------

loc_2F8C8:
	btst	#0,status(a1)	; sonic left from spike
	beq.s	loc_2F8D2	; spike facing left
	rts
; ---------------------------------------------------------------------------

loc_2F8D2:
	bset	#3,Obj_EHZBoss_State(a1)	; flag to separate spike from vehicle
	rts
; ===========================================================================

loc_2F8DA:	; Obj56_VehicleTop:
	movea.l	objoff_34(a0),a1 ; parent address (vehicle)
	move.l	x_pos(a1),x_pos(a0)
	move.l	y_pos(a1),y_pos(a0)
	move.b	status(a1),status(a0)	; update position and status
	move.b	render_flags(a1),render_flags(a0)
	move.b	objoff_3E(a1),d0	; boss invincibility timer
	cmpi.b	#$1F,d0	; boss just got hit?
	bne.s	loc_2F906
	move.b	#2,anim(a0)	; robotnik animation when hit

loc_2F906:
	cmpi.b	#4,(MainCharacter+routine).w	; Sonic = ball
	beq.s	loc_2F916
	cmpi.b	#4,(Sidekick+routine).w	; Tails = ball
	bne.s	loc_2F924

loc_2F916:
	cmpi.b	#2,anim(a0)	; check eggman animation (when hit)
	beq.s	loc_2F924
	move.b	#3,anim(a0)	; eggman animation when hurting sonic

loc_2F924:
	lea	(Ani_obj56_c).l,a1	; animation script
	jsr	(AnimateSprite).l
	jmp	(DisplaySprite).l
; ===========================================================================
; animation script
; off_2F936:
Ani_obj56_a:	offsetTable
		offsetTableEntry.w byte_2F93C	; 0
		offsetTableEntry.w byte_2F940	; 1
		offsetTableEntry.w byte_2F956	; 2
byte_2F93C:
	dc.b   1,  5,  6,$FF
byte_2F940:
	dc.b   1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  4,  4,  4,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,$FF; 16
byte_2F956:
	dc.b   1,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  3,  3,  3,  2
	dc.b   2,  2,  1,  1,  1,  5,  6,$FE,  2
	even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2F970:	BINCLUDE "LevelsS2\EHZ\Misc Object Data\Map - Boss Propellers.bin"
	; propeller
	; 7 frames
	
; animation script
; off_2FA44:
Ani_obj56_b:	offsetTable
		offsetTableEntry.w byte_2FA4A	; 0
		offsetTableEntry.w byte_2FA4F	; 1
		offsetTableEntry.w byte_2FA53	; 2
byte_2FA4A:
	dc.b   5,  1,  2,  3,$FF	; spike
byte_2FA4F:
	dc.b   1,  4,  5,$FF	; foreground wheel
byte_2FA53:
	dc.b   1,  6,  7,$FF	; background wheel
	even

; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2FA58:	INCLUDE "LevelsS2\EHZ\Misc Object Data\Map - Boss Drill Car.asm"
	; ground vehicle
	; frame 0 = vehicle itself
	; frame 1-3 = spike
	;	frame 4-5 = foreground wheel
	; frame 6-7 = background wheel

; animation script
; off_2FAC8:
Ani_obj56_c:	offsetTable
		offsetTableEntry.w byte_2FAD2	; 0
		offsetTableEntry.w byte_2FAD5	; 1
		offsetTableEntry.w byte_2FAD9	; 2
		offsetTableEntry.w byte_2FAE2	; 3
		offsetTableEntry.w byte_2FAEB	; 4
byte_2FAD2:	dc.b  $F,  0,$FF	; bottom
byte_2FAD5:	dc.b   7,  1,  2,$FF	; top, normal
byte_2FAD9:	dc.b   7,  5,  5,  5,  5,  5,  5,$FD,  1	;	top, when hit
byte_2FAE2:	dc.b   7,  3,  4,  3,  4,  3,  4,$FD,  1	; top, laughter (when hurting sonic)
byte_2FAEB:	dc.b  $F,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,$FD,  1	; top, when flying off
	even	; for top part, after end of special animations always return to normal one ($FD->1)

; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj56_MapUnc_2FAF8:	INCLUDE "LevelsS2\EHZ\Misc Object Data\Map - Boss Ship.asm"
	; flying vehicle
	; frame 0 = bottom
	; frame 1-2 = top, normal
	; frame 3-4 = top, laughter
	; frame 5 = top, when hit
	; frame 6 = top, when flying off
; ===========================================================================

JmpTo52_DeleteObject 
	jmp	(DeleteObject).l
JmpTo35_DisplaySprite 
	jmp	(DisplaySprite).l


;I'm not sure if there is an equivalent! S3K has lots of special cases x3
;Should perhaps port this.
Boss_LoadExplosion:
	rts