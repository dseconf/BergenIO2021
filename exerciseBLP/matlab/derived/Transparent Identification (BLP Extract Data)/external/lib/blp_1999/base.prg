new ;

@ these are the libraries @

library gauss,/home/jamesl/gauss/ownlib/berry,
        /home/jamesl/gauss/ownlib/struc-inst-steve2 ;


outfile = "20.1.1.1.0_macro.out"  ;

@ these variables control how the program is run @

start_wt = 1 ;           @ set to 1 to begin with "optimal" weighting matrix @
twoloop = 1 ;            @ set to 1 to use opt. weights on a second loop @
loaddraw = 0 ;           @ set to 1 to load random draws from disk, @
newdraw = 1 ;            @ set to one to run drawopt.prc @
loadz = 0 ;              @ set to one to load instr. from disk (see below) @

newstart = 1;           @ set to one to calc new simplex and aweight @
endflag = 0 ;         @ set to one to load simplex and calculate se's, etc.@
dfiflag = 1 ;       @ set to one if marginal Japanese car is produced in U.S. 
                         where applicable, zero if from Japan              @
ciflag = 1 ;        @ set to one to count captive imports against the ver  @			   
nfind = 20 ;             @ # of simulation draws per year for drawopt @
conduct =0 ;         @ Set to 0 if Bertrand, 1 for Cournot, 2 for mixed @  

onelam = 1 ;          @ Set to 1 to constrain all VER lambdas to be equal @

newse = 1 ;  @ Set to 1 to create new stuff for standard errors, else 0 @
             @  For you, Steve. @
nsim = 1500 ;

@ print out flags @

output file=^outfile reset ; " " ;

$timestr(0) ;
$datestr(0) ;

"nfind " nfind ;
"onelam " onelam ;
"dfiflag " dfiflag ;
"ciflag " ciflag ;
"conduct " conduct ;
"loaddraw " loaddraw ;
output off ; 

clear qsetvec,psetvec ;
clear name,id,yr,cy,dr,at,ps,air,drv,p,wt,dom,disp,hp,lng,pm,sij,
wdt,wb,mpg,q,cpi,meanly,size,mpd,kseed1,kseed2,lamda,verdum,uswage,
 xr,jwage,gwage,ci,
firmids,euro,reli,qstar,nvec,rmat,modlist,yen,dm,yenlag,dmlag,dfi ;
  
clear markup,shares,delta,s0,xrand,qty,nyr,firmid,xyr,prederr,alpha0,
      pyr,alpha,sig,randij,bx,del_last,r1,r2,alpha,hard,myr,years,
      x,w,z,xnorm,ynorm,dyr,xrandall,krand,mc,bw,depvar,alphai ;

      
@ *************************  CONSTRUCT DATA ************* @      
      

@ Start by loading in the ascii file @
"loading data...." ;
load x[2217,25] = panel6.asc ;  @ panel6.asc contains the dfi binary variable 
                                  and the captive import binary variable  @

@ convert 1990 displacement in liters to cubic inches @
x[2087:2217,13] = x[2087:2217,13] .* 61.02 ;  @ Change this line if we add @
@ earlier years.             @

@************ create mpd for all years. *****************************@

load odat[20,13] = otherdat.asc ;   @ odat contains, in order: year,size @
@meanly,cpi,gasprice,rmat1,rmat2 nvec @
rmattmp = odat[.,6:7] ;            @ create vectors of year dummies  @
nvectmp = odat[.,8] ;
nobs= rows(x) ;
const = zeros(nobs,rows(odat)) ;
i = 1 ;
do until i > rows(odat) ;
  const[rmattmp[i,1]:rmattmp[i,2],i] = ones(nvectmp[i],1) ;
  i=i+1 ;
endo ;


mpd = zeros(nobs,1) ;            @ create mpd for all years   @
j = 1 ;
do until j>rows(odat) ;
  mpd = mpd + const[.,j].*(x[.,18]/10)*(odat[j,4]/100)*(1/odat[j,5]) ;
  j = j+1 ;
endo ;

x = x~mpd ;                 @ add mpd to the entire data set  @

/*************  Choose years to include in the program ************/

