# vim: syntax=asm-mycpu

NOP

VAR global byte $foo
VAR global word $baz
VAR global byte $yatta
VAR local word $bar
VAR local word $bambatta

ST16 $bar 0x0000
ST $foo 'h'

