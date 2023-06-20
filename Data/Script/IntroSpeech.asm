Script_IntroSpeech:
    script_set_palette %00000000
    script_show_pic Pic_Dogwood,0,0
    script_fade_in_white
    script_text Script_IntroSpeech_Text1
    script_fade_out_white
    
    script_show_pic Pic_Mans001,0,0
    script_fade_in_white
    script_text Script_IntroSpeech_Text2
    script_fade_out_white
    
    script_show_pic Pic_Mockum,0,0
    script_fade_in_white
    script_text Script_IntroSpeech_Text3
    script_asm_call Script_IntroSpeech_NameEntry
    script_text Script_IntroSpeech_Text4
    script_fade_out_white
    
    script_show_pic Pic_Dogwood,0,0
    script_fade_in_white
    script_text Script_IntroSpeech_Text5
    script_fade_out_white
    script_show_pic Pic_Mockum,0,0
    script_asm_call Script_IntroSpeech_ShrinkAnim
    script_end

Script_IntroSpeech_Text1:
;        ##################
    db  "Ah, welcome! My",$80
    db  "name is PROFESSOR",$81
    db  "JAMES P. DOGWOOD,",$81
    db  "but you can call",$81
    db  "me DOGWOOD.",$ff
;        ##################

Script_IntroSpeech_Text2:
;        ##################
    db  "This world is",$80
    db  "inhabited by both",$81
    db  "us monsters and",$81
    db  "beings known as",$81
    db  "HUMANS, or MANS",$81
    db  "for short!",$82
    db  "Some of us keep",$80
    db  "MANS as pets, but",$81
    db  "others use them to",$81
    db  "battle against",$81
    db  "other MANS."$82
    db  "Myself, I've taken",$80
    db  "it upon myself to",$81
    db  "study them. You",$81
    db  "might say I'm a",$81
    db  "MANS expert!",$ff
;        ##################

Script_IntroSpeech_Text3:
;        ##################
    db  "But enough about",$80
    db  "me, why don't you",$81
    db  "tell me a bit",$81
    db  "about yourself?",$82
    db  "What's your name?",$ff
;        ##################

Script_IntroSpeech_Text4:
;        ##################
    db  "Ah, so you're",$80
    dbw $c0,$0000
    db  "!",$81
    db  "Nice to meet you!",$ff
;        ##################

Script_IntroSpeech_Text5:
;        ##################
    dbw $c0,$0000
    db  "!",$80,$82
    db  "It's time for you",$80
    db  "to train to become",$81
    db  "the best MANSTAMER",$81
    db  "there is!",$82
    db  "You'll face many",$80
    db  "good times and",$81
    db  "challenges along",$81
    db  "the way!",$82
    db  "Go for it!",$ff
;        ##################

Script_IntroSpeech_NameEntry:
    ld      hl,Player_Name
    farjp   GM_TextInput

Script_IntroSpeech_ShrinkAnim:
    ; TODO
    ret