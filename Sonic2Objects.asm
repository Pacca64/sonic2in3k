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
	;tst.w	(Two_player_mode).w
	;beq.s	Obj06_ChkDel
	;rts

; ---------------------------------------------------------------------------
; loc_214DA:
;Obj06_ChkDel:
	;move.w	x_pos(a0),d0
	;andi.w	#$FF80,d0
	;sub.w	(Camera_X_pos_coarse).w,d0
	;cmpi.w	#$280,d0
	;bhi.s	JmpTo19_DeleteObject
	;rts
; ---------------------------------------------------------------------------
;JmpTo19_DeleteObject 
	;jmp	(DeleteObject).l

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
    blo.s   Obj06_Spiral_CharacterFallsOff_whenTooSlow  ;if not, run normal code.
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
	beq.s	return_215BE	;if not, rts. Seems to be some kind of failsafe.
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