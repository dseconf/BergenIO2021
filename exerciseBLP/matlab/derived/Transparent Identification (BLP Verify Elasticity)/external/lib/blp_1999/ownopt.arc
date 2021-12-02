proc amoeba(p,y,ftol,&f);        @ Procedure takes matrix p as input,  @
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
          "toly is set at  0.000001    " ;
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
         format 8,4 ; output file = amoeba.out on  ;
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

         if (tol<ftol) or (toly< 0.000001) ;  @ toly is %diff in obj function @
           retp( p[.,ilo] );
           iter=itmax;
         endif;  @ Convergence.    @

         if iter==itmax;
           save fvec=y;             @ Save values @
           save simplex=p;
           print "AMOEBA exceeding maximum iterations. ";
           retp( p[.,ilo] );
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




proc (2)=golden(&obj,x,f,tol) ;
  local obj:proc,x,f,tol,xnew,fnew,direc ;

  do until (x[3]-x[1])<tol ;
    output file=^outfile on ;
    " " ; "GOLDEN " ; x' ; f' ; " " ;
    output off ;
    direc = (x[3]-x[2]) > (x[2]-x[1]) ;
    direc = 2*direc - 1 ;
    xnew = 2*x[2]/3 + x[2+direc]/3 ;
    fnew = obj(xnew) ;
    if fnew<f[2] ;
      x[2-direc] = x[2] ; f[2-direc] = f[2] ;
      x[2] = xnew ; f[2] = fnew ;
    else ;
      x[2+direc] = xnew ; f[2+direc] = fnew ;
    endif ;
  endo ;
  retp(x[2],f[2]) ;
endp ;



@
  name:  bracket.prc

  this procedure "brackets" a function by finding 3 values of x such that
  x1<x2<x3 and f(x1)>f(x2) and f(x3)>f(x2).  Therefore, we know that a (local)
  minimum of f( ) exists between x1 and x3.  The returned x and f vectors serve
  as inputs into a golden line search algorithm.

  The procedure requires the function f, an intital point x1 and a
  positive increment, "incr."  The function is first evaluated at x1
  and (x1+abs(incr)) ; the procedure decides where to go from there.
@

proc (2)=bracket(&f,x1,incr) ;
  local f:proc,x1,incr,x2,f1,f2,xv,fv ;
  incr = abs(incr) ;
  startbrc:
  f1 = f(x1) ;
  x2 = x1+incr ;
  f2 = f(x2) ;
  if f1<f2 ;           @ search for a new low value for x @
    xv = (x1-incr)|x1|x2 ;   @ intial vector of x's @
    fv = f(xv[1])|f1|f2 ;    @ intial vector of f's @
    do while fv[2]>=fv[1] ;
      output file=^outfile on ; " " ; "BRACKET" ; xv' ; fv' ; output off ;
      if fv[2]>fv[1] ;
        xv = (xv[1]-incr)|xv[1:2] ;  @ shift right @
        fv = f(xv[1])|fv[1:2] ;
      else ;                         @ else is fv[1] = fv[2] @
        xv[1] = xv[1]-incr ;
        fv[1] = f(xv[1]) ;
      endif ;
    endo ;
  elseif f1>f2 ;       @ search for a new high value for x @
    xv = x1|x2|(x2+incr) ;  @ intial x vector @
    fv = f1|f2|f(xv[3]) ;   @ intial f vector @
    do while fv[2]>=fv[3] ;
      output file=^outfile on ; " " ; "BRACKET" ; xv' ; fv' ; output off ;
      if fv[2]>fv[3] ;
        xv = xv[2:3]|(xv[3]+incr) ;  @ shift left @
        fv = fv[2:3]|f(xv[3]) ;
      else ;
        xv[3] = xv[3]+incr ;      @ handle equality @
        fv[3] = f(xv[3]) ;
      endif ;
    endo ;
  else ;     @ what if intial f1==f2? @
    incr = 2*incr ;
    goto startbrc ;
  endif ;
  retp(xv,fv) ;
endp ;


proc (2)=makesimp(x,incr,&f) ;   @ make a simplex for amoeba @
  local x,incr,k,fvec,simp,i ;
  local f:proc ;
  k = rows(x) ;
  fvec = zeros(k+1,1) ;
  simp = zeros(k,k+1) ;
  simp[.,1] = x ;
  fvec[1] = f(x) ;
  i = 2 ;
  do until i>(k+1) ;
    simp[.,i] = x ;
    simp[i-1,i] = x[i-1] + incr[i-1] ;
    fvec[i] = f(simp[.,i]) ;
    i = i+1 ;
  endo ;
  retp(simp,fvec) ;
endp ;


  