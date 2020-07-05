proc completion_bindings {entry} {
  bind $entry <Tab> { path_expand %W; break }
  bind $entry <Escape> { popdown_list %W }
  bind $entry <slash> { popdown_list %W }
}

proc path_expand {entry} {
  popdown_list $entry
  #get the path we have so far
  set pathsofar [$entry get]
  if [string length $pathsofar]==0 {
    set startpath .
    set nextpath ""
  } else {
    set pathels [split $pathsofar /]
    set nextpath [lindex $pathels end]
    set chopat [expr [llength $pathels]-2]
    set newpathels [lrange $pathels 0 $chopat]
    set startpath [join $newpathels /]
  }
  if ![file isdirectory $startpath/] {
    bell
    return
  }
  if ![file readable $startpath/] {
    bell
    return
  }
  set pattern "$nextpath*"
  set kids [glob -nocomplain $startpath/*]
  set good ""
  foreach kid $kids {
    if [string match $startpath/$pattern $kid] {
      lappend good $kid
    }
  }
  if [llength $good]==0 {    # no matches
    bell
    return
  } elseif [llength $good]==1 {    # one match
    set show [string range $good [string length $pathsofar] end]
    if [file isdirectory $good] {
      $entry insert end $show/
    } else {
      $entry insert end $show
    }
  } else {    # more than one match
    $entry insert end [more_non_unique $pathsofar $good]
    popup_list $entry $good
    bell
  }
}

proc popdown_list {entry} {
  if [winfo exists .pe_popup] {
    .pe_popup unpost
  }
}

proc popup_list {entry list} {
  set list [lsort $list]
  if ![winfo exists .pe_popup] {
    menu .pe_popup -tearoff 0
  } else {
    .pe_popup delete 0 end   
  }
  set length [llength $list]
  set maxw 0
  set widest 0
  for {set i 0} {$i<$length} {incr i} {
    set w [string length [lindex $list $i]]
    if $w>$maxw {
      set maxw $w
      set widest $i
    }
  }
  if ($length<10) {
    set columns 1
  } elseif ($length<45) {
    set columns 2
  } elseif ($length<80) {
    set columns 3
  } elseif ($length<150) {
    set columns 4
  } elseif ($length<240) {
    set columns 5
  } else {
    set columns 6
  }
  set rows [expr int($length/$columns)]
  if [expr $length%$columns] { incr rows }
  set i 0
  set skippath [expr [string length [file dirname [lindex $list 0]]]+1]
  #special case for starting path of "/"
  if $skippath==2 { set skippath 1 }
  foreach item $list {
    set tmp [string range $item $skippath end]
    set type [file type $item]
    switch $type {
      file { if [file executable $item] { set tmp "$tmp*" } }
      link { set tmp "$tmp@" }
      directory { set tmp "$tmp/" }
      fifo { set tmp "$tmp|" }
      socket { set tmp "$tmp=" }
      characterSpecial { set tmp "$tmp%" }
      blockSpecial { set tmp "$tmp%" }
    }
    if [expr $i%$rows]==0 {
      .pe_popup add command -label $tmp -columnbreak 1 -command "$entry delete 0 end; $entry insert end $item"
    } else {
      .pe_popup add command -label $tmp -command "$entry delete 0 end; $entry insert end $item"
    }
    incr i
  }
  set x [winfo rootx $entry]
  set y [expr [winfo rooty $entry]+[winfo height $entry]]
  .pe_popup post $x $y
  #focus .bar
  #grab -global .bar
}

proc more_non_unique {start matchlist} {
  set nonunique [lindex $matchlist 0]
  set startlen [string length $start]
  foreach a $matchlist {
    for {set i [string length $nonunique]} {$i>=0} {incr i -1} {
      if {"[string range $a 0 $i]"=="[string range $nonunique 0 $i]"} {
        set nonunique [string range $nonunique 0 $i]
        break
      } 
    }
  }
  return [string range $nonunique $startlen end] 
}

