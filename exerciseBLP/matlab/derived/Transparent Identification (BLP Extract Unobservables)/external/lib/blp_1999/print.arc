
proc printmat(x,mask,width,prec) ;
  local x,mask,width,prec ;
  local c,k,i,fstring,m,w,p,fnew,zz,f,mr,wr,pr ;
  k = cols(x) ;

  @ check for column vector @

  mr = rows(mask) ;
  wr = rows(width) ;
  pr = rows(prec) ;
  if mr==1 ; mask=mask' ; mr=rows(mask) ; endif ;
  if wr==1 ; width=width' ; wr=rows(width) ; endif ;
  if pr==1 ; prec=prec' ; pr=rows(prec) ; endif ;

  @ fill out vectors with last item if necessary @

  do while mr<k ;
    mask = mask|mask[mr,1] ;
    mr = rows(mask) ;
  endo ;

  do while wr<k ;
    width = width|width[wr,1] ;
    wr = rows(width) ;
  endo ;

  do while pr<k ;
    prec = prec|prec[pr,1] ;
    pr = rows(prec) ;
  endo ;

  @ loop through to create format matrix for printfm @

  i = 1 ;
  fstring = "-*.*s "|"*.*lf " ;
  do while i<=k ;
    m = mask[i,1] ;
    w = width[i,1] ;
    p = prec[i,1] ;
    c = fstring[m+1,1] ;
    fnew = c~w~p ;
    if i==1 ;
      f = fnew ;
    else ;
      f = f|fnew ;
    endif ;
    i = i+1 ;
  endo ;

  @ print using printfm and return 1 if successful @

  zz=printfm(x,mask',f) ;
  retp(zz) ;
endp ;



/* this file prints a column of alpha numeric data followed by any number of
   columns of data.  it uses the procedure printmat */
proc printan(x) ;
  local x,mask,width,prec,zz ;
  let mask = 0 1 ;
  let width = 8 ;
  let prec = 8 3 ;
  zz=printmat(x,mask,width,prec) ;
  retp(" ") ;
endp ;
/* this file prints a column of alpha numeric data followed by any number of
   columns of data.  it uses the procedure printmat */
proc printna(x) ;
  local x,mask,width,prec,zz ;
  let mask = 1 0 ;
  let width = 8 ;
  let prec = 3 8 ;
  zz=printmat(x,mask,width,prec) ;
  retp(" ") ;
endp ;