let keepyrs =  {71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 };
keepyrs = keepyrs' ;
nyrs = rows(keepyrs) ;
f = ones(2217,nyrs) ;

n=1 ;
do until n > nyrs ;
  f[.,n] = (x[.,3] .eq keepyrs[n]) ;
  n=n+1 ;
endo ;

fprime = f' ;
d = sumc(fprime) ;

"creating needed variables ..." ;
y = selif(x,d) ;
let xnames =
name id yr cy dr at ps air drv p wt dom disp hp lng wdt wb mpg q
firmids euro reli qstar dfi ci mpd ;
makevars(y,0,xnames) ;
@***************** Now create rmat and nvec based on selected years **** @

@ Create nvec  @

nvec = counts(yr,keepyrs) ;

@ Create rmat based on selected years @

sumvec = ones(nyrs,1) ;
sumvec[1] = nvec[1] ;
i=2 ;
do until i > nyrs;
  sumvec[i] = nvec[i] + sumvec[i-1] ;
  i=i+1 ;
endo ;
rmat = ones(nyrs,2) ;
i = 1 ;
do until i > nyrs ;
  rmat[i,2] = sumvec[i] ;
  i=i+1 ;
endo ;
i=1 ;
do until i > nyrs ;
  rmat[i,1] = rmat[i,2] - nvec[i] + 1 ;
  i=i+1 ;
endo ;

@ now read in meanly, size, and the cpi deflator.                     @
@ Recall, the 1990 values of meanly and size are total guesses.  Fix. @

load x[20,15] = otherdat3.asc ;
load lagerate[20,2] = lagged_erate.asc ;  @ lagged yen and dm @
x = x~lagerate ;
f = ones(20,nyrs) ;
n=1 ;
do until n > nyrs ;
  f[.,n] = (x[.,1] .eq keepyrs[n]) ;
  n=n+1 ;
endo ;
fprime = f' ;
d = sumc(fprime) ;
y = selif(x,d) ;
let xnames =  yr size meanly cpi gasprice rm1 rm2 n1
              uswage gwage jwage dm yen gnp primer yenlag dmlag ;
let vnames = size meanly cpi uswage gwage jwage dm yen gnp primer yenlag dmlag ;
makevars(y,vnames,xnames) ;

@************ Create sharevec ******************************** @

sharevec = ones(rows(q),1) ;
years = rows(rmat) ;
j=1 ;
do until j> years ;
  r1=rmat[j,1] ; r2=rmat[j,2] ;
  sharevec[r1:r2] = (q[r1:r2] ./ size[j]) / 1000 ;
  j=j+1 ;
endo ;

@*********** Now scale the relevant variables. **************** @

@ deflate price variable using 1982-84 = 100 cpi  @

years = rows(rmat) ;
j=1 ;
do until j>years ;
  r1=rmat[j,1] ; r2=rmat[j,2] ;
  p[r1:r2] = p[r1:r2] ./ (cpi[j]/100) ;
  j=j+1 ;
endo ;

@ rescale sales, price, and weight  @

q = q / 1000 ;
p = p / 1000 ;
wt = wt / 1000 ;

@ rescale hp, disp lenght width wheelbase @

hp = hp / 100 ;
disp = disp / 100 ;
lng = lng / 100 ;
wdt = wdt / 100 ;
wb = wb / 100 ;

@ rescale mpg @

mpg = mpg / 10 ;



@ **** Next create the string matrices required in the program ***** @

prodvec = name ;

mostobs = maxc(nvec) ;
mostobs1 = mostobs * ones(nyrs,1) ;
extraobs = mostobs1 - nvec  ;
prodname = zeros(mostobs,nyrs) ;
k=1 ;
do until k > nyrs ;
  prodname[1:nvec[k],k] = prodvec[rmat[k,1]:rmat[k,2]] ;
  k=k+1 ;
endo ;


@ ************ Now create the variable modlist which is needed **********@
@                to get the standard errors correctly.                   @
"creating stuff to compute correct s.e.'s ...." ;

