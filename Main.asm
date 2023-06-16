; ================================================================
; PROJECT: POCKET MANS
; Main source code file
; (C) 2023 DevEd
; 
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:
; 
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; ================================================================

; set to 1 to enable debugging features
DebugMode = 1

include "hardware.inc/hardware.inc"

; ================================================================
; Defines
; ================================================================

btnA            equ 0
btnB            equ 1
btnSelect       equ 2
btnStart        equ 3
btnRight        equ 4
btnLeft         equ 5
btnUp           equ 6
btnDown         equ 7

_A              equ 1 << btnA
_B              equ 1 << btnB
_Select         equ 1 << btnSelect
_Start          equ 1 << btnStart
_Right          equ 1 << btnRight
_Left           equ 1 << btnLeft
_Up             equ 1 << btnUp
_Down           equ 1 << btnDown

; --------

macro dstr
    db  \1
    db  0
endm

macro ldfar
    ld      b,bank(\2)
    rst     Bankswitch
    ld      \1,\2
endm
    
; Loads appropriate ROM bank for a routine and executes it.
; Trashes B.
macro farcall
    ld      b,bank(\1)
    rst     Bankswitch
    call    \1
endm
    
macro resbank
    ldh     a,[sys_LastBank]
    ldh     [sys_CurrentBank],a
    ld      [rROMB0],a
endm

macro tmcoord
    ld      hl,((\2*20) | \1)
    endm
    
macro WaitForVRAM
    ldh     a,[rSTAT]
    and     STATF_BUSY
    jr      nz,@-4
endm

macro djnz
    dec     b
    jr      nz,\1
endm
    
macro lb
    ld      \1,\2<<8 | \3
endm
    
macro dbp
.str\@
    db      \1
.str\@_end
    rept    \2-(.str\@_end-.str\@)
        db  \3
    endr
endm

macro dbw
    db      \1
    dw      \2
endm

macro dwfar
    db      bank(\1)
    dw      \1
    endm

; --------

section "OAM buffer",wram0,align[8]
OAMBuffer:  ds  40 * 4
OAMBuffer_End:

section "Stack",wram0[$cf00]
sys_Stack:          ds  256

section "System RAM",hram
sys_GBType:         db
sys_CurrentFrame:   db
sys_btnPress:       db
sys_btnHold:        db
sys_btnRelease:     db
sys_RNG:            ds  4
sys_VBlankFlag:     db
sys_STATFlag:       db
sys_TimerFlag:      db
sys_SerialFlag:     db
sys_JoypadFlag:     db
sys_CurrentBank:    db
sys_LastBank:       db

section "OAM DMA routine",hram[$fff0]
sys_OAMDMA:         ds  15

section fragment "WRAM defines",wram0
sys_StringBuffer:   ds  20

; ================================================================
; Reset vectors
; ================================================================

section "Reset $00",rom0[$00]
Reset00:    jp  EntryPoint

section "Reset $08",rom0[$08]
DoOAMDMA:   jr  sys_OAMDMA

section "Reset $10",rom0[$10]
WaitVBlank: jp  _WaitVBlank

section "Reset $18",rom0[$18]
WaitSTAT:   jp  _WaitSTAT

section "Reset $20",rom0[$20]
WaitTimer:  jp  _WaitTimer

section "Reset $28",rom0[$28]
Bankswitch: jp  _Bankswitch
    ret

section "Reset $30",rom0[$30]
Reset30:    ret

section "Reset $38",rom0[$38]
ErrTrap:    jr  ErrTrap

; ================================================================
; Interrupt vectors
; ================================================================

section "VBlank IRQ",rom0[$40]
_VBlank:    jp  DoVBlank

section "STAT IRQ",rom0[$48]
_STAT:      jp  DoSTAT

section "Timer IRQ",rom0[$50]
_Timer:     jp  DoTimer

section "Serial IRQ",rom0[$58]
_Serial:    jp  DoSerial

section "Joypad IRQ",rom0[$60]
_Joypad:    jp  DoJoypad

; ================================================================
; ROM header
; ================================================================

section "ROM header",rom0[$100]
EntryPoint:
    jr  Start
    nop
    nop
NintendoLogo:   ds  48,0  ; handled by post-linking tool
ROMTitle:       dbp "POCKET MANS",15,0
GBCSupport:     db  CART_COMPATIBLE_DMG
NewLicenseCode: db  "56"
SGBFlag:        db  CART_INDICATOR_GB
CartType:       db  CART_ROM_MBC5_RAM_BAT
ROMSize:        db  ; handled by post-linking tool
RAMSize:        db  CART_SRAM_128KB
DestCode:       db  CART_DEST_NON_JAPANESE
OldLicenseCode: db  $33
ROMVersion:     db  -1
HeaderChecksum: db  0 ; handled by post-linking tool
ROMChecksum:    dw  0 ; handled by post-linking tool

