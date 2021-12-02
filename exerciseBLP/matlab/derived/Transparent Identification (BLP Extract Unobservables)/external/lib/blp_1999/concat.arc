proc concatv(x,y) ;
  local x,y ;
  if not scalmiss(x) ;
    x = x|y ;
  else ;
    x = y ;
  endif ;
  retp(x) ;
endp ;


proc concath(x,y) ;
  local x,y ;
  if not scalmiss(x) ;
    x = x~y ;
  else ;
    x = y ;
  endif ;
  retp(x) ;
endp ;