if newse ;
  chgtol = 10 ;                @ percentage change which defines new model @
  
  data=hp~lng~wdt~wb ;         @ sort on these variables        @
  kx = cols( data) ;           @ number of variables to sort on  @
  modelvec= prodvec ;
  
  n = rows(data) ;
  x = data~yr~seqa(1,1,n) ;
  clear data ;
  
  
  @ make list of possible models (to sort on) @
  
  m = sortcc(modelvec,1) ;
  i = 1 ;
  do until i>n ;
    mi = m[i] ;
    
    if strlen(mi)>6;
      "model " $mi "has too long of a name" ;
      "position is " i ;
      END ;
    endif ;
    
    if i==1 ;
      modlist = mi ;
    else ;
      if m[i]$/=m[i-1] ;
	modlist = modlist|m[i] ;
      endif ;
    endif ;
    i = i+1 ;
  endo ;
  clear m ;
  
  newmodv = zeros(n,1) ;   @ new model vector @
  newlist = miss(0,0) ;    @ list of new models @
  
  nmodel = 0 ;
  
  
  
  i = 1 ;
  do until i>rows(modlist) ;    @ loop o list of model names @
    
    @ define data for this model name @
    
    m = modlist[i] ;
    y = selif(x,m.==modelvec) ;
    y = sortc(y,kx+1) ;            @ sort by yr @
    xm = y[.,1:kx] ;
    yr = y[.,kx+1] ;
    order = y[.,kx+2] ;
    
    @ the first occurence of this model name must be a new model @
    
    nmodel = nmodel+1 ;
    newname = m$+ftocv(yr[1],2,0) ;
    newmodv[order[1],.] = newname ;
    newlist = concatv(newlist,newname) ;
    newx = xm[1,.] ;
    @   "found model # " nmodel ;; " " ;; $newname ;@
    
    if rows(y)>1 ;   @ if name appears more than once, check for add'l models @
      j = 2 ;
      do until j>rows(y) ;
	if not (perchg(xm[j,.],newx)<chgtol)  ;  @ check for changes @
	  nmodel = nmodel+1 ;
	  newname = m$+ftocv(yr[j],2,0) ;
	  newlist = concatv(newlist,newname) ;
	  newx = xm[j,.] ;
	  @        "found model # " nmodel ;; " " ;; $newname ; @
	endif ;
	newmodv[order[j]] = newname ;
	j = j+1 ;
      endo ;
    endif ;
    
    i = i+1 ;
  endo ;
  
  @ output file=models.out reset ;@
  yr = x[.,kx+1] ;
  @ printna(yr~modelvec~newmodv) ;@
  @ output off ;                  @
  
  modlist=newlist ;
  save modlist ;
  save newmodv ;
  save modelvec ;
  
else ; 
  "loading modlist,modelvec and newmodv..." ;
  load modlist ;
  load newmodv ;
  load modelvec ;
endif ;


@ *************************** END OF NEW SE LOOP ************* @

@  Add VER dummy variables @ 
 hyundai = firmids.==21 ;

 japan = 1 - euro - dom - hyundai - (dfi*dfiflag) + (ci*ciflag) ;    

 yr81 = yr.==81 ;
 yr82 = yr.==82 ;
 yr83 = yr.==83 ;
 yr84 = yr.==84 ;
 yr85 = yr.==85 ;
 yr86 = yr.==86 ;
 yr87 = yr.==87 ;
 yr88 = yr.==88 ;
 yr89 = yr.==89 ;
 yr90 = yr.==90 ;


if onelam ;
  ver81 = japan.*yr81 ;
  ver82 = japan.*yr82 ;
  ver83 = japan.*yr83 ;
  ver84 = japan.*yr84 ;
  ver85 = japan.*yr85 ;
  ver86 = japan.*yr86 ;
  ver87 = japan.*yr87 ;
  ver88 = japan.*yr88 ;
  ver89 = japan.*yr89 ;
  ver90 = japan.*yr90 ;
