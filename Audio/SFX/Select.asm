section "SFX sequence - Select",romx

SFX_Select:
    db  1,0
    dw  SFX_Select_CH5
    dw  Sound_DummySeq
    dw  Sound_DummySeq
    dw  Sound_DummySeq

SFX_Select_CH5:
    pulse 2
    envelope $f1
    octave 7
    note C_,1
    note D#,1
    note G#,1
    note D#,1
    note G#,1
    envelope $c1
    note G#,1
    envelope $91
    note G#,1
    envelope $61
    note G#,1
    envelope $31
    note G#,1
    sound_end
