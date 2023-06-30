section "SFX sequence - PC Bootup",romx
SFX_PCBootup:
    db  2,0
    dw  SFX_PCBootup_CH1
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_PCBootup_CH1:
    envelope $f0
    pulse 2
    octave 3
:   note C_,1
    rest 1
    octave_up
    sound_loop :-,5
    sound_end

section "SFX sequence - PC Cursor",romx
SFX_PCCursor:
    db  2,0
    dw  SFX_PCCursor_CH1
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_PCCursor_CH1:
    envelope $f0
    pulse 2
    octave 6
    note D_,1
    rest 1
    sound_end

section "SFX sequence - PC Select",romx
SFX_PCSelect:
    db  2,0
    dw  SFX_PCSelect_CH1
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_PCSelect_CH1:
    envelope $f0
    pulse 2
    octave 5
    note E_,1
    rest 1
    octave_up
    note E_,1
    rest 1
    sound_end

section "SFX sequence - PC Alert",romx
SFX_PCAlert:
    db  2,0
    dw  SFX_PCAlert_CH1
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_PCAlert_CH1:
    envelope $f0
    pulse 2
    octave 6
    note C_,1
    rest 1
    note F#,1
    rest 1
    sound_end

section "SFX sequence - PC Shutdown",romx

SFX_PCShutdown:
    db  2,0
    dw  SFX_PCShutdown_CH1
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_PCShutdown_CH1:
    envelope $f0
    pulse 2
    octave 5
    note C_,1
    rest 1
    octave_down
    note C_,1
    rest 1
    octave_down
    note G_,1
    rest 1
    note C_,1
    rest 1
    octave_down
    note C_,1
    rest 1
    sound_end