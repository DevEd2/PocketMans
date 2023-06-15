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

section "OAM buffer",wram0,align[8]
OAMBuffer:  ds  40 * 4
OAMBuffer_End:

section "OAM DMA routine",hram
sys_OAMDMA: ds  $10

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

; ================================================================
; Reset vectors
; ================================================================

section "Reset $00",rom0[$00]
Reset00:    jp  EntryPoint

section "Reset $08",rom0[$08]
WaitVBlank: jp  _WaitVBlank

section "Reset $10",rom0[$10]
Reset10:    ret

section "Reset $18",rom0[$18]
Reset18:    ret

section "Reset $20",rom0[$20]
Reset20:    ret

section "Reset $28",rom0[$28]
Reset28:    ret

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

Start:
    di
    ld      sp,$dffe
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
    
    ; fall through
    
; ================================================================
; Game mode includes
; ================================================================

include "Engine/GameModes/Debug.asm"
include "Engine/GameModes/Overworld.asm"
include "Engine/GameModes/Battle.asm"

; ================================================================
; Support routines
; ================================================================

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
    sub     " "
    ld      [de],a
    inc     de
    jr      PrintString

include "Engine/WLE_Decode.asm"
include "Engine/Math.asm"
    
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

Font:   incbin  "GFX/Font.gfx.wle"
