	  
@ ************************************************************** @
@ This file contains the procedures for the program "gmest.prg"
   11/92
   The utility function is:
   u_ij = x_j*b_i  - (alpha/Y_i)*p_j + xi_j + e_ij
 
   You can set alpha0 = 0 in proc defdata below.  Otherwise, there
   is very little difference from earlier versions.
 
                                                                  @
@ ************************************************************** @
 
 
@ ***** THIS IS PROC DEFDATA ********* @
 

proc (0)=defdata(yr,parm) ;
  clearg ysim,neg,yp,xr,sumneg ;
  alpha = parm[1] ;                @ alphai = alpha/ysimi @
  sig = parm[2:krand+1] ;            @ sigmas on x's  @
  lamda = parm[krand+2:kparm] ;
  
  nyr = nvec[yr] ;
  r1 = rmat[yr,1] ;
  r2 = rmat[yr,2] ;
  xyr = x[r1:r2,.] ;
  xrand = xrandall[r1:r2,.] ;  @ these x's have random coeff @
  shares = sharevec[r1:r2] ;
  firmid = firmids[r1:r2] ;
  pyr = p[r1:r2] ;
  qsetvec = qsetters[r1:r2].*seqa(1,1,nyr) ;
  qsetvec = selif(qsetvec,qsetvec.>0) ;
  psetvec = psetters[r1:r2].*seqa(1,1,nyr) ;
  psetvec = selif(psetvec,psetvec.>0) ;
  
  ysim = exp(meanly[yr]+sigly*ynorm) ;      @ income draws @
  alphai = alpha./ysim ;
  xr = xrand*(sig.*xnorm) ;                 @ random x term @
  randij = xr - alphai.*pyr ;               @ total random term @
endp ;


@
Calculate shares given delta.  Note this assumes that defdata has
already been run.
@

