
 @ THESE PROCEDURES CALCULATE CORR'S AND COV MATRICES @

 proc corr(x) ;
   local m,x,v,s,c;
   m = meanc(x) ;
   v = x'x/(rows(x)) - m*m' ;
   s = sqrt(diag(v)) ;
   c = v./(s*s') ;
   retp(c) ;
 endp ;


 proc cov(x) ;
   local m,x,v,s,c;
   m = meanc(x) ;
   v = x'x/(rows(x)) - m*m' ;
   retp(v) ;
 endp ;


 @ THESE PROCEDURES ESTIMATES ONE EQUATION MODELS @
 @ THEY INCLUDE OLS, 2SLS AND GMM.                @
 @ PRINTING IS CONTROLLED BY "PRINTVAR", WHICH    @
 @ IS EXPLAINED BELOW.                            @
 @ (USU. PRINTVAR CONTAINS VARIABLE NAMES.)       @


 proc (2)=ols(y,x,printvar) ;
   local x,y,printvar,nobs,k,xxi,b,e,vc,stderr,rsq ;
   nobs = rows(x) ;
   k = cols(x) ;
   xxi = inv(x'x) ;
   b = xxi*x'y ;
   e = y-x*b ;
   vc = (e'e)*xxi/(nobs-k) ;
   stderr = sqrt(diag(vc)) ;
   rsq = 1-(cov(e)/cov(y)) ;
   printout(b,stderr,printvar,"OLS") ;
   format 5,3 ; "R-SQ = " rsq ; " " ;
   "NOBS = " nobs ;
   retp(b,stderr) ;
 endp ;


 proc (2)=twosls(y,x,z,printvar) ;
   local x,y,z,printvar,nobs,k,xxi,b,e,vc,stderr,rsq,rv,zzi ;
   nobs = rows(x) ;
   k = cols(x) ;
   zzi = inv(z'z) ;
   b = inv(x'z*zzi*z'x)*x'z*zzi*z'y ;
   e = y-x*b ;
   rv = e'e-nobs*(meanc(e)^2) ;
   vc = rv*inv(x'z*zzi*z'x)/(nobs-k) ;
   stderr = sqrt(diag(vc)) ;
   printout(b,stderr,printvar,"2SLS") ;

   format 5,3 ; "R-SQ = " (1-(cov(e)/cov(y))) ; " " ;
   retp(b,stderr) ;
 endp ;


 @ a one equation, linear, method of moments routine: @



 proc (2)=gmm1(y,x,z,printvar) ;
   local y,x,z,printvar,n,loop,zx,b,g,vg,gam,ggi,vb,se,a,e ;
   n = rows(x) ;
   loop = 1 ;
   a = eye(cols(z)) ;
   do until loop>2 ;
      zx = z'x ;
      b = invpd(zx'a*zx)*zx'a*z'y ;
      e = y-x*b ;
      g = z.*e ;
      vg = cov(g) ;
      gam = zx/n ;
      ggi = invpd(gam'gam) ;
      vb = ggi*gam'vg*gam*ggi/n ;
      se = sqrt(diag(vb)) ;
      format 1,0 ; " " ; "STAGE " loop ;; " RESULTS IN GMM1: " ; " " ;
      printout(b,se,printvar,"GMM1") ;
      format 5,3 ; "R-SQ = " (1-(cov(e)/cov(y))) ; " " ;
      a = invpd(vg) ;
      loop = loop + 1 ;
    endo ;
    retp(b,se) ;
 endp ;


 @ THIS PRINTS OUT RESULTS:                                      @
 @ if printvar==0: nothing prints                                @
 @ if printvar==1: results print with no names                   @
 @ if cols(printvat)=cols(b): print results and xnames           @
 @ if cols(printvat)=(cols(b)+1): print results, depvar name     @
 @      and xnames (depvar name comes first)                     @
 @ else: an error message prints.                                @


 proc (0)=printout(b,se,printvar,procname) ;
   local b,se,printvar,k,kp ;

   " " ; " " ; "RESULTS FOR: " $procname ; " " ;
   k = rows(b) ; kp = rows(printvar) ;
   if not (printvar==0) ;
     format /rd 8,4 ;
     " " ;
     if printvar==1 ;
       "   PARM     (SE)" ;
       format 8,4 ; b~se ;
     elseif kp==k ;
       "VAR         PARM      SE" ;" " ;
       printan(printvar~b~se) ;
     elseif kp==(k+1) ;
       "Dependent Variable is: " $printvar[1] ; " " ;
       "VAR         PARM      SE" ;" " ;
       printan(printvar[2:kp]~b~se) ;
     else ;
       "WHAT DID YOU WANT PRINTED in  " $procname ;
       "(name vector not conformable)" ;
     endif ;
   endif ;
 endp ;


 proc exp2(x) ;    @ prevents exp from returning a bad value @
   local x,limit,ok,signx ;
   limit = 700 ;
   if not ( abs(x)<limit ) ;
     ok = abs(x) .< limit ;         @ check for bad numbers  @
     signx = (x.>0)-(x.<0) ;
     x = x.*ok + (1-ok).*limit.*signx ;
   endif ;
   retp( exp(x) ) ;
 endp ;
