
#include "bbos.inc.asm"

.define BL_SIZE loader_end-loader_entry

copy_start:
start:
    PUSH A  ; A has drive to load off
        ; get position of BBOS
        SET A, 0x0000
        SUB SP, 4
        SET B, SP
        PUSH B
            INT BBOS_IRQ_MAGIC
        ADD SP, 1
        SET I, physical_start
        SET J, [B+BBOS_START_ADDR]
        SUB J, BL_SIZE
        SET Z, J
        SET A, BL_SIZE
        ADD SP, 4
.copy_top:
        SUB A, 1
        STI [J], [I]
        IFN A, 0
            SET PC, .copy_top
        SET PC, Z
copy_end:

physical_start:

loader_entry:
    SET J, PC
    POP B

    PUSH J
    ADD [SP], title_str-loader_entry-1
        SET I, J
        ADD I, write_screen-loader_entry-1
        JSR I
    ADD SP, 1

    SET A, 0x2003
    SET C, [sector_start]
    SET X, 0
    SET Z, [sector_end]
load_top:
    IFE Z, 0
        ADD PC, done-src1
src1:
    PUSH C
    PUSH X
    PUSH B
        INT BBOS_IRQ_MAGIC
    POP Y
    ADD SP, 2
    IFE Y, 0
        ADD PC, load_fail-src2
src2:
    SUB Z, 1
    ADD C, 1
    ADD X, 0x200
    ADD PC, load_top-src3
src3:

load_fail:
    PUSH J
    ADD [SP], drive_fail-loader_entry-1
        SET I, J
        ADD I, write_screen-loader_entry-1
        JSR I
    ADD SP, 1
    ADD PC, die-src4
src4:

done:
    SET A, B
    SET SP, 0
    SET PC, 0

die:
    SET PC, die

write_screen:
    PUSH A
        SET A, 0x1004
        PUSH [SP+2]
            INT BBOS_IRQ_MAGIC
        ADD SP, 1
    POP A
    RET
    
drive_fail:
    .asciiz "Error while reading"
title_str:
    .asciiz "BootLoader v0.1"
loader_end:
end:

.org 509
sector_start:
.org 510
sector_end:
.org 511
magic: