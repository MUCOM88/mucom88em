;==========================================================================
; MUSICLALF Ver.1.2(MUCOM88 Ver.1.7)�Ή�
; �t�@�C���� : music2.asm (Z80�A�Z���u���\�[�X)
; �@�\ : ���t���[�`��(�g���ݗp)
; �X�V�� : 2019/10/23
;==========================================================================
; ���{�\�[�X��MUSICLALF Ver.1.0��music2���獷���C���ɂč쐬�������ł��B
;==========================================================================
	
	
	
VRTC:	EQU	0F302H
R_TIME:	EQU	0F304H
INT3:	EQU	0F308H
S.ILVL:	EQU	0E6C3H
MAXCH:		EQU	11
	
MUSNUM:	EQU	0C200H	; �ް� � ���� ���ڽ
PCMADR:	EQU	0E300H	; ADPCM�ް�ð��� � ���� ���ڽ
EFCTBL:	EQU	0AA00H	; ����� � ���� ���ڽ
	
OTODAT:	EQU	MUSNUM+1
MU_TOP:	EQU	MUSNUM+5
	
	
	ORG 0B000H
	
	
	JP	MSTART
	JP	MSTOP
	JP	FDO
	JP	EFC
	JP	RETW
	
FLGADR: DB	0	;#n
	
	
; **	RETURN WORK ADR	**
	
	;IN:	A<-���������(0-10)
	;EXIT:	IX
RETW:
	LD	IX,CH1DAT
	OR	A
	RET	Z
	LD	DE,CH2DAT-CH1DAT
RETW2:
	ADD	IX,DE
	DEC	A
	RET	Z
	JR	RETW2
	
; **	EFC FROM BASIC	**
	
	;USR(n):	n=0<->max255
EFC:
	
	CP	2
	RET	NZ
	CALL	21A0H	;FACC->BIN
	LD	H,1	;PRI
	CALL	EFECT
	RET
	
	
; **	EFECT	***
	
	;IN:	H<=��ײ��è
	;	L<=EFC ����
	
EFECT:
	LD	A,(PRISSG)
	CP	H
	JR	Z,EFECT2
	RET	NC
EFECT2:
	DI
	LD	A,H
	LD	(PRISSG),A
	LD	A,L
	ADD	A,A
	LD	L,A
	LD	H,0
	LD	DE,EFCTBL
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	DE,0
	LD	A,1
	LD	(CH6DAT+2),HL
	LD	(CH6DAT+4),DE
	LD	(CH6DAT),A
	LD	IX,CH6DAT
	LD	HL,DMY
	CALL	NOISE
	EI
	RET
	
	
	
; **	MUSIC START/STOP	**
	
;	IN: A<= MUSIC NUMBER (0->)
	
MSTART:
	LD	A,0	;!
	
	DI
	LD	(MUSNUM),A
	CALL	CHK
	CALL	AKYOFF
	CALL	SSGOFF
	CALL	WORKINIT
START:
	PUSH	HL
	CALL	INT57
	CALL	ENBL
	CALL	TO_NML
	POP	HL
	EI
	RET
MSTOP:
	DI
	CALL	AKYOFF
	CALL	SSGOFF
	LD	A,(M_VECTR)
	LD	C,A
	IN	A,(C)
	OR	10000000B
	OUT	(C),A
	EI
	RET
	
	
; **	FADEOUT		**
	
FDO:
	LD	A,16
	LD	(FDCO),A
	RET
FDOUT:
	LD	HL,FDCO+1
	DEC	(HL)
	RET	NZ
	LD	(HL),16
	LD	A,(FDCO)
	OR	A
	RET	Z
	DEC	A
	LD	(FDCO),A
FDO2:
	ADD	A,0F0H
	LD	(TOTALV),A
	XOR	A
	LD	(FMPORT),A
	LD	IX,CH1DAT
	CALL	FDOFM
	LD	B,3
FDOSSG:
	PUSH	BC
	LD	A,(IX+6)
	LD	C,A
	AND	11110000B
	LD	E,A
	LD	A,C
	AND	00001111B
	LD	C,A
	CALL	PV1
	LD	DE,WKLENG
	ADD	IX,DE
	POP	BC
	DJNZ	FDOSSG
	
	CALL	DVOLSET
	
	LD	A,4
	LD	(FMPORT),A
	LD	DE,WKLENG
	ADD	IX,DE
	CALL	FDOFM
	
	LD	A,(FDCO)
	OR	A
	JR	Z,FDO3
	RET
FDOFM:
	LD	B,3
FDL2:
	PUSH	BC
	CALL	STVOL
	LD	DE,WKLENG
	ADD	IX,DE
	POP	BC
	DJNZ	FDL2
	LD	B,3
	RET
FDO3:
	CALL	MSTOP
	XOR	A
	LD	(TOTALV),A
	RET
	

; **	�غ� � ���� ��� �����ò � ��ų	**

INT57:
	PUSH	AF
	PUSH	HL
	LD	A,5
	;LD	(S.ILVL),A
	OUT	(0E4H),A	;  CUT INT 5-7
	LD	A,3
	OUT	(0E6H),A	;  VRTC=ON;RTCLOCK=ON;USART=OFF
	LD	A,I
	LD	H,A
	LD	L,8
	LD	DE,PL_SND
	LD	(HL),E
	INC	HL
	LD	(HL),D
	
	CALL	TO_NML
INT573:
	CALL	MONO
	
	CALL	AKYOFF		;  ALL KEY OFF
	CALL	SSGOFF
	
	LD	DE,2983H	; CH 4-6 ENABLE
	CALL	PSGOUT
	
        LD	DE,0
	LD	B,6
INITF2:
	CALL	PSGOUT
	INC	D
	DJNZ	INITF2
	
	LD	D,7
	LD	E,00111000B
	CALL	PSGOUT
	LD	HL,INITPM
	LD	DE,PREGBF
	LD	BC,9
	LDIR			; PSG�ޯ̧ �Ƽ�ײ��
	
	POP	HL
	POP	AF
	RET

; **	Э��ޯ� �غ� ENABLE	**

ENBL:
	LD	A,(TIMER_B)
	LD	E,A
	CALL	STTMB		;  SET Timer-B

	LD	A,(M_VECTR)
	LD	C,A
	IN	A,(C)
	AND	7FH
	OUT	(C),A
	RET
	
; **	ALL MONORAL / H.LFO OFF	***
	
MONO:
	LD	D,0B4H
	LD	E,0C0H
	XOR	A
	LD	(FMPORT),A
	LD	B,3
MONO2:
	CALL	PSGOUT
	INC	D
	DJNZ	MONO2
	
	LD	D,018H
        LD	B,6
MONO3:
	CALL	PSGOUT
	INC	D
	DJNZ	MONO3
	
	LD	B,3
	LD	D,0B4H
	LD	A,4
	LD	(FMPORT),A
MONO4:
	CALL	PSGOUT
	INC	D
	DJNZ	MONO4
	
	XOR	A
	LD	(FMPORT),A
	
	LD	DE,2200H
	CALL	PSGOUT
	LD	DE,1200H
	CALL	PSGOUT
	
	LD	HL,PALDAT
	LD	B,7
MONO5:
	LD	(HL),0C0H
	INC	HL
	DJNZ	MONO5
	
	LD	A,3
	LD	(PCMLR),A
	RET
	
; **	MUSIC MAIN	**

PL_SND:
	DI
	PUSH	AF
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	IX
	PUSH	IY
	
PLSET1:
 	LD	E,38H		;  TIMER-OFF DATA
 	LD	D,27H
  	CALL	PSGOUT		;  TIMER-OFF
PLSET2:
	LD	E,3AH
	CALL	PSGOUT		;  TIMER-ON

	CALL	DRIVE
	CALL	FDOUT
PLSND3:
	
	;LD	A,(S.ILVL)
	LD	A,5
	OUT	(0E4H),A	;CUT INT 5-7
	
	POP	IY
	POP	IX
	POP	BC
	POP	DE
	POP	HL
	POP	AF
	
	EI
	RET
	
; **	CALL FM		**
	
DRIVE:
	XOR	A
	LD	(FMPORT),A
	
	LD	IX,CH1DAT
	CALL	FMENT
	LD	IX,CH2DAT
	CALL	FMENT
	LD	IX,CH3DAT
	CALL	FMENT
	
; **	CALL SSG	**
	
	LD	A,0FFH
	LD	(SSGF1),A
	
 	LD	IX,CH4DAT
  	CALL	SSGENT
 	LD	IX,CH5DAT
 	CALL	SSGENT
 	LD	IX,CH6DAT
 	CALL	SSGENT
	XOR	A
	LD	(SSGF1),A
	
	LD	A,(NOTSB2)
	OR	A
	RET	NZ
	
	INC	A
	LD	(DRMF1),A
	LD	IX,DRAMDAT
	CALL	FMENT
	XOR	A
	LD	(DRMF1),A
	
	LD	A,4
	LD	(FMPORT),A
	LD	IX,CHADAT
	CALL	FMENT
	LD	IX,CHBDAT
	CALL	FMENT
	LD	IX,CHCDAT
	CALL	FMENT
	LD	A,0FFH
	LD	(PCMFLG),A
	LD	IX,PCMDAT
	CALL	FMENT
	XOR	A
	LD	(PCMFLG),A
	RET
	
SSGENT:
	CALL	SSGSUB
	CALL	PLLFO
	RET
FMENT:
	CALL	FMSUB
	CALL	PLLFO
	RET
	
;**	FM �ݹ�� � ���� �ݿ� ٰ��	**

FMSUB:
	LD	A,(IX)
	DEC	A
	LD	(IX),A
	JR	Z,FMSUB1
	
	LD	B,(IX+18)	;  'q'
	CP	B
	JR	Z,FMSUB0
	RET	NC

FMSUB0:
	LD	H,(IX+3)
	LD	L,(IX+2)	;  HL=SOUND DATA ADD
	LD	A,(HL)		;  A=DATA
	CP	0FDH		; COUNT OVER ?
	RET	Z
	BIT	5,(IX+33)
	JR	NZ,FS2
	CALL	KEYOFF
	RET
FS2:
	LD	A,(IX+6)
	ADD	A,(IX+17)
	LD	C,A
	SRL	C
	CALL	STV2
	SET	6,(IX+31)	;  SET KEYOFF FLAG
	RET

; **	SET NEW SOUND	**
	
FMSUB1:
	SET	6,(IX+31)
	LD	H,(IX+3)
	LD	L,(IX+2)	; HL=SOUND DATA ADD
	LD	A,(HL)		; A=DATA
	CP	0FDH		; COUNT OVER?
	JR	NZ,FMSUBC
FMSUBE:
	RES	6,(IX+31)	; RES KEYOFF FLAG
	INC	HL
FMSUBC:
	LD	A,(HL)		;
	OR	A		; �ް� ���خ� � �����
	JR	NZ,FMSUB2	;* 00H as end

	SET	0,(IX+31)
	LD	D,(IX+5)
	LD	E,(IX+4)	; HL=DATA TOP ADDRES
	LD	A,E
	OR	D
	JP	Z,FMEND		;* DATA TOP ADRESS �� 0000H �� BGM
				; � ���خ� � ��ò �� ��޲� �ض��
	EX	DE,HL
FMSUBB:
	LD	A,(HL)		; GET FLAG & LENGTH

; **	SET LENGTH	**

FMSUB2:
	INC	HL
	CP	0F0H		;
	JP	NC,FMSUBA	; DATA �� ����� �� FMSUBA �

	RLCA
	SRL	A		; GET CY=7TH BIT (���� �׸�) : A=LENGTH
	LD	(IX),A		; SET WAIT COUNTER
	JP	NC,FMSUB5	; ���� �� FMSUB5 �

; **	SET F-NUMBER	**

FMSUB3:
	LD	(IX+3),H
	LD 	(IX+2),L	; SET NEXT SOUND DATA ADD
	BIT	4,(IX+33)
	JR	NZ,FS3
	BIT	5,(IX+33)
	JR	NZ,FS2
FS3:
	CALL	KEYOFF
	RET

FMSUB5:
	BIT	6,(IX+31)
	CALL	NZ,KEYOFF
	
	LD	A,(PLSET1+1)
	CP	78H
	JR	NZ,FMSUB4
	
	LD	A,(FMPORT)
	OR	A
	JR	NZ,FMSUB4
	LD	A,(IX+8)
	CP	2		; CH=3?
	JP	Z,EXMODE
FMSUB4:
	LD	A,(HL)		; A=BLOCK( OCTAVE-1 ) & KEY CODE DATA
	INC	HL
	LD	(IX+3),H
	LD	(IX+2),L	; SET NEXT SOUND DATA ADD

	LD	B,A		; STORE
	BIT	6,(IX+31)	; CHECK KEYOFF FLAG
	JR	NZ,FMSUB9

	LD	A,(IX+32)	; GET BEFORE CODE DATA
	SUB	B
	JR	NZ,FMSUB9
	SCF
	RET
FMSUB9:
	LD	A,B
	LD	(IX+32),A
	LD	A,(PCMFLG)
	OR	A
	JR	NZ,PCMGFQ
	LD	A,(DRMF1)
	OR	A
	JR	Z,FMGFQ
DRMFQ:
	BIT	6,(IX+31)
	RET	Z
	CALL	DKEYON
	RET
PCMGFQ:
	LD	A,B
	AND	00001111B
	LD	HL,PCMNMB
	ADD	A,A
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	E,(IX+9)
	LD	D,(IX+10)
	ADD	HL,DE
	
	LD	A,B
	AND	11110000B
	RRCA
	RRCA
	RRCA
	RRCA
	LD	B,A
	DEC	B
	INC	B
	JR	Z,ASUB72
ASUB7:
	SRL	H
	RR	L
	DJNZ	ASUB7
ASUB72:
	LD	(DELT_N),HL
	BIT	6,(IX+31)
	JR	NZ,AS72
	CALL	LFORST
AS72:
	CALL	LFORST2
	CALL	PLAY
	RET
FMGFQ:
	LD	A,B
	LD 	C,A		; STORE
	AND 	70H		; GET BLOCK DATA
	SRL	A		; A4-A6 �߰� ���خ�ֳ � �ܾ�
	LD 	B,A

	LD	A,C		; RESTORE A
	AND	0FH		; GET KEY CODE (C,C+,D ... B)

	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,FNUMB
	ADD	HL,DE

	LD	C,(HL)
	INC	HL
	LD	A,(HL)		; GET FNUM2
	OR	B		; A= KEY CODE & FNUM HI

	LD	L,C
	LD	H,A
	LD	D,(IX+10)	;
	LD	E,(IX+9)	; GET DETUNE DATA
	ADD	HL,DE		; DETUNE PLUS
	BIT	6,(IX+33)
	JR	NZ,FMS92
	LD	(IX+29),L	; FOR LFO
	LD	(IX+30),H	; FOR LFO
	
	LD	(FNUM),HL
FMS92:
	BIT	6,(IX+31)
	CALL	NZ,LFORST
	CALL	LFORST2
FMSUB8:
	LD	BC,0
FMSUB6:
	ADD	HL,BC		; BLOCK/FNUM1&2 DETUNE PLUS (for SE MODE)
	LD	E,H		; BLOCK/F-NUMBER2 DATA
FPORT:
	LD	A,0A4H		; PORT A4H
	ADD	A,(IX+8)
	LD	D,A
	CALL	PSGOUT

	SUB	4
	LD	D,A
	LD	E,L		; F-NUMBER1 DATA
FMSUB7:
	CALL	PSGOUT
	CALL	KEYON
        AND	A
	RET

; **	SE MODE � DETUNE ��ò	**

EXMODE:
	LD	BC,(DETDAT)
	LD	B,0
	LD	(FMSUB8+1),BC
	CALL	FMSUB4		; SET OP1
	RET	C

	LD	HL,DETDAT+1
	LD	A,0AAH		;  A = CH3 F-NUM2 OP1 PORT - 2
EXMLP:
	LD	(FPORT+1),A
	INC	A
	PUSH	AF
	LD	C,(HL)
	LD	B,0
	INC	HL
	PUSH	HL
HLSTC0:
	LD	HL,(FNUM)
	CALL	FMSUB6		; SET OP2-OP4

	POP	HL
	POP	AF
	CP	0ADH		; END PORT+1
	JP 	NZ,EXMLP

	LD	A,0A4H
	LD	(FPORT+1),A
BRESET:
	LD	BC,0
	LD	(FMSUB8+1),BC
	RET			;  RET TO MAIN

; **	KEY-OFF ROUTINE		**

KEYOFF:
	LD	A,(PCMFLG)
	OR	A
	JP	NZ,PCMEND
	LD	A,(DRMF1)
	OR	A
	JR	NZ,DKEYOF
	LD	A,(FMPORT)
	ADD	A,(IX+8)
	LD	E,A
	LD	D,28H		;  PORT 28H
	CALL	PSGOUT		;  KEY-OFF
	RET
	
; --	ؽ�� �ݹ�� � ����	--
	
DKEYOF:
	LD	D,10H
	LD	A,(RHYTHM)	; GET RETHM PARAMETER
	AND	00111111B
	OR	80H
	LD	E,A
	CALL	PSGOUT
	RET

; **	KEY-ON  ROUTINE   **

KEYON:
	LD	A,(FMPORT)
	OR	A
	LD	A,0F0H
	JR	Z,KEYON2
	LD	A,0F4H
KEYON2:
	ADD	A,(IX+8)
	LD	E,A
	LD	D,28H
	CALL	PSGOUT		;  KEY-ON
	BIT	5,(IX+33)
	CALL	NZ,STVOL
	RET
	
; **   ؽ�� �ݹ�� � ����   **
	
DKEYON:
	LD	D,10H
	LD	A,(RHYTHM)	; GET RETHM PARAMETER
	AND	00111111B
	LD	E,A		; KEY ON
	CALL	PSGOUT
	RET

; **	ALL KEY-OFF ROUTINE   **

AKYOFF:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	
	LD	E,0
	LD	D,28H
	LD	B,7
AKYOF2:
	CALL	PSGOUT
	INC	E
	DJNZ	AKYOF2
	
	POP	DE
	POP	BC
	POP	AF
	RET

; **	FM DATA OUT ROUTINE	**
;
; ENTRY: D<= REGISTER No.
;	 E<= DATA

PSGOUT:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	
	
	LD	A,(PORT13)
	LD	C,A
	
	LD	A,D
	CP	30H
	JR	C,PSGO4
	LD	A,(FMPORT)
	AND	A
	JR	Z,PSGO4
	
	LD	A,(PORT13+1)
	LD	C,A
PSGO4:
	OUT	(C),D
	PUSH	BC
	POP	BC
	INC	BC
	OUT	(C),E
	
PSGOE:
	POP	HL
	POP	BC
	POP	AF
	RET


; **	��ޥ����� � ��ò	**

FMSUBA:
	AND	0FH		; A=COMMAND No.(0-F)
	LD	DE,FMSUBC
	PUSH	DE		; STORE RETURN ADDRES
	LD	DE,FMCOM
	LD	B,A
	ADD	A,A
	ADD	A,B		; A*3
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A		; DE+A*3
	PUSH	DE
	RET

; **	FM CONTROL COMMAND(s)   **

FMCOM:
	JP	OTOPST		; F0-�ݼ�� ���    '@'
	JP	VOLPST		; F1-VOLUME SET   'v'
	JP	FRQ_DF		; F2-DETUNE(���ʽ� ��׼) 'D'
	JP	SETQ		; F3-SET COMMAND 'q'
	JP	LFOON		; F4-LFO SET
	JP	REPSTF		; F5-REPEAT START SET  '['
	JP	REPENF		; F6-REPEAT END SET    ']'
	JP	MDSET		; F7-FM�ݹ�� Ӱ�޾��
	JP	STEREO		; F8-STEREO MODE
	JP	FLGSET		; F9-FLAG SET
	JP	W_REG		; FA-COMMAND OF   'y'
	JP	VOLUPF		; FB-VOLUME UP    ')'
        JP	HLFOON		; FC-HARD LFO
	JP	TIE		; (CANT USE)
	JP	RSKIP		; FE-REPEAT JUMP'/'
	JP	SECPRC		; FF-to second com
	
FMCOM2:
	JP	PVMCHG		;FFF0-PCM VOLUME MODE
;	JP	HRDENV		;FFF1-HARD ENVE SET 's'		;���C���O
	JP	NTMEAN						;���C����
;	JP	ENVPOD		;FFF2-HARD ENVE PERIOD		;���C���O
	JP	NTMEAN						;���C����
	JP	REVERVE		;FFF3-��ް��
	JP	REVMOD		;FFF4-��ް��Ӱ��
	JP	REVSW		;FFF5-��ް�� ����
	JP	NTMEAN
	JP	NTMEAN
	
SECPRC:
	LD	A,(HL)
	INC	HL
	AND	0FH		; A=COMMAND No.(0-F)
	LD	DE,FMCOM2
	LD	B,A
	ADD	A,A
	ADD	A,B
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	PUSH	DE
	
NTMEAN:
	RET
	
TIE:
	RES	6,(IX+31)
	RET
	
; **	�׸޾��	**
	
FLGSET:
	LD	A,(HL)
	INC	HL
	LD	(FLGADR),A
	RET
	
; **	��ް��	**
	
REVERVE:
	LD	A,(HL)
	INC	HL
	LD	(IX+17),A
RV1:
	SET	5,(IX+33)
        RET
REVSW:
	LD	A,(HL)
	INC	HL
	OR	A
	JR	NZ,RV1
	RES	5,(IX+33)
	CALL	STVOL
	RET
REVMOD:
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,RM2
	SET	4,(IX+33)
	RET
RM2:
	RES	4,(IX+33)
	RET
	
; **	PCM VMODE CHANGE	**
	
PVMCHG:
	LD	A,(HL)
	INC	HL
	LD	(PVMODE),A
	RET
	
; **	STEREO	**
	
STEREO:
	LD	A,(DRMF1)
	OR	A
	JR	NZ,STE2
	LD	A,(PCMFLG)
	OR	A
	JR	Z,STER2
	LD	A,(HL)
	INC	HL
	LD	(PCMLR),A
	RET
STER2:
	LD	A,(HL)
	INC	HL
	RRCA
	RRCA
	LD	C,A
	LD	DE,PALDAT
	LD	A,(FMPORT)
	ADD	A,(IX+8)
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	LD	A,(DE)
	AND	00111111B
	OR	C
	LD	(DE),A
	
	LD	E,A
	LD	A,0B4H
	ADD	A,(IX+8)
	LD	D,A
	CALL	PSGOUT
	RET
STE2:
	LD	A,(HL)
	INC	HL
	LD	C,A
	AND	00001111B
	LD	B,A
	LD	DE,DRMVOL
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	LD	A,(DE)
	PUSH	DE
	AND	00011111B
	LD	E,A
	LD	A,C
	RLCA
	RLCA
	AND	11000000B
	OR	E
	POP	DE
	LD	(DE),A
	LD	E,A
	LD	A,B
	ADD	A,18H
	LD	D,A
	CALL	PSGOUT
	RET
	
	
; **	VOLUME UP & DOWN	**
	
VOLUPF:
	LD	A,(HL)
	INC	HL
	ADD	A,(IX+6)
	LD	(IX+6),A
	LD	A,(PCMFLG)
	OR	A
	RET	NZ
	LD	A,(DRMF1)
	OR	A
	JP	NZ,DVOLSET
	CALL	STVOL
	RET
	
; **	SE DETUNE SET SUB ROUTINE	**

MDSET:
	CALL	TO_EFC
	LD	DE,DETDAT
	LD	BC,4
	LDIR
	RET

; **	HARD LFO SET	**
	
HLFOON:
	LD	A,(HL)	; FREQ CONT
	INC	HL
	OR	00001000B
	LD	E,A
	LD	D,022H
	CALL	PSGOUT
	
	LD	C,(HL)	; PMS
	INC	HL
	LD	A,(HL)	; AMS
	INC	HL
	RLCA
	RLCA
	RLCA
	RLCA
	OR	C
	LD	C,A	; AMS+PMS
	
	LD	A,(FMPORT)
	ADD	A,(IX+8)
	LD	DE,PALDAT
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	LD	A,(DE)
	AND	11000000B
	OR	C
	LD	(DE),A
	
	LD	E,A
	LD	A,0B4H
	ADD	A,(IX+8)
	LD	D,A
	CALL	PSGOUT
	RET
	
; **	SOFT LFO SET(RESET)	**

LFOON:
	LD	A,(HL)		; GET SUB COMMAND
	INC	HL
	
	OR	A
	JP	NZ,LFOON3
	
	CALL	SETDEL
	CALL	SETCO
	CALL	SETVCT
	CALL	SETPEK
	
	SET	7,(IX+31)	;  SET LFO FLAG
	RET
	
LFOON3:
	DEC	A
	LD	C,A
	ADD	A,A
	ADD	A,C
	LD	DE,LFOTBL
	
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	
	PUSH	DE
	RET
	
LFOTBL:
	JP	LFOOFF
	JP	LFOON2
	JP	SETDEL
	JP	SETCO
	JP	SETVC2
	JP	SETPEK
	JP	TLLFO
SETDEL:
	LD	A,(HL)
	INC	HL
	LD 	(IX+19),A	; SET DELAY
	LD	(IX+20),A
	RET
SETCO:
	LD	A,(HL)
	INC	HL
	LD	(IX+21),A	; SET COUNTER
	LD	(IX+22),A
	RET
SETVCT:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(IX+23),E	; SET �ݶخ�
	LD	(IX+25),E
	LD	(IX+24),D
	LD	(IX+26),D
	RET
SETVC2:
	CALL	SETVCT
	JP	LFORST
SETPEK:
	LD	A,(HL)
	INC	HL
	LD	(IX+27),A	; SET PEAK LEVEL
	SRL	A
	LD	(IX+28),A
	RET
	
LFOON2:
	SET	7,(IX+31)	; LFOON
        RET
LFOOFF:
	RES	7,(IX+31)	; RESET LFO
	RET
	
TLLFO:
	LD	A,(HL)
	INC	HL
	OR	A
	JR	NZ,TLL2
	RES	6,(IX+33)
	RET
TLL2:
	LD	(LFOP6+1),A
	SET	6,(IX+33)
	LD	A,(HL)
	INC	HL
	LD	(IX+29),A
	LD	(IX+30),0
	LD	(IX+11),A
	RET
	
; **	SET Q COMMAND	**

SETQ:
	LD	A,(HL)
	INC	HL
	LD	(IX+18),A
	RET

; **	�ݼ�� ��� Ҳ�	**

OTOPST:
	LD	A,(PCMFLG)
	OR	A
	JR	NZ,OTOPCM
	LD	A,(DRMF1)
	OR	A
	JR	NZ,OTODRM
	LD	A,(HL)
	INC	HL
	LD	(IX+1),A
	CALL	STENV
	CALL	STVOL
	RET
OTODRM:
	LD	A,(HL)
	INC	HL
	LD	(RHYTHM),A	; SET RETHM PARA
	RET
OTOPCM:
	LD	A,(HL)
	LD	(PCMNUM),A
	DEC	A
	LD	(IX+1),A
	INC	HL
	ADD	A,A
	ADD	A,A
	ADD	A,A
	PUSH	HL
	LD	HL,PCMADR
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(STTADR),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(ENDADR),DE
	INC	HL
	INC	HL
	LD	E,(HL)
	POP	HL
	LD	A,(PVMODE)
	OR	A
	RET	Z
	LD	(IX+6),E
	RET

; **	��ح�� ���	**

VOLPST:
	LD	A,(PCMFLG)
	OR	A
	JR	NZ,PCMVOL
	LD	A,(DRMF1)
	OR	A
	JR	NZ,VOLDRM
	LD	A,(HL)
	INC	HL
	LD	(IX+6),A
	CALL	STVOL
	RET
	
VOLDRM:
	LD	A,(HL)
	INC	HL
	LD	(IX+6),A
	CALL	DVOLSET
VOLDR1:
	LD	B,6
	LD	DE,DRMVOL
VOLDR2:
	LD	C,(HL)
	LD	A,(DE)
	AND	11000000B
	OR	C
	LD	(DE),A
	
	PUSH	DE
	LD	E,A
	LD	A,B
	SUB	6
	NEG
	LD	D,18H
	ADD	A,D
	LD	D,A
	CALL	PSGOUT
	POP	DE
	
	INC	DE
	INC	HL
	DJNZ	VOLDR2
	RET
PCMVOL:
	LD	E,(HL)
	INC	HL
	LD	A,(PVMODE)
	OR	A
	JR	NZ,PCMV2
	LD	(IX+6),E
	RET
PCMV2:
	LD	(IX+7),E
	RET
	
; --   SET TOTAL RHYTHM VOL	--
	
DVOLSET:
	LD	D,11H
	LD	A,(IX+6)
	AND	00111111B
	LD	E,A
	LD	A,(TOTALV)
	ADD	A,A
	ADD	A,A
	ADD	A,E
	CP	64
	JR	C,DV2
	XOR	A
DV2:
	LD	E,A
	CALL	PSGOUT
	RET
	
; **	������ ���	**

FRQ_DF:
	XOR	A
	LD	(IX+32),A	; DETUNE � �ޱ�� BEFORE CODE � CLEAR
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,FD2
	PUSH	HL
	LD	L,(IX+9)
	LD	H,(IX+10)
	ADD	HL,DE
	EX	DE,HL
	POP	HL
FD2:
	LD	(IX+9),E
	LD	(IX+10),D
	LD	A,(PCMFLG)
	OR	A
	RET	Z
	PUSH	HL
	LD	HL,(DELT_N)
	ADD	HL,DE
	EX	DE,HL
	LD	C,D
	LD	D,09H
	CALL	PCMOUT
	INC	D
	LD	E,C
	CALL	PCMOUT
	POP	HL
	RET

	
; **	��߰� �����	**
	
RSKIP:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	
	PUSH	HL
	DEC	HL
	DEC	HL
	ADD	HL,DE
	LD	A,(HL)
	DEC	A	; LOOP ���� =1?
	JR	Z,RSKIP2
	POP	HL
	RET
RSKIP2:
	LD	DE,4
	ADD	HL,DE	; HL = JUMP ADR
	EX	DE,HL
	POP	HL
	EX	DE,HL
	RET
	
; **	��߰� ���� ���		**
	
REPSTF:
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		; DE as REWRITE ADR OFFSET +1
	INC	HL
	
	PUSH	HL
	DEC	HL
	DEC	HL
	ADD	HL,DE
	LD	A,(HL)
	DEC	HL
	LD	(HL),A
	POP	HL
	
	RET
	
	
; **	��߰� ���� ��� (FM)	**

REPENF:
	
	DEC	(HL)		; DEC REPEAT Co.
	JR	Z,REPENF2
	
	INC	HL
	INC	HL
	
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	HL
	AND	A
	SBC	HL,DE
	RET
	
REPENF2:
	
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	(HL),A
	LD	DE,4
	ADD	HL,DE
	
	RET
	
	
; **	�ݼ�� ��� ���ٰ�� (FM)	**

STENV:
	PUSH	HL

	CALL	KEYOFF
	LD	A,80H
	ADD	A,(IX+8)
	LD	E,00FH
	LD	B,4
ENVLP:
	LD	D,A
	CALL	PSGOUT		; �ذ�(RR) ��� � ���
	ADD	A,4
	DJNZ	ENVLP

	LD	A,(IX+1)	; ܰ� �� �ݼ�� ���ް � ��
STENV0:
	LD	C,A
	
	RRCA
	RRCA
	RRCA
	RRCA			; *16
	LD	H,A
	AND	11110000B
	LD	L,A
	LD	A,H
	AND	00001111B
	LD	H,A		; HL=*16
	
	LD	A,C
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,C		; *9
	
	ADD	A,L
	LD	L,A
	ADC	A,H
	SUB	L
	LD	H,A		; HL=*25
	
	EX	DE,HL
	LD	HL,(OTODAT)
	INC	HL
	ADD	HL,DE		;  HL � �ݼ���ް� ��ɳ ���ڽ
	LD	DE,MUSNUM
	ADD	HL,DE

STENV1:
	LD	BC,0406H	; 4 OPERATER
				; 6 PARAMATER(Det/Mul,Total,KS/AR,DR,SR,SL/RR)
	LD	A,30H		; START=PORT 30H
	ADD	A,(IX+8)	; PLUS CHANNEL No.
	LD	D,A

STENV2:
	PUSH	BC
STENV3:
	LD	E,(HL)		; GET DATA
	CALL	PSGOUT

	INC 	D		;
	INC 	D		;  SKIP BLANK PORT
	INC 	D		;
	INC 	D		;
	INC 	HL

	DJNZ 	STENV3

	POP	BC
	DEC	C
	JP	NZ,STENV2

	LD	A,(HL)		; GET FEEDBACK/ALGORIZM
	LD	E,A
	AND	07H		; GET ALGORIZM
	LD	(IX+7),A	; STORE ALGORIZM
	LD	A,0B0H		; GET ALGO SET ADDRES
	ADD	A,(IX+8)	; CH PLUS
	LD	D,A
	CALL	PSGOUT

	POP	HL
	RET

	
; **	��ح��	**

STVOL:
	PUSH	HL
	PUSH	DE
	PUSH	BC

	CALL	STV1

	POP	BC
	POP	DE
	POP	HL
	RET
STV1:
	LD	C,(IX+6)	; INPUT VOLUME
	LD	A,(TOTALV)
	ADD	A,C
	CP	20
	JR	C,STV12
	XOR	A
STV12:
	LD	C,A
STV2:	LD	B,0
	LD	HL,FMVDAT
	ADD	HL,BC
	LD	E,(HL)		; GET VOLUME DATA
	
	LD	A,40H
	ADD	A,(IX+8)	; GET PORT No.

	LD	HL,CRYDAT
	LD	B,0
	LD	C,(IX+7)	; INPUT ALGOLIZM
	ADD	HL,BC
	LD	C,(HL)		; C=��ر
	LD	B,4		; 4 OPERATER

STVOL2:
	RR	C
	LD	D,A
	CALL	C,PSGOUT	;  ��ر �� PSGOUT �
	ADD	A,4
	DJNZ	STVOL2
	RET

	
; **	Timer-B �������� ٰ��   **

; 	IN: E<= TIMER_B COUNTER
	
STTMB:
	PUSH AF
	PUSH DE
STTMB2:
	
	LD D,26H
	CALL PSGOUT

	LD D,27H
	LD E,78H
	CALL PSGOUT     ;  Timer-B OFF
	LD E,7AH
	CALL PSGOUT     ;  Timer-B ON

	LD A,5
	OUT (0E4H),A

	POP DE
	POP AF
	RET

	
; **	LFO ٰ��	**
	
PLLFO:
	
; ---	FOR FM & SSG LFO	---
	
	BIT	7,(IX+31)	;  CHECK bit 7 ... LFO FLAG
	RET	Z

	LD	L,(IX+2)
	LD	H,(IX+3)
	DEC	HL
	LD 	A,(HL)
	CP	0F0H
	RET	Z	;  ���� � �ް� �� '&' �� RET

	BIT	5,(IX+31)	; LFO CONTINE FLAG
	JR	NZ,CTLFO	; bit 5 = 1 �� LFO ���޸

; **	LFO INITIARIZE   **

        CALL	LFORST
	CALL	LFORST2
	LD	A,(IX+21)
	LD	(IX+22),A
	SET	5,(IX+31)	; SET CONTINUE FLAG
	
CTLFO:
	LD	A,(IX+20)
	OR	A
	JR	Z,CTLFO1
	DEC	A
	LD	(IX+20),A
	RET
CTLFO1:
	DEC	(IX+22)	;����
	RET	NZ
	
	LD	A,(IX+21)
	LD	(IX+22),A	;���� �� ��ò
	LD	A,(IX+28)	;  GET PEAK LEVEL COUNTER (P.L.C)
	OR	A
	JR	NZ,PLLFO1	;  P.L.C > 0 �� PLLFO1

	AND	A
	LD	HL,0
	LD	D,(IX+26)
	LD	E,(IX+25)
	SBC	HL,DE
	LD	(IX+26),H
	LD	(IX+25),L	; WAVE ����
	LD	A,(IX+27)
	LD	(IX+28),A	;  P.L.C �� ��ò

PLLFO1:
	DEC	(IX+28)		; P.L.C.-1
	LD	L,(IX+25)
	LD	H,(IX+26)
	CALL	PLS2
	RET
PLS2:
	LD	A,(PCMFLG)
	OR	A
	JR	Z,PLSKI2
	LD	DE,(DELT_N)
	ADD	HL,DE
	LD	(DELT_N),HL
	LD	D,09H
	LD	E,L
	CALL	PCMOUT
	INC	D
	LD	E,H
	CALL	PCMOUT
	RET
PLSKI2:
	LD	E,(IX+29)	;  GET FNUM1
	LD	D,(IX+30)	;  GET B/FNUM2
	ADD	HL,DE		;  HL= NEW F-NUMBER
	LD	(IX+29),L	; SET NEW F-NUM1
	LD	(IX+30),H	; SET NEW F-NUM2
	LD	A,(SSGF1)
	OR	A
	JR	Z,LFOP5
	
; ---	FOR SSG	LFO	---
	
	LD	A,(IX+32)	; GET KEY CODE&OCTAVE
	
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	
	OR	A		;  OCTAVE=1?
	JR	Z,SSLFO2
	LD	B,A
	
SNUMGETL:
	
	SRL	H
	RR	L
	DJNZ	SNUMGETL

SSLFO2:
	LD	E,L
	LD	D,(IX+8)
	CALL	PSGOUT

	INC	D
	LD	E,H
	CALL	PSGOUT

	RET
	
; ---	FOR FM LFO	---
	
LFOP5:
	BIT	6,(IX+33)
	JR	NZ,LFOP6
	BIT	1,(IX+8)	;  CH=3?
	JR	Z,PLLFO2	; NOT CH3 THEN PLLFO2
	LD	A,(PLSET1+1)
	CP	78H
	JR	NZ,PLLFO2	; NOT SE MODE
	LD	(NEWFNM),HL
LFOP4:
	LD	HL,DETDAT
	LD	IY,OP_SEL
	LD	B,4
LFOP3:
	PUSH	BC
	LD	DE,(NEWFNM)
	LD	C,(HL)
	LD	B,0
	INC	HL
	EX	DE,HL
	ADD	HL,BC
	
	PUSH	DE
	LD	E,H
	LD	D,(IY)
	INC	IY
	CALL	PSGOUT
	DEC	D
	DEC	D
	DEC	D
	DEC	D
	LD	E,L
	CALL	PSGOUT
	POP	DE
	EX	DE,HL
	POP	BC
	DJNZ	LFOP3
	RET
PLLFO2:
	LD	E,H
	LD	A,0A4H	;  PORT A4H
	ADD	A,(IX+8)
	LD	D,A
	CALL	PSGOUT
	SUB	4
	LD	E,L	;  F-NUMBER1 DATA
	LD	D,A
	CALL	PSGOUT
	RET
	
LFOP6:
	LD	C,1
	LD	A,40H
	ADD	A,(IX+8)
	LD	E,L
	BIT	0,C
	CALL	NZ,LFP62
	BIT	2,C
	CALL	NZ,LFP62
	BIT	1,C
	CALL	NZ,LFP62
	BIT	3,C
	RET	Z
LFP62:
	LD	D,A
	CALL	PSGOUT
	ADD	A,4
	RET
	
; ---	RESET PEAK L.&DELAY	---
	
LFORST:
	LD	A,(IX+19)
	LD	(IX+20),A	; LFO DELAY � ����ò
	RES	5,(IX+31)	; RESET LFO CONTINE FLAG
	RET
LFORST2:
	LD	A,(IX+27)
	SRL	A
	LD	(IX+28),A	; LFO PEAK LEVEL �� ��ò
	LD	A,(IX+23)	;
	LD	(IX+25),A	; �ݶخ� ����ò
	LD	A,(IX+24)	;
	LD	(IX+26),A
	BIT	6,(IX+33)
	RET	Z
	LD	A,(IX+11)
	LD	(IX+29),A
	LD	(IX+30),0
	RET
	
SSG:
; **	SSG �ݹ�ݴݿ� ٰ��   **

SSGSUB:
	LD	A,(IX)
	DEC	A
	LD	(IX),A
	JR	Z,SSSUB7

	LD	B,(IX+18)	;  'q'
	CP	B
	JR	NZ,SSSUB0
	
	LD	H,(IX+3)
	LD	L,(IX+2)	;  HL=SOUND DATA ADD
	LD	A,(HL)		;  A=DATA
	CP	0FDH		; COUNT OVER?
	JR	Z,SSUB0
	CALL	SSSUBA		; TO REREASE
	RET
SSUB0:
 	RES	6,(IX+31)	;  SET TIE FLAG
SSSUB0:
	BIT 	7,(IX+6)	; ENVELOPE CHECK
	RET 	Z
	CALL	SOFENV
	LD	E,A
	LD	D,(IX+7)
	CALL	PSGOUT
	RET
	
SSSUB7:
	LD	H,(IX+3)
	LD	L,(IX+2)	;  HL AS SOUND DATA ADD
	LD	A,(HL)		;  A=DATA
	CP	0FDH		; COUNT OVER?
	JR	NZ,SSSUBE
SSUB1:
	RES	6,(IX+31)	;  SET TIE FLAG
	INC	HL
	JP	SSSUBB
SSSUBE:
	SET	6,(IX+31)
SSSUBB:
	LD	A,(HL)
	OR	A	;  CHECK END MARK
	JR	NZ,SSSUB2
	SET	0,(IX+31)
	LD	D,(IX+5)
	LD	E,(IX+4)	;  HL=DATA TOP ADD
	LD	A,E
	OR	D
	JP	Z,SSGEND
	EX	DE,HL
SSSUB1:
	LD	A,(HL)	;  INPUT FLAG &LENGTH
	
SSSUB2:
	INC	HL
	CP	0F0H	;  COMMAND OF PSG?
 	JP	NC,SSSUB8
	
	RLCA
	SRL	A		;  CY=REST FLAG
	LD	(IX+0),A	;  SET WAIT COUNTER
	JR	NC,SSSUB6	;  ���� �� SSSUBA
	CALL	SSSUBA
	JP	SETPT
	
; **	SET FINE TUNE & COARSE TUNE	**
	
SSSUB6:
	LD	A,(HL)		;  LOAD OCT & KEY CODE
	INC	HL
	
	BIT	6,(IX+31)
	JR	NZ,SSSKIP0	;  NON TIE
	
	LD	C,A
	LD	B,(IX+32)
	SUB	B
	JP	Z,SETPT		; IF NOW CODE=BEFORE CODE THEN SETPT
	
	LD	A,C
	
SSSKIP0:
	LD	(IX+32),A	; STORE KEY CODE & OCTAVE
	
	PUSH	HL
	LD	B,A
	AND	00001111B	;  GET KEY CODE
	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,SNUMB
	ADD	HL,DE
	
	LD	A,(HL)		;  GET FNUM2
	INC	HL
	LD	H,(HL)		;  GET FNUM1
	LD	L,A
	
	LD	D,(IX+10)	;
	LD	E,(IX+9)	;  GET DETUNE DATA
	ADD	HL,DE		;  DETUNE PLUS
  	LD	(IX+30),H	; SAVE FOR LFO
	LD	(IX+29),L
	
	SRL	B
	SRL	B
	SRL	B
	SRL	B
	
	DEC	B
	INC	B		;  OCTAVE=1?
	JR	Z,SSSUB4	;  1 �� SSSUB4 �
	
SSSUB5:
	SRL	H
	RR	L
	DJNZ	SSSUB5		;  OCTAVE DATA � ��ò
	
SSSUB4:
	
	LD	E,L
	LD	D,(IX+8)
	CALL	PSGOUT
	
	LD	E,H
	INC	D
	CALL	PSGOUT
	
	BIT	6,(IX+31)
	JR	NZ,SSSUBF
	CALL	SOFENV
	JR	SSSUB9
	
SSSUBF:			; KEYON ���ķ � ���
;	BIT	7,(IX+33)				;���폜
;	JR	Z,SSSUBG	; NOT HARD ENV.		;��
	
; ---	HARD ENV. KEY ON	---
	
;	LD	E,16					;��
;	LD	D,(IX+7)				;��
;	CALL	PSGOUT		; HARD ENV.KEYON	;��
	
;	LD	A,(IX+33)				;��
;	AND	00001111B				;��
;	LD	E,A					;��
;	LD	D,0DH					;��
;	CALL	PSGOUT					;��
;	JR	SSSUBH					;��
	
; ---	SOFT ENV. KEYON		---
	
SSSUBG:
	LD	A,(IX+6)
	AND	00001111B
	OR	10010000B	;  TO STATE 1 (ATTACK)
	LD	(IX+6),A
	
	LD	A,(IX+12)	;  ENVE INIT
	LD	(IX+11),A
	RES	5,(IX+31)	; RESET LFO CONTINE FLAG
	CALL	SOFEV7
SSSUBH:
	LD	C,(IX+27)
	SRL	C
	LD	(IX+28),C	;  LFO PEAK LEVEL �� ��ò
	LD	C,(IX+19)
	LD	(IX+20),C	;  LFO DELAY � ����ò
SSSUB9:
	POP	HL
	
; **   VOLUME OUT PROCESS   **
	
;
;  ENTRY A: VOLUME DATA
;
	
SSSUB3:
;	BIT	7,(IX+33)					;���폜
;	JR	NZ,SETPT	; IF HARD ENVE THEN SETPT	;��
	
	LD	E,A
	LD	D,(IX+7)
	CALL	PSGOUT
	
; **   SET POINTER   **
	
SETPT:
        LD	(IX+3),H
	LD	(IX+2),L	;  SET NEXT SOUND DATA ADDRES
	RET
	
; **	KEY OFF �� � RR ���	**
	
SSSUBA:
	
; --	HARD ENV. KEY OFF	--
	
;	BIT	7,(IX+33)				;���폜
;	JR	Z,SSUBAB	; NOT HARD ENV.		;��
;	LD	E,0					;��
;	LD	D,(IX+7)				;��
;	CALL	PSGOUT		; HARD ENV.KEYOFF	;��
	
; --	SOFT ENV. KEY OFF	--
	
;SSUBAB:						;���폜
	BIT	5,(IX+33)
	JR	Z,SSUBAC
	RES	6,(IX+31)
	JP	SSSUB0
SSUBAC:
	XOR	A
	BIT	7,(IX+6)
	JR	Z,SSSUB3	;  �ذ� �ެŹ��� SSSUB3
	LD	A,(IX+6)
	AND	10001111B	; STATE 4 (�ذ�)
	LD	(IX+6),A
	CALL	SOFEV9
	JR	SSSUB3
	
; **   ��� ����� � ��ò   **
	
SSSUB8:
	AND	0FH		; A=COMMAND No.(0-F)
	LD	DE,SSSUBB
	PUSH	DE		; STORE RETURN ADDRES
	LD	DE,PSGCOM
	LD	B,A
	ADD	A,A
	ADD	A,B		; A*3
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A		; DE+A*3
	PUSH	DE
	RET
	
; **   PSG COMMAND TABLE   **
	
PSGCOM:
	JP	OTOSSG		;F0-�ݼ�� ���         '@'
	JP	PSGVOL		;F1-VOLUME SET
	JP	FRQ_DF		;F2-DETUNE
	JP	SETQ		;F3-COMMAND OF        'q'
	JP	LFOON		;F4-LFO
	JP	REPSTF		;F5-REPEAT START SET  '['
	JP	REPENF		;F6-REPEAT END SET    ']'
	JP	NOISE		;F7-MIX PORT          'P'
	JP	NOISEW		;F8-NOIZE PARAMATER   'w'
	JP	FLGSET		;F9-FLAG SET
	JP	ENVPST		;FA-SOFT ENVELOPE     'E'
	JP	VOLUPS		;FB-VOLUME UP    ')'
        JP	NTMEAN		;FC-
	JP	TIE
	JP	RSKIP
	JP	SECPRC		;FF- to sec com
	
; **	HARD ENVE SET	**
	
;HRDENV:						;���폜
;	LD	E,(HL)					;��
;	INC	HL					;��
;	LD	D,0DH					;��
;	CALL	PSGOUT					;��
;	LD	A,E					;��
;	OR	10000000B	; SET H.E FLAG		;��
;	LD	(IX+33),A	; H.E MODE		;��
;	LD	(IX+6),16				;��
;	RET						;��
	
; **	HARD ENVE PERIOD	**
	
;ENVPOD:						;���폜
;	LD	E,(HL)					;��
;	INC	HL					;��
;	LD	D,0BH					;��
;	CALL	PSGOUT					;��
;	LD	E,(HL)					;��
;	INC	HL					;��
;	INC	D					;��
;	CALL	PSGOUT					;��
;	RET						;��
	
; **   WRITE REG   **
	
W_REG:
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	CALL	PSGOUT
	RET
	
; **   MIX PORT CONTROL   **
	
NOISE:
	LD	C,(HL)
	INC	HL
	
	LD	B,(IX+8)	; CH NO.
	
	LD	A,(PREGBF+5)
	LD	E,A
	SRL	B
	INC	B
	LD	D,B
	LD	A,01111011B
NOISE1:
	RLCA
	DJNZ	NOISE1
	AND	E
	LD	E,A
	LD	A,C
	LD	B,D
	RRCA
NOISE2:
	RLCA
	DJNZ	NOISE2
	OR	E
	LD	D,7
	LD	E,A
	CALL	PSGOUT
	
	LD	A,E
	LD	(PREGBF+5),A
	RET
	
; **   ɲ�� ���ʽ�   **
	
NOISEW:
	LD	E,(HL)
	INC	HL
	LD	D,6
	CALL	PSGOUT
	LD	A,E
	LD	(PREGBF+4),A
	RET
	
; **   ����۰�� ���Ұ� ���   **
	
ENVPST:
	EX	DE,HL
	PUSH	IX
	POP	HL
	LD	BC,12
	ADD	HL,BC
	EX	DE,HL
	LD	BC,6
	LDIR
	LD	A,(IX+6)
	OR	10010000B	; �����׸� �����׸� ���
	LD	(IX+6),A
	RET
	
; **   PSG �ݼ�����   **
	
OTOSSG:
	LD	A,(HL)
	INC	HL
	PUSH	HL
	CALL	OTOCAL
	CALL	ENVPST
	POP	HL
	RET
OTOCAL:
	LD	HL,SSGDAT
	ADD	A,A
	LD	C,A
	ADD	A,A
	ADD	A,C	;*6
	LD	E,A
	LD	D,0
	ADD	HL,DE
	RET
	
; **	SSG VOLUME UP & DOWN	**
	
VOLUPS:
	LD	D,(HL)
	INC	HL
	
;	BIT	7,(IX+33)				;���폜
;	RET	NZ					;��
	
	LD	A,(IX+6)
	LD	E,A
	AND	00001111B
	ADD	A,D
	CP	16
	RET	NC
	LD	D,A
	LD	A,E
	AND	11110000B
	OR	D
	LD	(IX+6),A
	RET
	
	
; **	PSG VOLUME	**
	
PSGVOL:
;	RES	7,(IX+33)	; RES HARD ENV FLAG	;���폜
	
	LD	A,(IX+6)
	AND	11110000B
	LD	E,A
	LD	C,(HL)
PV1:
	LD	A,(TOTALV)
	ADD	A,C
	CP	16
	JR	C,PV2
	XOR	A
PV2:
	OR	E
	INC	HL
	LD	(IX+6),A
	RET
	
; **	SSG ALL SOUND OFF	**
	
SSGOFF:
	LD	B,3
	LD	D,8
	LD	E,0
SSGOF1:
	CALL	PSGOUT
	INC	D
	DJNZ	SSGOF1
	RET
	
; **   SSG KEY OFF   **
	
SKYOFF:
	XOR	A
	LD	(IX+6),A	; ENVE FLAG RESET
	
	LD	E,A
	LD	D,(IX+7)
	CALL	PSGOUT
	RET
	
	
; **	SOFT ENVEROPE PROCESS	**
	
SOFENV:
	BIT	4,(IX+6)	; CHECK ATTACK FLAG
	JR	Z,SOFEV2
	
	LD	A,(IX+11)
	LD	D,(IX+13)
	ADD	A,D
	JR	NC,SOFEV1
	LD	A,0FFH
SOFEV1:
	CP	0FFH
	LD	(IX+11),A
	JR	NZ,SOFEV7
	
	LD	A,(IX+6)
	XOR	00110000B
	LD	(IX+6),A	; TO STATE 2 (DECAY)
	JR	SOFEV7
	
SOFEV2:
	BIT	5,(IX+6)
	JR	Z,SOFEV4
	
	LD	A,(IX+11)
	LD	D,(IX+14)	; GET DECAY
	LD	E,(IX+15)	; GET SUSTAIN
	
	SUB	D
	JR	C,SOFEV8
	CP	E
	JR	NC,SOFEV3
SOFEV8:
	LD	A,E
SOFEV3:
	CP	E
	LD	(IX+11),A
	JR	NZ,SOFEV7
	LD	A,(IX+6)
	XOR	01100000B
	LD	(IX+6),A	; TO STATE 3 (SUSTAIN)
	JR	SOFEV7
	
SOFEV4:
	BIT	6,(IX+6)
	JR	Z,SOFEV9
	
	LD	A,(IX+11)
	LD	D,(IX+16)	;  GET SUSTAIN LEVEL
	SUB	D
	JR	NC,SOFEV5
	XOR	A
	
SOFEV5:
	OR	A
	LD	(IX+11),A
	JR	NZ,SOFEV7
	LD	A,(IX+6)
	AND	10001111B
	LD	(IX+6),A	; END OF ENVE
	JR	SOFEV7
	
SOFEV9:
	LD	A,(IX+11)
	LD	D,(IX+17)    ; GET REREASE
	SUB	D
	JR	NC,SOFEVA
	XOR	A
SOFEVA:
	LD	(IX+11),A
	
; **	VOLUME CALCURATE	**
	
SOFEV7:
	PUSH	HL
	LD	E,(IX+11)
	LD	D,0
	LD	HL,0
	LD	A,(IX+6)	; GET VOLUME
	AND	00001111B
	INC	A
	LD	B,A
SOFEV6:
	ADD	HL,DE
	DJNZ	SOFEV6
	LD	A,H
	POP	HL
	BIT	6,(IX+31)
	RET	NZ
	BIT	5,(IX+33)
	RET	Z
	ADD	A,(IX+17)
	SRL	A
	RET
	
; **	�ݿ� ���	**
	
FMEND:
	LD	(IX+2),L
	LD	(IX+3),H
	LD	A,(PCMFLG)
	OR	A
	JR	NZ,PCMEND
	CALL	KEYOFF
	RET
PCMEND:
	LD	DE,0B00H
	CALL	PCMOUT
	LD	DE,0100H
	CALL	PCMOUT
	LD	DE,0021H
	CALL	PCMOUT
	RET
SSGEND:
	LD	(IX+2),L
	LD	(IX+3),H
	CALL	SKYOFF
	RES	7,(IX+31)	; RESET LFO FLAG
	RET
	
	
; **   VOLUME OR FADEOUT etc RESET   **
	
WORKINIT:
	XOR	A
	LD	(C2NUM),A
	LD	(CHNUM),A
	LD	(PVMODE),A
	
	LD	A,(MUSNUM)
	LD	HL,MU_TOP
WI1:
	LD	DE,MAXCH*4
	OR	A
	JR	Z,WI2
	INC	HL
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,MU_TOP
	ADD	HL,DE
	DEC	A
	JR	WI1
WI2:
	LD	A,(HL)
	LD	(TIMER_B),A
	INC	HL
	LD	(TB_TOP),HL
	
	LD	B,6
	LD	IX,CH1DAT
WI4:
	PUSH	BC
	CALL	FMINIT
	LD	DE,WKLENG
	ADD	IX,DE
	POP	BC
	DJNZ	WI4
	
	XOR	A
	LD	(CHNUM),A
	LD	IX,DRAMDAT
	CALL	FMINIT
	
	XOR	A
	LD	(CHNUM),A
	LD	B,4
	LD	IX,CHADAT
WI6:
	PUSH	BC
	CALL	FMINIT
	LD	DE,WKLENG
	ADD	IX,DE
	POP	BC
	DJNZ	WI6
	RET
	
	
FMINIT:
	PUSH	IX
	POP	HL
	LD	E,L
	LD	D,H
	INC	DE
	LD	(HL),0
	LD	BC,WKLENG-1
	LDIR
	
	LD	(IX),1
	LD	(IX+6),0
	
; ---	POINTER � ����ò	---
	
	LD	HL,(TB_TOP)	; HL=TABLE TOP ADR (Ch)
	
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	HL
	LD	HL,MU_TOP
	ADD	HL,DE
	LD	(IX+2),L
	LD	(IX+3),H
	POP	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,E
	OR	D
	JR	Z,FMI2
	LD	HL,MU_TOP
	ADD	HL,DE
	LD	(IX+4),L
	LD	(IX+5),H
FMI2:
	LD	HL,C2NUM
	INC	(HL)
	LD	HL,(TB_TOP)
	LD	DE,4
	ADD	HL,DE
	LD	(TB_TOP),HL
	
	LD	A,(CHNUM)
	CP	3
	JR	NC,SSINIT
	
	LD	(IX+8),A
	INC	A
	LD	(CHNUM),A
	RET
	
; ---   FOR SSG   ---
	
SSINIT:
	ADD	A,5
	LD	(IX+7),A
	LD	A,(CHNUM)
	SUB	3
	ADD	A,A
	LD	(IX+8),A
	
	LD	A,(CHNUM)
	INC	A
	LD	(CHNUM),A
	RET
	
	
; **	CHANGE SE MODE	**
	
TO_NML:
	LD	A,38H
	LD	(PLSET1+1),A
	LD	A,3AH
TNML2:
	LD	(PLSET2+1),A
	LD	D,27H
	LD	E,A
	CALL	PSGOUT
	RET
TO_EFC:
	LD	A,78H
	LD	(PLSET1+1),A
	LD	A,7AH
	JR	TNML2
	
	
; ***	ADPCM	PLAY	***
	
	;	IN:(STTADR)<=���� ���� ���ڽ
	;	   (ENDADR)  <=���� ���� ���ڽ
	;	   (DELT_N)<=���� ڰ�
	
PLAY:
	PUSH	HL
	
	LD	DE,0B00H
	CALL	PCMOUT
	LD	DE,0100H
	CALL	PCMOUT
	
	LD	DE,0021H
	CALL	PCMOUT
	LD	DE,1008H	;
	CALL	PCMOUT		;
	LD	DE,1080H	;
	CALL	PCMOUT		; INIT
	
	LD	HL,(STTADR)
	LD	D,2
	LD	E,L
	CALL	PCMOUT		; START ADR
	INC	D
	LD	E,H
	CALL	PCMOUT
	
	LD	HL,(ENDADR)
	LD	D,4
	LD	E,L
	CALL	PCMOUT		; END ADR
	INC	D
	LD	E,H
	CALL	PCMOUT
	
	LD	D,09H
	LD	A,(DELT_N)	; ���� ڰ� ��
	LD	E,A
	CALL	PCMOUT
	LD	D,0AH
	LD	A,(DELT_N+1)	; ���� ڰ� �ޮ��
	LD	E,A
	CALL	PCMOUT
	
	LD	DE,00A0H
	CALL	PCMOUT
	
	LD	D,0BH
	LD	E,(IX+6)
	LD	A,(TOTALV)
	ADD	A,A
	ADD	A,A
	ADD	A,E
	CP	250
	JR	C,PL1
	XOR	A
PL1:
	LD	E,A
	LD	A,(PVMODE)
	OR	A
	JR	Z,PL2
	LD	A,(IX+7)
	ADD	A,E
	LD	E,A
PL2:
	CALL	PCMOUT		; VOLUME
	
	LD	D,01H
	LD	A,(PCMLR)
	RRCA
	RRCA
	AND	11000000B
	LD	E,A
	CALL	PCMOUT		; 1 bit TYPE,L&R OUT
	
	LD	A,(PCMNUM)
	LD	(P_OUT),A	; �ݺ޳�޽
	
	POP	HL
	RET
	
	
; ***	ADPCM	OUT	***
	
PCMOUT:
	PUSH	BC
	
	LD	A,(PORT13+1)
	LD	C,A
PCMO2:
	IN	A,(C)
	JP	M,PCMO2
	
	OUT	(C),D
PCMO3:
	IN	A,(C)
	JP	M,PCMO3
	INC	C
	
	OUT	(C),E
	
	POP	BC
	RET
	
	
; **	�غ� ��ò/�ް�� ���� ���	**
	
CHK:
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
	
	
; **	MUSIC WORK	**
	
NOTSB2:	DB	0	;(INFADR)
PVMODE:	DB	0	;PCMvolMODE
P_OUT:	DB	0
M_VECTR:DB	0	;32H OR AAH
PORT13:	DW	0	;44H OR A8H
TOTALV:	DB	0
FDCO:	DB	0,0
	
SSGF1:			;  SSG 4-6CH  PLAY FLAG
	DB	0
DRMF1:	DB	0
KEYBUF:	DB	0
FMPORT:	DB	0
FNUM:	DW	0
	
	
; **	��ح�� �ް�   **

FMVDAT:					; ��ح�� �ް� (FM)
	DB	36H,33H,30H,2DH
	DB	2AH,28H,25H,22H		;  0,  1,  2,  3
	DB	20H,1DH,1AH,18H		;  4,  5,  6,  7
	DB	15H,12H,10H,0DH		;  8,  9, 10, 11
	DB	0AH,08H,05H,02H		; 12, 13, 14, 15

CRYDAT:			; ��ر / Ӽޭڰ� � �ް�
	DB	08H	;
	DB	08H	; �� �ޯ� �� ��ر/Ӽޭڰ� � ��ܽ
	DB	08H	;
	DB	08H	; Bit=1 �� ��ر
	DB	0CH	;      0 �� Ӽޭڰ�
	DB	0EH	;
	DB	0EH	; Bit0=OP 1 , Bit1=OP 2 ... etc
	DB	0FH	;
	
; **	PMS/AMS/LR DATA	**
	
PALDAT:
	DB	0C0H
	DB	0C0H
	DB	0C0H
	DB	0	; DUMMY
	DB	0C0H
	DB	0C0H
	DB	0C0H
PCMLR:
	DB	0
	
; **	SOUND WORK (FM)	**
CH1DAT:
	DB	1	; LENGTH �����		IX+ 0
	DB	24	; �ݼ�� ���ް		1
	DW	0	; DATA ADDRES WORK	2,3
	DW	0	; DATA TOP ADDRES	4,5
	DB	10	; VOLUME DATA		6
	DB	0	; �ٺ�ؽ�� No.		7
	DB	0	; ����� ���ް          	8
	DW	0	; ������ DATA		9,10
	DB	0	; for TLLFO		11
	DB	0	; for ��ް��		12
	DS	5	; SOFT ENVE DUMMY	13-17
	DB	0	; q������		18

	DB	0	; LFO DELAY		19
	DB	0	; WORK			20
	DB	0	; LFO COUNTER		21
	DB	0	; WORK			22
	DW	0	; LFO �ݶخ� 2BYTE	23,24
	DW	0	; WORK			25,26

	DB	0	; LFO PEAK LEVEL	27
	DB	0	; WORK			28
	DB	0	; FNUM1 DATA		29
	DB	0	; B/FNUM2 DATA		30
	DB	00000001B	;bit 7=LFO FLAG	31
	
			; bit	6=KEYOFF FLAG
			;	5=LFO CONTINUE FLAG
			;	4=TIE FLAG
			;	3=MUTE FLAG
			;	2=LFO 1SHOT FLAG
			;
			;	0=1LOOPEND FLAG
	DB 	0	; BEFORE CODE		32
	DB	0	; bit	6=TL LFO FLAG     33
			;	5=REVERVE FLAG
			;	4=REVERVE MODE
	DW	0	;	���ݱ��ڽ	34,35
	DB	0,0     ; 36,37 (��)
CH2DAT:
	DB	1
	DB	24
	DW	0000H
	DW	0000H
	DB	10
	DB	0
	DB	1
	DW	0000H
	DS	7
	DB	0	;18

	DB	0
	DB	0
	DB	0
	DB	0
	DW	0
	DW	0

	DB	0
	DB	0
	DB	0
	DB	0
	DB	00000010B
	DW	0,0,0
CH3DAT:
	DB	1
	DB	24
	DW	0000H
	DW	0000H
	DB	10
	DB	0
	DB	2
	DW	0000H
	DS	7
	DB	0	;18

	DB	0
	DB	0
	DB	0
	DB	0
	DW	0
	DW	0

	DB	0
	DB	0
	DB	0
	DB	0
	DB	00000011B
	DW	0,0,0
	
; **	WORK (SSG)	**

CH4DAT:
	DB	1	; COUNTER WORK		0
	DB	0	; �ݼ�� No.		1
	DW	0000H	; DATA ADRS WORK	2,3
	DW	0000H	; DATA TOP ADRS		4,5
	DB	8	; CURENT VOLUME(bit0-3)	6
			; bit 4 = attack flag
			; bit 5 = decay flag
			; bit 6 = sustain flag
			; bit 7 = soft envelope flag
	
	DB	8	; VOL.REG.No.		7
	DB	0       ; CHANNEL No.          	8
	DW	0	; FOR DETUNE		9,10
	DB	0	; SOFT ENVE COUNTER	11
	DS	6	; SOFT ENVE		12-17
	
	DB	0	; COUNTER OF 'q'	18
	
	DB	0	; LFO DELAY		19
	DB	0	; WORK			20
	DB	0	; LFO COUNTER		21
	DB	0	; WORK			22
	DW	0	; LFO �ݶخ� 2BYTE	23,24
	DW	0	; WORK			25,26

	DB	0	; LFO PEAK LEVEL	27
	DB	0	; WORK			28
	DB	0	; FNUM1 DATA		29
	DB	0	; B/FNUM2 DATA		30
	DB	00000100B	; bit 7=LFO FLAG	31
			; bit	6=KEYOFF FLAG
			; bit	5=LFO CONTINUE FLAG
			; bit	4=TIE FLAG
			;	3=MUTE FLAG
	
			;	0=1LOOPEND FG
	DB	0	; BEFORE CODE		32
	DB      0       ; bit 7 = HARD ENVE FLAG 33
			; bit 0-3 = HARD ENVE TYPE
	DW	0
	DB	0,0

CH5DAT:
	DB	1
	DB	0
	DW	0000H
	DW	0000H
	DB	8
	
	DB	9
	DB	2
	DW	0
	DB	0
	DS	6
	
	DB	0
	
	DB	0
	DB	0
	DB	0
	DB	0
	DW	0
	DW	0
	
	DB	0
	DB	0
	DB	0
	DB	0
	DB	00000101B
	DW	0,0,0
	
CH6DAT:
	DB	1
	DB	0
	DW	0000H
	DW	0000H
	DB	8
	
	DB	10
	DB	4
	DW	0
	DB	0
	DS	6
	
	DB	0
	
	DB	0
	DB	0
	DB	0
	DB	0
	DW	0
	DW	0
	
	DB	0
	DB	0
	DB	0
	DB	0
	DB	00000110B
	DW	0,0,0
	
DRAMDAT:
	DB	1,0
	DW	0,0
	DB	10,0,2
	DW	0
	DS	7
	DB	0	;18
	DS	19,0
CHADAT:
	DB	1,0
	DW	0,0
	DB	10,0,2
	DW	0
	DS	7
	DB	0	;18
	DS	19,0
CHBDAT:
	DB	1,0
	DW	0,0
	DB	10,0,2
	DW	0
	DS	7
	DB	0	;18
	DS	19,0
CHCDAT:
	DB	1,0
	DW	0,0
	DB	10,0,2
	DW	0
	DS	7
	DB	0	;18
	DS	19,0
PCMDAT:
	DB	1,0
	DW	0,0
	DB	10,0,2
	DW	0
	DS	7
	DB	0	;18
	DS	19,0
	
RHYTHM:	DB	0
	
WKLENG:	EQU	CH2DAT-CH1DAT
	
; **	PSG REGISTOR WORK	**
	
PREGBF:
	DB	0,0,0,0,0,0,0,0,0
INITPM:
	DB	0,0,0,0,0,56,0,0,0
	
; **	SE MODE(MODE2) � ������ ܰ�	**

DETDAT:
	DB	0	;		OP1
	DB	0	;		OP2
	DB	0	;		  3
	DB	0	;		  4
	
; **	DRAM VOLUME DATA	**
	
DRMVOL:
	DB	0C0H	; BASS
	DB	0C0H	; SNEA
	DB	0C0H	; SYMB
	DB	0C0H	; HI-HAT
	DB	0C0H	; TAM
	DB	0C0H	; RIM
	
NEWFNM:
	DW	0
OP_SEL:
	DB	0A6H,0ACH,0ADH,0AEH	; OP 4,3,1,2
	
CHNUM:	DB	0
C2NUM:	DB	0
TB_TOP:	DW	0
;TIMER_B:DB	0				;���C���O
TIMER_B:DB	0				;���C����
PRISSG:	DB	0
	
; ***	ADPCM WORK	***
	
	
DMY:	DB	8
STTADR: DW      0
ENDADR: DW      0
DELT_N:	DW	0	; ���� ڰ�
PCMNUM:	DB	0
PCMFLG:	DB	0
PRI:	DB	0
TYPE1:	DB	032H,044H,046H
TYPE2:	DB	0AAH,0A8H,0ACH
	
	
FNUMB:	DW	026AH,028FH,02B6H,02DFH,030BH,0339H
	DW      036AH,039EH,03D5H,0410H,044EH,048FH
SNUMB:	DW	0EE8H,0E12H,0D48H,0C89H,0BD5H,0B2BH
	DW	0A8AH,09F3H,0964H,08DDH,085EH,07E6H
PCMNMB:		; C-B ��� � ���� �����ݸ� ڰ�
	DW	49BAH+200,4E1CH+200,52C1H+200,57ADH+200
	DW	5CE4H+200,626AH+200,6844H+200,6E77H+200
	DW	7509H+200,7BFEH+200,835EH+200,8B2DH+200
	
	
SSGDAT:
	DB	255,255,255,255,0,255 ; E
	DB	255,255,255,200,0,10
	DB	255,255,255,200,1,10
	DB	255,255,255,190,0,10
	DB	255,255,255,190,1,10
	DB	255,255,255,170,0,10
	DB	40,70,14,190,0,15
	DB	120,030,255,255,0,10
	DB	255,255,255,225,8,15
	DB	255,255,255,1,255,255
	DB	255,255,255,200,8,255
	DB	255,255,255,220,20,8
	DB	255,255,255,255,0,10
	DB	255,255,255,255,0,10
	DB	120,80,255,255,0,255
	DB	255,255,255,220,0,255