proc sharep(delta) ;
  local exb,shrpred ;
  clearg sij ;
  exb = exp(delta+randij) ;             @ if exp blows up it must be bounded @
  sij = shr_wt.*exb./(1+sumc(exb)') ;
  sij = sij' ;                 @ sij is nsim by nyr and remains in memory @
  shrpred = meanc(sij) ;
  retp(shrpred) ;
endp ;


@
For a given year, the following "contracts" to find a new value for delta.
Once again, this assumes that defdata has been run
@


proc deltap(d0) ;
  local j,tol,exp_dold,exp_dyr,exr,sexr,exb,denom,phi ;
  exp_dold = exp(d0) ;
  exp_dyr = exp_dold ;
  exr = exp(randij) ;
  sexr = shr_wt.*exr ;
  
  j = 1 ; tol = 1 ;
  do until tol < deltol ;              @ improve by contracting @
    exb = exp_dyr.*exr ;
    denom = (1+sumc(exb)') ;
    phi = sexr./denom ;
    phi = meanc(phi') ;
    exp_dyr = shares./phi ;    @ this is the contraction @
    tol = maxc( abs( (exp_dold./exp_dyr) - 1) ) ;
    exp_dold = exp_dyr ;                       @ keep track of last guess @
    j = j+1 ;
  endo ;
  
  retp(ln(exp_dyr)) ;
endp ;


@ The next proc loops over years to find delta and markup for all years @

proc (2) = del_mark(parm) ;
  local yr ;
  clearg dyr ;
  delta = zeros(n,1) ;
  markup = delta ;
  yr = 1 ;
  "looking for new delta in yr: " ;;
  do until yr>years ;
    defdata(yr,parm) ;
    format /rd 2,0 ; yr ;; format 6,4 ;
    dyr = deltap(del_last[r1:r2]) ;
    delta[r1:r2] = dyr ;
    myr = mark(dyr) ;
    markup[r1:r2] = myr ;
    yr = yr+1 ;
  endo ;
  del_last = delta ;
  " " ;
  retp(delta,markup) ;
endp ;



@
The next proc loops over years to find delta (but not the markup) for
  all years
@
  
  proc del(parm) ;
    local yr,myr ;
    clearg dyr ;
    delta = zeros(n,1) ;
    yr = 1 ;
    "looking for new delta in yr: " ;;
    do until yr>years ;
      defdata(yr,parm) ;
      format /rd 2,0 ; yr ;; format 6,4 ;
      dyr = deltap(del_last[r1:r2]) ;
      delta[r1:r2] = dyr ;
      yr = yr+1 ;
    endo ;
    del_last = delta ;
    " " ;
    retp(delta) ;
  endp ;
  
  
  
@
  Obj calculates the objective function.  It calls proc del and then
    calculates beta and the demand "error".
@
    

proc obj(parm) ;
  local object,d_del,zx,e,g,y,bxw,lnmc,not_ok,sumbad,simp,
  fvec,lamvec,mc ;
  clearg prederr ;
  {delta,markup} = del_mark(parm) ;  @ delta,markup,mc are globals @
  
  /*
  @ these lines are for an "inner loop" search over lamda @
  
  pm = p-markup ;
  "make simplex for obj-inner" ;
  {simp,fvec} = makesimp(lamda,0.2,&objinner) ;
  " " ; " amoeba for obj-inner" ; " " ;
  {lamda,object} = amoeba1(simp,fvec,0.001,&objinner) ;
  */
  
  lamvec = verdum*lamda ;
  mc = p-markup-lamvec ;


  @ These lines check for negative MC @

  not_ok = (mc.<=0) ;
  mc = mc + not_ok.*(0.001-mc) ;  @ set mc to one dollar if neg @
  "number of neg MC: " sumc(not_ok) ;

  @ now take log @


  lnmc = ln(mc) ;  
  y = delta | lnmc ;                                                
  depvar = y ;
  bxw = inv(zxw'zxw)*zxw'z'y ;   @ instrumental var estimate of beta @
  bx = bxw[1:kx] ; bw = bxw[kx+1:kx+kw] ;
  e = y-xw*bxw ;
  prederr = e ;                    @ the error is 2N by 1 @
  g = (z'e)/n ;
  object = g'g  ;
  
  
  format 6,4 ;
  output file=^outfile on ;
  " " ; "outer loop : " timestr(0) ;
  format 5,3 ; (parm)' ; "bx: " bx' ; "bw: " bw' ; 
  "lamda: " lamda' ; format 10,8 ; object ;
  output off ;
  retp(object) ;
endp ;


proc gshared(delta) ;                   @ deriv of share wrt delta @
  local exb,j,s,g,gsum,shrpred ;
  clear gsum ;
  exb = exp(delta+randij) ;
  s = exb./(1+sumc(exb)') ;
  j = 1 ;                     @ calculate gradients @
  do until j>nsim ;
    gsum = gsum - shr_wt.*s[.,j].*s[.,j]' ;
    j = j+1 ;
  endo ;
  shrpred = meanc((shr_wt.*s)') ;
  g = gsum/nsim ;
  g = g + eye(rows(g)).*shrpred ;
  retp(g) ;
endp ;
    

@ Grady calculates the derivative of delta and wrt parameters @

proc grady(delta,markup,parm) ;
  local kp,yr,gdel,shr0,ds_dparm,dh,k,imat,parm1,shr1,dyr,
  gmark,m1,gy ;
  dh = .01 ;
  kp = rows(parm) ;
  yr = 1 ;
  gdel = zeros(n,kp) ;
  gmark = gdel ;
  "finding derivatives in yr: " ;;
  do until yr>years ;
    yr ;;
    defdata(yr,parm) ;
    dyr = delta[r1:r2] ;
    shr0 = sharep(dyr) ;
    k = 1 ;  imat = eye(kp)  ;
    ds_dparm = zeros(nyr,rows(parm)) ;
    do until k>kp ;                 @ loop to get numeric gradients @
      parm1 = parm + imat[.,k]*dh ;
      defdata(yr,parm1) ;
      shr1 = sharep(dyr) ;
      ds_dparm[.,k] = (shr1-shr0)/dh ;
      m1 = mark(dyr) ;
      gmark[r1:r2,k] = (m1-markup[r1:r2])/dh ;
      k = k+1 ;
    endo ;
    gdel[r1:r2,.] = -inv( gshared(dyr) )*ds_dparm ; @ gdel via chain rule @
    yr = yr+ 1;
  endo ; " " ;
  gy = gdel|gmark ;
  retp(gy) ;
endp ;


@ Derivative of shares wrt price
(cross terms >0 only if owned by the same firm) 
@

proc gsharep1(delta) ;
  local j,k,exb,s,g ;
  
  exb = exp(delta+randij) ;    @ calculate share matrix @
  s = exb./(1+sumc(exb)') ;
  g = zeros(nyr,nyr) ;
  j = 1 ;                     @ calculate gradients @
  do until j>nyr ;
    k = j;
    do until k>nyr ;
      if firmid[k] == firmid[j] ;
	g[k,j] = meanc((shr_wt.*( ((j==k)*s[j,.]) - s[j,.].*s[k,.]).*alphai )') ;
      endif ;
      k = k+1 ;
    endo ;
    g[j,.] = g[.,j]' ;
    j = j+1 ;
  endo ;
  retp(g) ;
endp ;
  

proc gsharep(delta) ;
  local j,k,exb,s,g ;
  
  exb = exp(delta+randij) ;    @ calculate share matrix @
  s = exb./(1+sumc(exb)') ;
  g = zeros(nyr,nyr) ;
  j = 1 ;                     @ calculate gradients @
  do until j>nyr ;
    k = j ;
    do until k>nyr ;
      g[k,j] = meanc((shr_wt.*( (j==k)*s[j,.] - s[j,.].*s[k,.] ).*alphai )') ;
      k = k+1 ;
    endo ;
    g[j,.] = g[.,j]' ;
    j = j+1 ;
  endo ;
  retp(g) ;
endp ;

@ markup for price and qty setting @


proc mark(dyr) ;
local myr,g11i,g11,g21,g12,g22,firmidq,firmidp,g,dq2_dp2 ;
  
  if scalmiss(qsetvec) ;                    @ no qty-setting firms @
    g = gsharep1(dyr);
    myr = invpd(g)*shares ;
  else ;				@ some qty-setters  @
    
    g = gsharep(dyr) ;
    myr = zeros(nyr,1) ;
    
    @ get q-setting markups @
    
    g11 = g[qsetvec,qsetvec] ;         @ in write-up, df1_dp1 @ 
    g11i = invpd(g11) ;
    firmidq = firmid[qsetvec] ;
    myr[qsetvec] = (g11i.*(firmidq.==firmidq'))*shares[qsetvec] ;
    
    @ now price-setting @
    
    if not scalmiss(psetvec) ;              @ if any price-setting @
      
      g12 = g[qsetvec,psetvec] ;    @ in write-up, df1_dp2 @ 
      g21 = g[psetvec,qsetvec] ;    @ in write-up, df2_dp1 @ 
      g22 = g[psetvec,psetvec] ;    @ df2_dp2 @ ;
      
      dq2_dp2 = g22 + (g21*g11i*g12) ;
      
      firmidp = firmid[psetvec] ;
      
      dq2_dp2 = dq2_dp2.*(firmidp.==firmidp') ;
      myr[psetvec] = invpd(dq2_dp2)*shares[psetvec] ;
      
    endif ;
  endif ;
  
  retp(myr) ;
endp ;




/*  old procs mark
 
 proc mark(dyr) ;
   local myr,gi ; clearg g ;
   if conduct==1 ;
     g = gsharep(dyr);
     gi = invpd(g).*(firmid.==firmid') ;  @ for cournot, set cross terms to zero AFTER inverting @
     myr = gi*shares ;
   endif ;
   if conduct==0 ;
     g = gsharep1(dyr);
     myr = invpd(g)*shares ;
   endif ;
   retp(myr) ;
 endp ;
 


proc mark(dyr) ;
  local myr ; clearg g ;
  g = gsharep1(dyr);
  myr = invpd(g)*shares ;
  retp(myr) ;
endp ;

*/
  
@ this procedure is used in drawopt @

proc sij_(xnorm,ynorm,yr) ;
  local ysim,exb,s,alphai ;
  clearg randij ;
  ysim = exp(meanly[yr]+sigly*ynorm) ; clear ynorm ;
  
  alphai = alpha./ysim ;
  xrand = xrandall[r1:r2,.] ;  @ these x's have random coeff @
  xr = xrand*(sig.*xnorm) ;                 @ random x term @
  randij = alpha0*ln(ysim) + xr - alphai.*pyr ;               @ total random term @
  
  clear xr,alphai,xnorm ;
  
  exb = exp2(dyr+randij) ;
  
  s = exb./(1+sumc(exb)') ;
  clear exb ;
  
  retp(s') ;
endp ;


proc (3)=drawopt(nfind,delta) ;
  local yr,nsim,nsim1,s_in,shr,s2,loop,s,i,s_inave,
  newxnorm,newynorm,shr_wt,count,j,u,accept,bigwt,
  xnorm,ynorm,ysim,xr,randij,exb,s1,shr1,bigxnorm,bigynorm,alphai ;
  
  @ loop across the years, creating a large number of draws @
  
  rndseed kseed2 ;
  yr = 1 ;
  do until yr>years ;
    "taking draws in yr  " yr ; " " ;
    defdata(yr,parm0) ;
    dyr = delta[r1:r2] ;
    nsim = 1000 ; nsim1 = 200 ;
    s_in = zeros(nsim,1) ;
    shr = 0 ; s2 = 0 ;
    loop = 1 ;
    i = 1 ;
    do until loop>(nsim/nsim1) ;
      loop ;;
      s = sij_(rndn(krand,nsim1),rndn(1,nsim1),yr) ;
      s2 = s2 + sumc(s.*s) ;
      shr = shr+sumc(s) ;
      s_in[i:i+nsim1-1] = sumc(s') ;
      i = i+nsim1 ;
      loop = loop+1 ;
    endo ; " " ;
    shr = shr/nsim ;
    s_inave = meanc(s_in) ;
    
    @ accept a small set of draws for each year, keeping track of weight @
    
    newxnorm = zeros(krand,nfind) ;
    newynorm = zeros(1,nfind) ;
    shr_wt   = zeros(1,nfind) ;
    count = 0 ;
    j = 1 ;
    loop = 1 ;
    do until count>=nfind ;
      xnorm = rndn(krand,nsim1) ;
      ynorm = rndn(1,nsim1) ;
      s = sij_(xnorm,ynorm,yr) ;
      s_in = sumc(s') ;
      u = rndu(nsim1,1) ;
      i = 1 ;
      do until (i>nsim1) or (count>=nfind) ;
	accept = u[i].<s_in[i] ;
	if accept ;
	  count = count+1 ;
	  newxnorm[.,count] = xnorm[.,i] ;
	  newynorm[.,count] = ynorm[i] ;
	  shr_wt[count] = s_inave/s_in[i] ;
	  count~xnorm[.,i]'~ynorm[i] ;
	endif ;
	i = i+1 ;
	j = j+1 ;
      endo ;
      loop = loop+1 ;
    endo ;
    xnorm = newxnorm ;
    ynorm = newynorm ;
    ysim = exp(meanly[yr]+sigly*ynorm) ;
    
    
    alphai = alpha./ysim ;
    xrand = xrandall[r1:r2,.] ;  @ these x's have random coeff @
    xr = xrand*(sig.*xnorm) ;                 @ random x term @
    randij = alpha0*ln(ysim) + xr - alphai.*pyr ;               @ total random term @
    
    exb = exp(dyr+randij) ;
    s1 = exb./(1+sumc(exb)') ;
    s1 = (s1.*shr_wt)' ;
    shr1 = meanc(s1) ;
    
    if yr==1 ;
      bigxnorm = xnorm ; bigynorm = ynorm ; bigwt = shr_wt ;
    else ;
      bigxnorm = bigxnorm~xnorm ; bigynorm = bigynorm~ynorm ;
      bigwt = bigwt~shr_wt;
    endif ;
    
    yr = yr+1 ;
  endo ;
  retp(bigxnorm,bigynorm,bigwt) ;
endp ;


proc perchg(x,y) ;
  local x,y,p ;
  p = 2*abs(x-y)./abs(x+y) ;
  retp(100*p) ;
endp ;


proc (2)=exch(x) ;
  local x,zexch,ztot,kx,yr,xyr,sumx,k,idmat ;
  kx = cols(x) ;
  zexch = zeros(n,kx) ;
  ztot = zeros(n,kx) ;
  yr = 1 ;
  do until yr>years ;
    defdata(yr,parm0) ;      @ parm isn't nec here @
    idmat = firmid.==firmid' ;
    xyr = x[r1:r2,.] ;
    sumx = sumc(xyr) ;
    ztot[r1:r2,.] = ones(nyr,kx).*sumx' ;
    k = 1 ;
    do until k>kx ;
@     zexch[r1:r2,k] = sumc( (xyr[.,k].*idmat)' ) ;      OLD MISTAKEN WAY @
      zexch[r1:r2,k] = sumc(xyr[.,k].*idmat ) ;  @ NOTE CORRECTION @
      k = k+1 ;
    endo ;
    yr = yr+1 ;
  endo ;
  retp(zexch,ztot) ;
endp ;


@ PROCEDURES NEW TO STRUC-INSTR.PRG @

@ mdparm calculates del and parm as a function @

proc mdparm(parm) ;    @ takes deriv of delhat, mkhat, wrt parms @

  local j,tol,exp_dold,exp_dyr,exr,sexr,exb,denom,phi,mnew,delnew,mknew,g,d0 ;
  
  @ do the defdata stuff, with phat,shat @
 
  defdata(yr,parm|lamda) ;		@ year better be defined globally  @
  shares = shat[r1:r2] ;		@  redefine shares  @
  pyr = phat[r1:r2] ;			@ redefine price  @
  
  randij = xr - alphai.*pyr ;           @ new price, so new randij @
  
  delnew = deltap(delhat[r1:r2]) ;
  
  mknew = mark(delnew) ;
  
  retp(delnew|mknew) ;
endp ;


@ this proc takes x, removes perfectly collinear columns  @
@ and also removes nearly collinear columns, according to @
@ the tolerance in r2_tol, the max allowed r-sq from      @
@ regression of one column on others                      @

proc uncollin(x,r2_tol) ;
  local xnew,i,y,xxi,b,e,yd,r ;
  
  i = 2 ;
  xnew = x[.,1] ;
  
  do until i>cols(x) ;
    y = x[.,i] ;		@ might add this column  @
    trap 1 ;				@ trap any inversion error  @
    xxi = invpd((xnew~y)'(xnew~y)) ;
    trap 0 ;
    
    if scalerr(xxi) ;			@ didn't invert  @
      i ;; 
      " kill for rank" ;
    else ;				@ did invert  @
      
      @ get R^2 @
      
      b = y/xnew ;                  @  ols, new column on old   @
      e = y -  xnew*b ;
      yd = y - meanc(y) ;
      r = 1-(e'e)/(yd'yd) ;    @ original code was bugged on this line @
      if r>r2_tol ;			@ can adjust tol here  @
	i ;; "kill for R2 of " ;; r ;
      else ;
	i ;; "keep for R2 of " ;; r ;
	xnew = xnew~y ;
      endif ;
    endif ;
    i = i+1 ;
  endo ;
  retp( xnew ) ;
endp ;


@ markup as a function of price @



proc mkprice(pyr) ;
  local myr,g,exb,sij ;
  randij = xr - alphai.*pyr ;               @ total random term @
  exb = exp(dyr+randij) ;             @ if exp blows up it must be bounded @
  sij = shr_wt.*exb./(1+sumc(exb)') ;
  shares = meanc(sij') ;                 @ sij is nsim by nyr and remains in memory @
  g = gsharep1(dyr);
  myr = invpd(g)*shares ;
  retp(myr) ;
endp ;


proc (2)= prederr_(parm) ;
  local parm,f,y,e ;
  f = obj(parm) ;
  y = depvar ;
  e = y-xw*bxw0 ;
  retp(e,f) ;
endp ;






 
 
proc (2)=amoeba1(p,y,ftol,&f);        @ Procedure takes matrix p as input,  @
                                 @ where p is an initial NDIMx1 point  @
                                 @ augmented with a matrix of vertices @
                                 @ so that p defines an n-dimensional  @
                                 @ simplex.  Y contains the function   @
                                 @ values for the n+1 vertices for the @
                                 @ function f which is to be minimized @
                                 @ to a tolerance ftol.                @
                                 @ The procedure returns the simplex   @
                                 @ containing the minimizer vertically @
                                 @ concatenated with the vector of     @
                                 @ function values above it; i.e.,     @
                                 @ y'|p.                               @

         local nmax,aleph,bet,gimel,itmax,mpts,ilo,ihi,inhi,tol,
                 pbar,pr,ypr,yprr,prr,iter,ndim,i,ytemp,mp,toly ;

         local f:proc;

         nmax=90; aleph=1.0; bet=0.5; gimel=2.0; itmax=500;

         ndim=rows(p);
         mpts=ndim+1;
         output file = amoeba.out reset ;

         "****BEGIN NELDER & MEAD MINIMIZATION****";
          "toly is set at 0.001     " ;
         iter=0;

do until iter>itmax;             @ BEGIN MAIN LOOP. @

@----------------------------------------------------------------------@
@
         The following finds the point with the highest function value,
         the next highest, and the lowest.
@

         ilo=minindc(y); ihi=maxindc(y);
         ytemp=miss(y,maxc(y));
         inhi=maxindc( ytemp );

         tol = maxc(maxc(abs(p[.,ilo]-p))) ;
         toly = (maxc(y-minc(y)))/maxc(y) ;

@----------------------------------------------------------------------@
@
         Print current results.
@
         save fvec=y;             @ Save values @
         save simplex=p;
         format 8,4 ; output file =amoeba.out on  ;
         " " ; "Simplex/Fvec " ;
         p ; " " ; y' ; " " ;
         "Amoeba Iteration: ";; format /rd 3,0; iter;
         "***Low function value: ";; format 10,8 ; minc(y);
         format 6,5 ; "Low estimate:  ";; (p[.,ilo])';
         "Current tolerances (tol/toly): ";; tol~toly; " " ;
         output off ;


@----------------------------------------------------------------------@

@
         TEST FOR DONE:
@

         if (tol<ftol) ;  @ toly is %diff in obj function @
           retp( p[.,ilo],y[.,ilo] );
           iter=itmax;
         endif;  @ Convergence.    @

         if iter==itmax;
           save fvec=y;             @ Save values @
           save simplex=p;
           print "AMOEBA exceeding maximum iterations. ";
           retp( p[.,ilo],y[.,ilo] );
           iter=itmax;
         endif;
         iter=iter+1;

@----------------------------------------------------------------------@
@
         The following computes the vector average of all vertices
         in the simplex except the one with the high function value.
@
         if ihi/=1 and ihi/=mpts;
                 pbar=meanc( (p[.,1:ihi-1]~p[.,ihi+1:mpts])' );
         elseif ihi==1;
                 pbar=meanc( p[.,2:mpts]' );
         elseif ihi==mpts;
                 pbar=meanc( p[.,1:mpts-1]' );
         endif;

@----------------------------------------------------------------------@

         pr = (1+aleph)*pbar - aleph*p[.,ihi];    @ Reflect high point @
                                                  @ through average.   @

         ypr=f(pr);                               @ Evaluate new point.@

         if ypr<=y[ilo,1];                        @ If new point is the@
                 prr=gimel*pr + (1-gimel)*pbar;   @ best so far, try to@
                 yprr=f(prr);                     @ extend reflection. @

                 if ( yprr < minc(y[ilo,1]|ypr) ); @ Extension succeeds,@
                         p[.,ihi]=prr;             @ so replace high    @
                         y[ihi,1]=yprr;            @ point with new one.@

                 else;                            @ Extension fails,   @
                         p[.,ihi]=pr;             @ but can still use  @
                         y[ihi,1]=ypr;            @ reflected point.   @

                 endif;

         elseif ypr>=y[inhi,1];                   @ If reflected point is   @
                                                  @ worse than 2nd highest  @
                 if ypr<y[ihi,1];                 @ but better than highest,@
                         p[.,ihi]=pr;             @ replace highest...      @
                         y[ihi,1]=ypr;
                 endif;
                                                  @...but look for better.  @
                 prr=bet*p[.,ihi] + (1-bet)*pbar;
                 yprr=f(prr);

                 if yprr<y[ihi,1];                @ Contraction improves.   @
                         p[.,ihi]=prr;
                         y[ihi,1]=yprr;

                 else ;                           @ Can't get rid of high pt@
                         i=1;                     @ so contract the simplex @
                         do until i>mpts;
                            if i/=ilo;
                                 pr=0.5*(p[.,i]+p[.,ilo]);
                                 y[i,1]=f(pr);
                                 p[.,i] = pr ;
                            endif;
                            i=i+1;
                         endo;
                 endif;

         else;                                    @ Arrive here with   @
                 p[.,ihi]=pr;                     @ middling point.    @
                 y[ihi,1]=ypr;
         endif;


endo;
endp;
