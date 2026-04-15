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