; ================================================================
; Start of program code
; ================================================================

section fragment "Program code",rom0[$150]

Start:
    di
    ld      sp,sys_Stack
    push    af
    ; wait for vblank and disable lcd
    ld      hl,rLY
    ld      a,SCRN_Y
:   cp      [hl]
    jr      nz,:-
    xor     a
    ldh     [rLCDC],a
    pop     af
    ld      c,a
    ld      a,b
    and     1
    add     c
    ld      [sys_GBType],a ; $02 on DMG0 (unlikely), $01 on DMG/SGB, $FF on MGB/MGL/SGB2, $11 on CGB, $12 on AGB/GBP
    ; clear HRAM
    ld      bc,low(_HRAM) | (low(rIE) - low(_HRAM)) << 8
    xor     a
:   ld      [c],a
    inc     c
    dec     b
    jr      nz,:-
    ; clear VRAM
    xor     a
    ld      hl,_VRAM
    ld      bc,_SRAM-_VRAM
    call    _FillRAM
    ; clear OAM
    xor     a
    ld      hl,OAMBuffer
    ld      b,OAMBuffer_End - OAMBuffer
    call    _FillRAMSmall
    
    ; copy OAM DMA routine
    ld      hl,OAMDMA
    ld      bc,low(sys_OAMDMA) | ((OAMDMA_End - OAMDMA) << 8)
:   ld      a,[hl+]
    ld      [c],a
    inc     c
    dec     b
    jr      nz,:-
    
    ld      a,%11100100
    ldh     [rBGP],a
    ldh     [rOBP1],a
    ld      a,%11100000
    ldh     [rOBP0],a
    
    if DebugMode
        jp  GM_Debug
    endc
    
; ================================================================
; Game mode includes
; ================================================================

include "Engine/GameModes/Debug.asm"
include "Engine/GameModes/Overworld.asm"
include "Engine/GameModes/Battle.asm"
include "Engine/GameModes/SpriteView.asm"

; ================================================================
; Support routines
; ================================================================

section fragment "Program code",rom0

; Performs a bankswitch to bank B, preserving previous ROM bank.
; INPUT:    b = bank
_Bankswitch:
    push    af
    ldh     a,[sys_CurrentBank]
    ldh     [sys_LastBank],a        ; preserve old ROM bank
    ld      a,b
    ldh     [sys_CurrentBank],a     ; set new ROM bank
    ld      [rROMB0],a              ; perform bankswitch
    pop     af
    ret

OAMDMA: ; copied to HRAM during startup
    ld      a,high(OAMBuffer)
    ldh     [rDMA],a
    ; wait 160 cycles for transfer to complete
    ld      a,40
:   dec     a   
    jr      nz,:-
    ret
OAMDMA_End:

; Copy up to 65536 bytes to RAM.
; INPUT:   hl = source
;          de = destination
;          bc = size
; TRASHES: a, bc, de, hl
_CopyRAM::
    ld  a,[hl+]
    ld  [de],a
    inc de
    dec bc
    ld  a,b
    or  c
    jr  nz,_CopyRAM
    ret
    
; Copy up to 256 bytes to RAM.
; INPUT:   hl = source
;          de = destination
;           b = size
; TRASHES: a, b, de, hl
_CopyRAMSmall::
    ld  a,[hl+]
    ld  [de],a
    inc de
    dec b
    jr  nz,_CopyRAMSmall
    ret

; Fill RAM with a value.
; INPUT:    a = value
;          hl = address
;          bc = size
; TRASHES: a, bc, e, hl
_FillRAM::
    ld  e,a
.loop
    ld  [hl],e
    inc hl
    dec bc
    ld  a,b
    or  c
    jr  nz,.loop
    ret
    
; Fill up to 256 bytes of RAM with a value.
; INPUT:    a = value
;          hl = address
;           b = size
; TRASHES: a, b, e, hl
_FillRAMSmall::
    ld  e,a
.loop
    ld  [hl],e
    inc hl
    dec b
    jr  nz,.loop
    ret

; Loads a 20x18 tilemap to VRAM.
; INPUT:   hl = source
; TRASHES: a, bc, de, hl
; RESTRICTIONS: Must run during VBlank or while VRAM is accessible, otherwise written data will be corrupted
LoadTilemapScreen:
    ld  de,_SCRN0
    lb  bc,$12,$14
.loop
    ld  a,[hl+]
    ld  [de],a
    inc de
    dec c
    jr  nz,.loop
    ld  c,$14
    ld  a,e
    add $c
    jr  nc,.continue
    inc d
