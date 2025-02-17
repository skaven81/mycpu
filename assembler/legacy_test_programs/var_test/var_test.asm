# vim: syntax=asm-mycpu

NOP

VAR global byte $foo
VAR global word $baz
VAR global byte $yatta

ST16 $bar 0x0000
ST $foo 'h'

