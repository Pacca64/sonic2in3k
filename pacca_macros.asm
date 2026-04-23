; macro for detecting a Sonic 2 Zone ID.
BranchIfS2 macro BranchToIfS2
	cmp.b   #emerald_hill_zone,(Current_zone).w ;are we in Emerald Hill Zone?
    bhs     BranchToIfS2    ;if yes or higher, branch.
    endm

; macro for detecting a Sonic 2 Zone ID.
BranchIfNOTS2 macro BranchToIfS2
	cmp.b   #emerald_hill_zone,(Current_zone).w ;are we in Emerald Hill Zone?
    blo     BranchToIfS2    ;if yes or higher, branch.
    endm


;copied from S2, hope it works! Pawbs crossed x3
make_block_tile function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|(addr&tile_mask)