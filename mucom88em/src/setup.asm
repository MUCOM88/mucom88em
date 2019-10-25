;==========================================================================
; MUCOM88 Extended Memory Edition (MUCOM88em)
; ファイル名 : setup.asm
; 機能 : 
; 更新日：2019/10/22
;==========================================================================
; ※本ソースはMUSICLALF Ver.1.0～1.2共通のsetup.asmを元に作成した物です。
;==========================================================================;==========================================================================
	
	
	ORG	0C000H
	
NOTSB2:	EQU	0FFF8H
TXTEND:	EQU	0EB18H
S.ILVL:	EQU	0E6C3H
	
; **	ﾜﾘｺﾐ ｾｯﾃｲ/ﾎﾞｰﾄﾞ ﾁｪｯｸ ｿﾉﾀ	**
	
START:
	XOR	A
	LD	(NOTSB2),A
	
	LD	HL,TYPE1
	LD	DE,M_VECTR
	LDI
	LDI
	LDI
	
	LD	C,044H
	CALL	STT1
	DEC	A
	JR	Z,STTE
	LD	C,0A8H
	CALL	STT1
	DEC	A
	JR	Z,STT2
	LD	(NOTSB2),A
	JR	STTE
STT2:
	LD	HL,TYPE2
	LD	DE,M_VECTR
	LDI
	LDI
	LDI
	JR	STTE
	
; --	CHECK BORD TYPE	--
	
STT1:
	LD	A,0FFH
	OUT	(C),A
	PUSH	BC
	POP	BC
	INC	BC
	IN	A,(C)
	RET
	
STTE:
	RET
	
	
M_VECTR:EQU	0FFFCH
TYPE1:	DB	032H,044H,046H
TYPE2:	DB	0AAH,0A8H,0ACH
FNUMB:
	DW	6A02H,8F02H,0B602H,0DF02H,0B03H,3903H
	DW	6A03H,9E03H,0D503H,1004H,4E04H,8F04H
