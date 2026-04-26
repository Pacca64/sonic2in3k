; macro for detecting a Sonic 2 Zone ID.
BranchIfS2 macro BranchToIfS2
	cmp.b   #emerald_hill_zone,(Current_zone).w ;are we in Emerald Hill Zone?
    bhs     BranchToIfS2    ;if yes or higher, branch.
    endm

; macro for detecting a Sonic 2 Zone ID.
BranchIfNOTS2 macro BranchToIfNotS2
	cmp.b   #emerald_hill_zone,(Current_zone).w ;are we in Emerald Hill Zone?
    blo     BranchToIfNotS2    ;if lower, branch.
    endm

; Some S1 macros for behavior that is intended for Sonic 1 in S2CDR code, even though S1 is not implemented in S123K yet.
; So They'll be blank until that happens.

 ; macro for detecting a Sonic 1 Zone ID.
BranchIfS1 macro BranchToIfS1
    endm

; macro for detecting a Sonic 1 Zone ID.
BranchIfNOTS1 macro BranchToIfNotS1
	bra	BranchToIfNotS1
    endm


;copied from S2, hope it works! Pawbs crossed x3
make_block_tile function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|(addr&tile_mask)

; macro to declare sub-object data for Sonic 2
subObjData macro mappings,vram,renderflags,priority,width,collision
	dc.l mappings
	dc.w vram
	dc.b renderflags,priority,width,collision
    endm



;macros copied from S2 disasembly that are not engine specific, but make code in general easier to work with and port.

; macro to declare an offset table
offsetTable macro {INTLABEL}
current_offset_table := __LABEL__
__LABEL__ label *
    endm

; macro to declare an entry in an offset table
offsetTableEntry macro ptr
	dc.ATTRIBUTE ptr-current_offset_table
    endm


; macro to move the absolute value of the source in the destination
mvabs macro source,destination
	move.ATTRIBUTE	source,destination
	bpl.s	.skip
	neg.ATTRIBUTE	destination
.skip:
    endm

;these could be toggled for more accurate or more efficient variants in the S2 Disasm
;We just default to the more efficient version. Makes moving code faster.
	; regular meaning to the assembler; better but unlike original
_move	macro
		!move.ATTRIBUTE ALLARGS
	endm
_add	macro
		!add.ATTRIBUTE ALLARGS
	endm
_addq	macro
		!addq.ATTRIBUTE ALLARGS
	endm
_cmp	macro
		!cmp.ATTRIBUTE ALLARGS
	endm
_cmpi	macro
		!cmpi.ATTRIBUTE ALLARGS
	endm
_clr	macro
		!clr.ATTRIBUTE ALLARGS
	endm
_tst	macro
		!tst.ATTRIBUTE ALLARGS
	endm

; depending on if relativeLea is set or not, this will create a pc-relative lea or an absolute long lea.
lea_ macro address,reg
	!lea address(pc),reg
    endm

; if addsubOptimize, optimize these
addi_	macro
		!addq.ATTRIBUTE ALLARGS
	endm
subi_	macro
		!subq.ATTRIBUTE ALLARGS
	endm
adda_	macro
		!addq.ATTRIBUTE ALLARGS
	endm