.continue
    ld  e,a
    dec b
    jr  nz,.loop
    ret

; Same as LoadTilemapScreen, but performs ASCII conversion.
; INPUT:   hl = source
; TRASHES: a, bc, de, hl
; RESTRICTIONS: Must run during VBlank or while VRAM is accessible, otherwise written data will be corrupted
LoadTilemapText:
    ld  de,_SCRN0
    lb  bc,$12,$14
.loop
    ld  a,[hl+]
    sub " " + $80
    ld  [de],a
    inc de
    dec c
    jr  nz,.loop
    ld  c,$14
    ld  a,e
    add $C
    jr  nc,.continue
    inc d
.continue
    ld  e,a
    dec b
    jr  nz,.loop
    ret

; Prints a null-terminated string.
; INPUT:   hl = source
;          de = destination
PrintString:
    WaitForVRAM
    ld      a,[hl+]
    and     a           ; terminator byte reached?
    ret     z           ; if yes, return
    sub     " " + $80
    ld      [de],a
    inc     de
    jr      PrintString

PrintMansName:
    ld      b,12
:   WaitForVRAM
    ld      a,[hl+]
    sub     " " + $80
    ld      [de],a
    inc     de
    djnz    :-
    ret

; INPUT:                  a = hexadecimal number
; OUTPUT:  sys_StringBuffer = converted number
; TRASHES: bc, hl
; Adapted from https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispA
Hex2Dec8:
    inc     a
    ld      hl,sys_StringBuffer
    ld      c,-100
    call    :+      ; hundreds place
    ld      c,-10
    call    :+      ; tens place
    ld      c,-1
    call    :+
    ld      [hl],0
    ret
:   ld      b,-1
:   inc     b
    add     c
    jr      c,:-
    sub     c
    push    af
    ld      a,b
    add     "0"
    ld      [hl+],a
    pop     af
    ret

include "Engine/WLE_Decode.asm"
include "Engine/Math.asm"
include "Engine/Pic.asm"
    
; ================================================================
; Interrupt handlers
; ================================================================

DoVBlank:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,1
    ldh     [sys_VBlankFlag],a
    
    ld      hl,sys_CurrentFrame
    inc     [hl]
    
    ld      a,[sys_btnHold]
    ld      c,a
    ld      a,P1F_5
    ldh     [rP1],a
    ldh     a,[rP1]
    ldh     a,[rP1]
    cpl
    and     $f
    swap    a
    ld      b,a
    ld      a,P1F_4
    ldh     [rP1],a
    ldh     a,[rP1]
    ldh     a,[rP1]
    ldh     a,[rP1]
    ldh     a,[rP1]
    ldh     a,[rP1]
    ldh     a,[rP1]
    cpl
    and     $f
    or      b
    ld      b,a
    
    ld      a,[sys_btnHold]
    xor     b
    and     b
    ld      [sys_btnPress],a    ; store buttons pressed this frame
    ld      e,a
    ld      a,b
    ld      [sys_btnHold],a     ; store held buttons
    xor     c
    xor     e
    ld      [sys_btnRelease],a  ; store buttons released this frame
    ld      a,P1F_5|P1F_4
    ldh     [rP1],a
    
    rst     DoOAMDMA
    
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

DoSTAT:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,1
    ldh     [sys_STATFlag],a
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

DoTimer:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,1
    ldh     [sys_TimerFlag],a
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

DoSerial:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,1
    ldh     [sys_SerialFlag],a
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

DoJoypad:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,1
    ldh     [sys_JoypadFlag],a
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

_WaitVBlank:
    halt
    ldh     a,[sys_VBlankFlag]
    and     a
    jr      z,_WaitVBlank
    xor     a
    ldh     [sys_VBlankFlag],a
    ret

_WaitSTAT:
    halt
    ldh     a,[sys_STATFlag]
    and     a
    jr      z,_WaitSTAT
    xor     a
    ldh     [sys_STATFlag],a
    ret

_WaitTimer:
    halt
    ldh     a,[sys_TimerFlag]
    and     a
    jr      z,_WaitTimer
    xor     a
    ldh     [sys_TimerFlag],a
    ret

_WaitSerial:
    halt
    ldh     a,[sys_SerialFlag]
    and     a
    jr      z,_WaitSerial
    xor     a
    ldh     [sys_SerialFlag],a
    ret

_WaitJoypad:
    halt
    ldh     a,[sys_JoypadFlag]
    and     a
    jr      z,_WaitJoypad
    xor     a
    ldh     [sys_JoypadFlag],a
    ret

; ================================================================
; GFX data
; ================================================================

Font:   incbin  "GFX/Font.2bpp.wle"

include "Data/MansNames.asm"
include "Data/MansPics.asm"