else ; 
  bigj = sumc( (firmids.==(1~2))' ).*japan ;
  smallj = japan-bigj ;
  allj = bigj~smallj ;
  ver81 = allj.*yr81 ;
  ver82 = allj.*yr82 ;
  ver83 = allj.*yr83 ;
  ver84 = allj.*yr84 ;
  ver85 = allj.*yr85 ;
  ver86 = allj.*yr86 ;
  ver87 = allj.*yr87 ;
  ver88 = allj.*yr88 ;
  ver89 = allj.*yr89 ;
  ver90 = allj.*yr90 ;
endif ;

verdum = ver81~ver82~ver83~ver84~ver85~ver86~ver87~ver88~ver89~ver90 ;

jtrend = japan.*yr ;
etrend = euro.*yr ; 
asia = japan+hyundai ;
us = dom + (dfi*dfiflag)-(ci*ciflag) ;
yrdum = (yr.==keepyrs') ;
exrate = (us.*yrdum) + (asia.*yrdum)./(yen') + (euro.*yrdum)./(dm') ;
exrate = sumc( exrate' ); 
eratelag =(us.*yrdum) + (asia.*yrdum)./(yenlag') + (euro.*yrdum)./(dmlag') ;
eratelag = sumc( eratelag' ) ;
wage = (us.*yrdum).*(uswage') + (asia.*yrdum).*(jwage') + (euro.*yrdum).*(gwage') ; 
wage = sumc(wage') ;
gnp = yrdum*gnp ;      @ make macro demand side variables conformable @
primer=yrdum*primer ;

years=rows(nvec) ;

@ define conduct variables @

if conduct==0 ;
  qsetters = zeros(n,1) ;
  psetters = ones(n,1) ;
elseif conduct == 1 ;
  qsetters = ones(n,1) ;
  psetters = zeros(n,1) ;
elseif conduct == 2 ;
  qsetters = sumc(verdum') ;
  psetters = 1-qsetters ;
endif ;

  
  
  



@ load sigly ;   @
sigly = 1.72 ;  @ *************  note change ***************@
trend= yr-keepyrs[1] ;


del_last = ln(sharevec) ;

"log sharevec computed" ;
n = rmat[years,2] ;
nmax = maxc(nvec[1:years]) ;
space=wdt.*lng ;
hpwt = hp./wt ;



@************** NOW define the data and the instruments ****************** @


const = ones(n,1) ;

x = const~(hpwt)~space~air~mpd ~gnp~primer ;
xrandall = x[.,1:5] ;  

@ exog part of w:  @

w = const~ln(hpwt)~ln(space)~air~trend~japan~jtrend~euro~etrend~
    ln(eratelag)~ln(wage) ;

"logs in w computed" ;      
@  lq = ln(qstar)~(ln(qstar)^2) ; @

wexog =  w ; 

if not onelam ;
  verinst = verdum[.,1 3 5 7 9 11 13 15 17 19] + verdum[.,2 4 6 8 10 12 14 16 18 20] ;
else ;
  verinst = verdum ;
endif ;

excluded = japan~jtrend~euro~etrend~ln(eratelag)~verinst~ln(wage) ;

/*clear hpwt,space,air,trend,etrend,jtrend,euro,japan,eratelag ;*/


@ define column that ln(q) appears in (zero else) @

coeffq = 0 ;

kx = cols(x) ; kw = cols(w) ; krand = cols(xrandall) ;

xw = (x~zeros(n,kw))|(zeros(n,kx)~w) ;  @ "stack" x and w @

let xname = constant hpwt space air mpd  gnp primer ;


@ ******* other definitions ******** @
@ (you don't usually have to change these) @


if onelam ;
  let signame = constant hpwt space air mpd
               ver81 ver82 ver83 ver84 ver85 ver86 ver87 ver88 ver89 ver90 ;
else ;
  let signame = constant hpwt space air mpd
               ver81 ver81 ver82 ver82 ver83 ver83 ver84 ver84 ver85 ver85
               ver86 ver86 ver87 ver87 ver88 ver88 ver89 ver89 ver90 ver90 ;

  
endif ;

let wname = constant lnhpwt lnspace air trend japan jtrend euro etend 
            lag_lner ln_wage  ;


"data section completed...." ;

@ ********** define parms *************** @

let parm0[6,1] =   39.623  
	            2.271  
	            0.404  
	            1.945  
	            1.717  
	            0.655  ; 

    												    
klamda = cols(verdum) ;										    
										
/*
let verstart[10,1] =   
                       
    0.006  
    0.043  
    0.241  
    0.447  
    0.684  
    0.686  
    1.246  
    1.405  
    1.202  
    0.979  
*/
			  
verstart = .50*ones(10,1) ; 

parm0 = parm0 | verstart ;									    

output file=^outfile on ;
"parm0|verstart is " parm0 ;
output off ;


kparm = rows(parm0) ;										    
incr = 3|(0.50*ones(krand,1)) ; @ increments for initial simplex  *******change with vars change@    
incr = incr | (0.25*ones(klamda,1)) ;								    
												    
tol = 0.5 ;             @ tol for optimization (size of simplex) @				    
deltol = .0001 ;         @ tolerance for calculating delta @					    
  								    
 kseed1 = 17543 ;   @    original seeds  @								    
 kseed2 = 76312 ;  


output file=^outfile on ;
"kseed1 is " kseed1 ;
"kseed2 is " kseed2 ;
output off ;


@ use this starting value for initial weighting matrix @

parm1 = parm0 ;


if not ( (rows(wname)==cols(w)) and (rows(xname)==cols(x))
        and (rows(signame)==(kparm-1)) ) ;  @ note change** @ 
   cls ; locate 10,5 ; "bad names: try again" ; end ;
endif ;

@ ********************** define the simulation draws ****************** @

if loaddraw ;
  " " ; "LOADING DRAWS" ;
  load xnorm ;
  load ynorm ;
  load shr_wt ;
  nsim = cols(xnorm) ;
elseif newdraw ;
  " " ; "TAKING NEW DRAWS" ;
  rndseed kseed1 ;
  xnorm = rndn(krand,nsim) ;
  ynorm = rndn(1,nsim) ;
  shr_wt = 1 ;             @ shr_wt = one for random sampling @
  {del_last,m} = del_mark(parm0) ;
  {xnorm,ynorm,shr_wt} = drawopt(nfind,del_last) ;
  nsim = cols(xnorm) ;
else ;
  rndseed kseed1 ;
  xnorm = rndn(krand,nsim) ;
  ynorm = rndn(1,nsim) ;
  shr_wt = 1 ;             @ shr_wt = one for random sampling @
endif ;

@ *************************************************** @
@ ***************** instruments ********************* @
@ *************************************************** @


if loadz ;
  load z1=z1struct ;
  load z2=z2struct ;
else ;
  
  
  @ first create original instruments to get initial estimates of 
  bx, bw @
  
  "initial instruments" ;  
  {xexch,xtot} = exch(x) ;  @ xexch is sum(ownx), xtot is sum(allx) @
  {wexch,wtot} = exch( wexog ) ; 
  
  
  z1 = x~xexch~xtot~excluded~verdum ;
  z2 = wexog~wexch~wtot~verdum~gnp~primer ;    
  
  clear xexch,xtot,wexch,wtot,wexog ;
  @ only use these initial z's to get predicted delta, markup @
  
  
  load delta1 ;
  if (rows(delta1)==n) and twoloop ; 
    del_last = delta1 ; 
  endif ;
  
  {delta,mk} = del_mark(parm0) ;
  save delta1=del_last ;
  
  @ get predicted delta, markup               @
  @ (if 2SLS fails, use proc uncollin, below) @
  @ it is NOT obvious that we want to use 2SLS here @
  @ note also that instruments depend on initial parm0 @
 
  
    "original cols of z1: " cols(z1) ;   @  use these next two sets of lines only @
  z1 = uncollin(z1,0.99) ;               @  when necessary.                       @
  "remaining cols of z1: " cols(z1) ;
  
  
  "original cols of z2: " cols(z2) ;
  z2 = uncollin(z2,0.99) ;
  "remaining cols of z2: " cols(z2) ;
  
  
  
  
  
  
  
  "predicted deltas" ;
  {bx,s} = twosls(delta,x,z1,0) ;
  delhat = x*bx ;
  
  "predicted mc" ;
  {bw,s} = twosls(delta,w,z2,0) ;
  
  lnmchat = w*bw ;
  mchat = exp(lnmchat) ;
  
  bxw0 = bx|bw ;    
  
  @ solve for price at delhat, mchat @
  
  deltol0 = deltol ;
  deltol = deltol/10 ;   @ lower tolerance for calculating derivatives @
  
  phat = zeros(n,1) ;			@ pred price and shares  @
  shat = zeros(n,1) ;
  
  
  "Loop for predicted equilibrium prices, year by year " ;
  
  yr = 1 ;				@ loop over years  @
  do until yr>20 ;
    
    defdata(yr,parm0) ;
    
    mcyr = mchat[r1:r2] ;
    dyr = delhat[r1:r2] ;
    p0 = mchat[r1:r2] ;
    mk = mkprice(p0) ;
    pnew = mcyr+mk ;
    
    test = 1 ;
    do until test<0.005 ;			@ iterate on f.o.c.  @
      test = maxc(abs(pnew-p0)) ;
      "yr~test " yr~test ;
      p0 = pnew ;
      mk = mkprice(p0) ;
      pnew = mcyr+mk ;
      test = maxc(abs(pnew-p0)) ;
    endo ;
    
    phat[r1:r2] = pnew ;
    shat[r1:r2] = shares ;
    yr = yr+1 ;
    
  endo ;
  
  
  @ do some logit regressions, is phat a good instrument? @
  
  load y=y3 ;  @ logit dep var @
  
  "LOGIT OLS" ;
  
  {b,s} = ols(y,x~p,1) ;
  
  "LOGIT 2SLS with PHAT only" ;
  
  {b,s} = twosls(y,x~p,x~phat,1) ;
  
  "LOGIT 2SLS with PHAT, excluded" ;
  
  {b,s} = twosls(y,x~p,x~excluded,1) ;
  
  @ get the derivatives of delhat and mkhat wrt parms            @
  @ use proc mdparm, which give markup and delta as func of parm @
  
  ddel = zeros(n,krand+1) ;		@ deriv wrt delta   @
  dmk = ddel ;				@ deriv wrt markup  @
  
  yr = 1 ;
  do until yr>20 ;
    "finding deriv in yr: " yr ;
    grad1 = gradp(&mdparm,parm0[1:krand+1]) ;
    ddel[r1:r2,.] = grad1[1:nyr,.] ;
    dmk[r1:r2,.] = grad1[nyr+1:2*nyr,.] ;
    yr = yr+1 ;
  endo ;
  
  
  mcv = mchat-(verdum*lamda) ;		@ 1 / (deriv of mc wrt lambda)   @
  dver = verdum.*(1./mcv) ;		@ these are the "theoretical derivs wrt ver  @
  
  z1 = x~excluded~ddel~dmk~(dver)~verdum ;
  z2 = w~gnp~primer~dver~dmk~ddel~verdum ;
  
  
  @ take out perfectly and nearly collinear columns @
  @ use proc uncollin                               @
  
  "original cols of z1: " cols(z1) ;
  z1 = uncollin(z1,0.99) ;
  "remaining cols of z1: " cols(z1) ;
  
  
  "original cols of z2: " cols(z2) ;
  z2 = uncollin(z2,0.99) ;
  "remaining cols of z2: " cols(z2) ;
  
  
  "logit 2sls with z1 " ;
  
  {b,s} = twosls(y,x~p,z1,1) ;
    
  save z1struct = z1 ;
  save z2struct = z2 ;
  
endif ;

z0 = (z1~zeros(n,cols(z2))) | (zeros(n,cols(z1))~z2) ;
clear z1,z2 ;


kz = cols(z0) ;
xw = (x~zeros(n,kw))|(zeros(n,kx)~w) ;  @ "stack" x and w @
zxw = z0'xw ;                            @ this is used in obj (IV estimates) @

z = z0 ;
save z0 ; clear z0 ;			@ save z0 as "original" instr  @



@ **************************************************** @
@ ************* start the program ******************** @
@ **************************************************** @


restart:   ;
save xnorm,ynorm,shr_wt ;  

if start_wt and newstart ;
  "finding starting matrix to weight instruments . . . " ;
  if twoloop == 0 ;
    incr = .50 * incr ; @ NOTE CHANGE IN INCREMENT ******************* @
  Endif ;
  
  Objstart = Obj(Parm0) ;

  clear z ; load z0 ;
  gind = z0.*prederr ;              @ prederr is calculated in obj @
  
  g = meanc(gind) ;
  vg = gind'gind/rows(gind)-g.*g' ;       clear gind ;
  
  
  @ vg should REALLY invert now, because of checks above @
  
  aweight = invpd(vg) ;  @  clear vg ; @
  c = chol(aweight) ;    
  if twoloop == 1 ;
    save aweight1=aweight ;
  else ;
    save aweight2=aweight ;
  endif ;
  
  z = z0*c' ;             clear c ;
  zxw = z'xw ;
  clear z0 ;
elseif start_wt ;
  
  load aweight=aweight2 ;
  c = chol(aweight) ;
  clear z ; load z0 ;
  z = z0*c' ;  clear aweight,c,z0 ;
  zxw = z'xw ;
endif ;



" " ; "BEGIN estimation loop " ;

if newstart ;
  "start the simplex . . . " ;
  
  {simplex,f} = makesimp(parm0,incr,&obj) ;
else ;
  load simplex; load f=fvec ;
endif ;



@ ************* get the answer **************** @



if not endflag ;
  pfinal = amoeba(simplex,f,tol,&obj);
  save pfinal ;
else ;
  load pfinal ;
  twoloop = 0 ;
endif ;



@ ********* find the variance of the parameters ******************** @

"looking for variances . . . " ;


deltol0 = deltol ;
deltol = deltol/10 ;   @ lower tolerance for calculating derivatives @
parm0 = pfinal ; save pfinal ;
obj0 = obj(parm0) ;
delta0 = delta ; mark0 = markup ; mc0 = mc ;
y0 = depvar ;
bxfinal = bx ; bwfinal = bw ;
bxw0 = bx|bw ;
allparms = bxw0|parm0 ;

e0 = y0-xw*bxw0 ;

"finding derivatives" ;
de = zeros(2*n,kparm) ;
df = zeros(kparm,1) ;
imat = eye(kparm) ;
i = 1 ;
do until i>kparm ;
  "finding derivative for parameter " i ;
  dp = .01*abs(parm0[i]) ;
  dp = maxc(.01|dp) ;
  parm = parm0 + dp*imat[.,i] ;
  {e,f} = prederr_(parm) ;
  de[.,i] = (e-e0)/dp ;
  df[i] = (f-obj0)/dp ;
  i = i+1 ;
endo ;

output on ;
" derivative of objective function wrt parm: " ; df' ;

deltol = deltol0 ;

de = (-xw)~de ;           @ deriv of errors wrt parameters @


@ add up moment conditions, etc., over model definitions @

nmodel = rows(modlist) ;

clear dg ;
gind = zeros(nmodel,cols(z)) ;

i = 1 ;
do until i>nmodel ;
  ok = modlist[i].$==newmodv ; ok = ok|ok ;
  ok1 = ok.*seqa(1,1,2*n) ;
  mods = selif(ok1,ok) ;
  if not scalmiss(mods) ;
    ei = e0[mods,.] ;
    dei = de[mods,.] ;
    zi = z[mods,.] ;
    gind[i,.] = ei'zi ;
    dg = dg + zi'dei ;
  endif ;
  i = i+1 ;
endo ;

g = meanc(gind) ;
dg = dg/nmodel ;
dgi = inv(dg'*dg) ;
vg = cov(gind) ;   @ variance of moment conditions @
clear gind ;

varp = dgi*dg'*vg*dg*dgi/nmodel ;
save varp ;
se = sqrt(diag(varp)) ;

output file=^outfile on ;

parmname = xname|wname|"alpha"|signame ;
"  PARM   SE " ; format 9,4 ;
if rows(parmname)==rows(allparms) ;
  printan(parmname~allparms~se) ;
else ;
  allparms~se ;
endif ;



objfinal2 = nmodel*g'*inv(vg)*g ;
"The objective function2 value is: " objfinal2 ;

"which is chi-sq with d.o.f. of: " cols(z)-rows(allparms) ;
output off ;



if twoloop ;
  twoloop = 0 ;
  newstart=1 ;
  goto restart ;
endif ;



@ ********** calculate best substitutes etc. @

output file=^outfile on ;

@ print out these models (only 6 or 7 will fit on a line) @

yr = rows(meanly) ;  @ compute for the last year only @
defdata(yr,parm0) ;
prod = prodname[1:nyr,yr] ;
/*
d = seqa(1,1,nyr)~pyr ;      @ sort by price or some other variable @
d = sortc(d,2) ;
sq = seqa(1,13,12) ;         @ this picks out every 12th (or whatever) model @
*/
let showmod = 22 25 11 43 48 68 2 10 69 54 65 91 89    ;

@ define more data @

delta = delta0[r1:r2] ;
pyr = p[r1:r2] ;

pyr1 = pyr[showmod] ;          @sort by price @
tt= pyr1~showmod ;
ss= sortc(tt,1) ;
showmod=ss[.,2] ;

myr = markup[r1:r2] ;
g = gsharep(delta) ;          @ (minus) derivative of shares wrt price @

dlns_dp =  g./shares ;  @ row i col j is dlnsi/dpj @
ds0_dp = sumc(g') ;
outside = ds0_dp./diag(g) ; @ share of dsj_dpj which goes to outside good @


el = diag(dlns_dp).*pyr ;
" " ; "Yr: " yr ;
"Number of inelastic demands: " sumc(abs(el).<1) ; " " ; " " ;

dlns_dp = dlns_dp[showmod,showmod] ;
modelvec = modelvec[r1:r2] ;
modelvec = modelvec[showmod] ;


@ print out cross-price terms (modify formats for aesthetics) @

"         " ;; format 8,8 ;
$modelvec[1:7]' ; "         " ;; $modelvec[8:rows(showmod)]' ;
k = 1 ;
do until k>rows(showmod) ;
  printan(modelvec[k]~(-100*dlns_dp[k,1:7]));
  printan("         "~(-100*dlns_dp[k,8:rows(showmod)])) ;
  " " ;
  k = k+1 ;
endo ;

@ calculate derivative wrt x @

"derivatives wrt x" ;


k = 1 ;
defdata(yr,parm0) ;
ds = zeros(nyr,cols(x)) ;
dyr0 = delta0[r1:r2] ;
xrand =  xrandall[r1:r2,.] ;
do until k>cols(x) ;
  xk = xyr[.,k] ;
  dx = 0.10 ;
  d = dyr0 + dx*bxfinal[k] ;     @ increase delta @
  j = 1 ;  match = 0 ;
  do until match or (j>krand) ;    @ find out which column of xrand matches @
    match = (xrand[.,j]==xk).*j ;  @ this column of x                       @
    j = j+1 ;
  endo ;
  xrand1 = xrand ;
  if match>0 ;
    xrand1[.,match] = xrand1[.,match]+dx ;
  endif ;
  xr = xrand1*(sig.*xnorm) ;    @ random x term @
  randij = xr - alphai.*pyr ;            @ total random term @
  sx = sharep(d) ;
  dsk = (sx-shares)./dx;
  ds[.,k] = (xk.*dsk)./shares ;      @ elas @
  k = k+1 ;
endo ;

"
X                              P
(elas of share wrt x)                (elas)
-----------------------------------------    -----
" ;


format 6,2 ;
k = 1 ; do until k>rows(showmod) ;
  printan(modelvec[k]~xyr[showmod[k],.]~pyr[showmod[k]]) ;
  printan("        "~ds[showmod[k],.]~el[showmod[k]]) ;
  " " ;
  k = k+1 ;
endo ;


@ substitution with outside good @

"Substitution with the outside good "

"
Model    % to Outside " ;
printan(modelvec~outside[showmod]) ;




if coeffq ;
  coeffq = bwfinal[rows(bw)] ;
  mc = p-mark0 ;
  avc = mc/(1+coeffq) ;
  avcyr = avc[r1:r2] ;
  qty = q[r1:r2] ;
  ma = pyr-avcyr ;        @ markup over avc @
  vprof = ma.*qty ;
  markout = myr[showmod]~ma[showmod]~vprof[showmod] ;
else ;
  markout = myr[showmod] ;
endif ;

"
Model     Markup(MC)   % Markup
($1,000)      
" ;

printan(modelvec~markout~(markout./pyr[showmod])) ;
output off ;

dos cp varp.fmt varp.20.1.1.1.0_macro.fmt ;
dos cp pfinal.fmt pfinal.20.1.1.1.0_macro.fmt ;


 end ;


