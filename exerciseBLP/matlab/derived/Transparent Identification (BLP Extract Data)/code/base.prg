/* new ; */

@ these are the libraries @

/*
library gauss,/home/jamesl/gauss/ownlib/berry,
        /home/jamesl/gauss/ownlib/struc-inst-steve2 ;
*/

outfile = "../output/make.log"  ;

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
nfind = 10 ;             @ # of simulation draws per year for drawopt @
conduct =0 ;         @ Set to 0 if Bertrand, 1 for Cournot, 2 for mixed @  

onelam = 1 ;          @ Set to 1 to constrain all VER lambdas to be equal @

newse = 1 ;  @ Set to 1 to create new stuff for standard errors, else 0 @
             @  For you, Steve. @
nsim = 1500 ;

@ print out flags @

output file=^outfile ; " " ;

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
@ BLP 1999 puts additional restrictions on Japan; this matches BLP 1995 table I @
japan = 1 - euro - dom;



@ OUTPUT FILES FOR MATLAB USE @
load y=y3 ;  @ logit dep var @
data = newmodv~id~firmids~p~dom~japan~euro~const~hpwt~air~mpd~space~mpg~trend~yr~sharevec~q~y;
mask = {0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1};
let fmt[18,3] = "*.*lf," 8 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12
                "*.*lf," 16 12;

outwidth 256;
output file="../output/blp_1999_data.csv" reset;
screen off;
print "model_id,car_id,firm_id,price,domestic,japan,european,const,hpwt,air,mpd,space,mpg,trend,year,share,quantity,logit_depvar,";
exit_code = printfm(data, mask, fmt);
screen on;
output off;


@ Declare some variables to allow code to compile @
clear shat, phat, delhat, parm0, bxw0, kparm, shr_wt, deltol, zxw, kw, xw;
