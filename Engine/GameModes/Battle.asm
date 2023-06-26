section "Battle RAM",wram0

BATTLE_TYPE_WILD_MANS = 0
BATTLE_TYPE_MANSTAMER = 1
BATTLE_TYPE_NO_MANS   = 2

Battle_PlayerActiveMans:
    MansStruct

Battle_EnemyActiveMans:
    MansStruct

BattleType:             db
Battle_EnemyName:       ds  8
Battle_StringBuffer:    ds  20

section "Battle strings",romx

Text_Battle_MansAppeared1:
;        ##################
    db  "Wild ",TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  TEXT_NEXT
    db  "appeared!",TEXT_CONT,TEXT_END

Text_Battle_MansAppeared2:
;        ##################
    db  "Oh no! It's a wild",TEXT_NEXT
    db  TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  TEXT_CONT,TEXT_END

Text_Battle_MansAppeared3:
;        ##################
    db  TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  TEXT_NEXT
    db  "appeared!",TEXT_CONT,TEXT_END

Text_Battle_Manstamer1:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  TEXT_NEXT
    db  "challenges you to",TEXT_CONT
    db  "a MANS BATTLE!",TEXT_CONT,TEXT_END

Text_Battle_Manstamer2:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  " wants to",TEXT_NEXT,
    db  "battle!",TEXT_CONT,TEXT_END

Text_Battle_Manstamer3:
    db  "You are challenged",TEXT_NEXT
    db  "by ",TEXT_STRING,8
    dw  Battle_EnemyName
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_PlayerSendOut:
;        ##################
    db  "Go!",TEXT_NEXT
    db  TEXT_STRING,12
    dw  Battle_PlayerActiveMans
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_PlayerRecall:
    db  TEXT_STRING,12
    dw  Battle_PlayerActiveMans
    db  "!",TEXT_NEXT
    db  "Return!",TEXT_CONT,TEXT_END
    
Text_Battle_EnemySendOut:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  " sends",TEXT_NEXT
    db  "out ",TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_EnemyRecall:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  " calls",TEXT_NEXT
    db  "back ",TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_PlayerMove:
;        ##################
    db  TEXT_STRING,12
    dw  Battle_PlayerActiveMans
    db  " used",TEXT_NEXT
    db  TEXT_STRING,16
    dw  Battle_StringBuffer
    db  "!",TEXT_CONT,TEXT_END
    
    
Text_Battle_EnemyMove:
;        ##################
    db  "Enemy ",TEXT_STRING,12
    dw  Battle_EnemyActiveMans
    db  TEXT_NEXT
    db  "used ",TEXT_CONT
    db  TEXT_STRING,16
    dw  Battle_StringBuffer
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_PlayerUseItem:
;        ##################
    db  "You used",TEXT_NEXT
    db  TEXT_STRING,16
    dw  Battle_StringBuffer
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_PlayerUseItemOnMans:
;        ##################
    db  "You used",TEXT_NEXT
    db  TEXT_STRING,16
    dw  Battle_StringBuffer
    db  "on ",TEXT_STRING,12
    dw  Battle_PlayerActiveMans
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_EnemyUseItem:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  " used",TEXT_NEXT
    db  TEXT_STRING,16
    dw  Battle_StringBuffer
    db  "!",TEXT_CONT,TEXT_END

Text_Battle_EnemyUseItemOnMans:
;        ##################
    db  TEXT_STRING,8
    dw  Battle_EnemyName
    db  " used",TEXT_NEXT
    db  "on ",TEXT_STRING,12
    dw  Battle_PlayerActiveMans
    db  "!",TEXT_CONT,TEXT_END