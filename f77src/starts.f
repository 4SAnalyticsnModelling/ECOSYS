
      SUBROUTINE starts(NHW,NHE,NVN,NVS)
C
C     THIS SUBROUTINE INITIALIZES ALL SOIL VARIABLES
C
      include "parameters.h"
      include "blkc.h"
      include "blk2a.h"
      include "blk2b.h"
      include "blk2c.h"
      include "blk5.h"
      include "blk8a.h"
      include "blk8b.h"
      include "blk11a.h"
      include "blk11b.h"
      include "blk13a.h"
      include "blk13b.h"
      include "blk13c.h"
      include "blk16.h"
      include "blk18a.h"
      include "blk18b.h"
      DIMENSION YSIN(4),YCOS(4),YAZI(4),ZAZI(4),OSCI(0:4),OSNI(0:4)
     2,ORCI(2,0:4),OSPI(0:4),OSCM(0:4),CORGCX(0:4)
     3,CORGNX(0:4),CORGPX(0:4),CNOSCT(0:4),CPOSCT(0:4)
     4,GSINA(JY,JX),GCOSA(JY,JX),ALTX(JV,JH)
     5,OSCX(0:4),OSNX(0:4),OSPX(0:4),OMCK(0:4),ORCK(0:4),OQCK(0:4)
     6,OHCK(0:4),TOSCK(0:4),TOSNK(0:4),TOSPK(0:4),TORGL(JZ) 
      PARAMETER (OQKM=12.0,DCKR=0.25,DCKM=2.5E+04,PSIPS=-0.5E-03)
      DATA OMCI/0.005,0.050,0.005,0.050,0.050,0.005,0.050,0.050,0.005
     2,0.005,0.050,0.005,0.005,0.050,0.005/
      DATA ORCI/0.01,0.05,0.01,0.05,0.01,0.05
     2,0.001,0.005,0.001,0.005/
      DATA OMCK/0.01,0.01,0.01,0.01,0.01/
      DATA ORCK/0.25,0.25,0.25,0.25,0.25/
      DATA OQCK/0.005,0.005,0.005,0.005,0.005/
      DATA OHCK/0.05,0.05,0.05,0.05,0.05/
      DATA OMCF/0.20,0.20,0.30,0.20,0.050,0.025,0.025/
      DATA OMCA/0.06,0.02,0.01,0.0,0.01,0.0,0.0/
      DATA CNRH/3.33E-02,3.33E-02,3.33E-02,5.00E-02,12.50E-02/
      DATA CPRH/3.33E-03,3.33E-03,3.33E-03,5.00E-03,12.50E-03/
      DATA BKRS/0.0500,0.0167,0.0167/
      DATA FORGC,FVLWB,FCH4F/0.1E+06,1.0,0.01/
      NDIM=1
      IF(NHE.GT.NHW)NDIM=NDIM+1
      IF(NVS.GT.NVN)NDIM=NDIM+1
      XDIM=1.0/NDIM
      ZERO=1.0E-16
      TAREA=0.0
      THETX=2.5E-03
      THETPI=0.00
      DENSI=0.92-THETPI
C
C     INITIALIZE MASS BALANCE CHECKS
C
      CRAIN=0.0
      HEATIN=0.0
      CO2GIN=0.0
      OXYGIN=0.0
      H2GIN=0.0
      TZIN=0.0
      ZN2GIN=0.0
      TPIN=0.0
      TORGF=0.0
      TORGN=0.0
      TORGP=0.0
      VOLWOU=0.0
      CEVAP=0.0
      CRUN=0.0
      HEATOU=0.0
      OXYGOU=0.0
      H2GOU=0.0
      TSEDOU=0.0
      TCOU=0.0
      TZOU=0.0
      TPOU=0.0
      XCSN=0.0
      XZSN=0.0
      XPSN=0.0
      TIONIN=0.0
      TIONOU=0.0
      VAP=2465.0
      VAPW=2834.0
      OXKM=0.064
      TYSIN=0.0
      ZSIN(1)=0.195
      ZSIN(2)=0.556
      ZSIN(3)=0.831
      ZSIN(4)=0.981
      ZCOS(1)=0.981
      ZCOS(2)=0.831
      ZCOS(3)=0.556
      ZCOS(4)=0.195
      DO 205 L=1,4
      ZAZI(L)=(L-0.5)*3.1416/4.0
205   CONTINUE
      DO 230 N=1,4
      YAZI(N)=3.1416*(2*N-1)/4.0
      YAGL=3.1416/4.0
      YSIN(N)=SIN(YAGL)
      YCOS(N)=COS(YAGL)
      TYSIN=TYSIN+YSIN(N)
      DO 225 L=1,4
      DAZI=COS(ZAZI(L)-YAZI(N))
      DO 225 M=1,4
      OMEGY=ZCOS(M)*YSIN(N)+ZSIN(M)*YCOS(N)*DAZI
      OMEGA(N,M,L)=ABS(OMEGY)
      OMEGX(N,M,L)=OMEGA(N,M,L)/YSIN(N)
      IF(ZCOS(M).GT.YSIN(N))THEN
      OMEGZ=ACOS(OMEGY)
      ELSE
      OMEGZ=-ACOS(OMEGY)
      ENDIF
      IF(OMEGZ.GT.-1.5708)THEN
      ZAGL=YAGL+2.0*OMEGZ
      ELSE
      ZAGL=YAGL-2.0*(3.1416+OMEGZ)
      ENDIF
      IF(ZAGL.GT.0.0.AND.ZAGL.LT.3.1416)THEN
      IALBY(N,M,L)=1
      ELSE
      IALBY(N,M,L)=2
      ENDIF
225   CONTINUE
230   CONTINUE
C
C     INITIALIZE C-N AND C-P RATIOS OF RESIDUE AND SOIL
C
      CNOFC(1,0)=0.005
      CNOFC(2,0)=0.005
      CNOFC(3,0)=0.005
      CNOFC(4,0)=0.020
      CPOFC(1,0)=0.0005
      CPOFC(2,0)=0.0005
      CPOFC(3,0)=0.0005
      CPOFC(4,0)=0.0020
      CNOFC(1,1)=0.020
      CNOFC(2,1)=0.020
      CNOFC(3,1)=0.020
      CNOFC(4,1)=0.020
      CPOFC(1,1)=0.0020
      CPOFC(2,1)=0.0020
      CPOFC(3,1)=0.0020
      CPOFC(4,1)=0.0020
      CNOFC(1,2)=0.005
      CNOFC(2,2)=0.005
      CNOFC(3,2)=0.005
      CNOFC(4,2)=0.020
      CPOFC(1,2)=0.0005
      CPOFC(2,2)=0.0005
      CPOFC(3,2)=0.0005
      CPOFC(4,2)=0.0020
      FL(1)=0.55
      FL(2)=0.45
      DO 95 K=0,5
      DO 95 N=1,7
      IF(K.LE.4.AND.N.EQ.3)THEN
      CNOMC(1,N,K)=0.15
      CNOMC(2,N,K)=0.09
      CPOMC(1,N,K)=0.015
      CPOMC(2,N,K)=0.009
      ELSE
      CNOMC(1,N,K)=0.225
      CNOMC(2,N,K)=0.135
      CPOMC(1,N,K)=0.0225
      CPOMC(2,N,K)=0.0135
      ENDIF
      CNOMC(3,N,K)=FL(1)*CNOMC(1,N,K)+FL(2)*CNOMC(2,N,K)
      CPOMC(3,N,K)=FL(1)*CPOMC(1,N,K)+FL(2)*CPOMC(2,N,K)
95    CONTINUE
C
C     CALCULATE ELEVATION OF EACH GRID CELL
C
      ALTY=0.0
      DO 9985 NX=NHW,NHE
      DO 9980 NY=NVN,NVS
      ZEROS(NY,NX)=ZERO*DH(NY,NX)*DV(NY,NX)
      GAZI(NY,NX)=ASP(NY,NX)/57.29577951
      GSINA(NY,NX)=ABS(SIN(GAZI(NY,NX)))
      GCOSA(NY,NX)=ABS(COS(GAZI(NY,NX)))
      GSIN(NY,NX)=SIN(SL(1,NY,NX)/57.29577951)*GCOSA(NY,NX)
     2+SIN(SL(2,NY,NX)/57.29577951)*GSINA(NY,NX)
      GCOS(NY,NX)=SQRT(1.0-GSIN(NY,NX)**2)
      DO 240 N=1,4
      DGAZI=COS(GAZI(NY,NX)-YAZI(N))
      OMEGAG(N,NY,NX)=AMAX1(0.0,AMIN1(1.0,GCOS(NY,NX)*YSIN(N)
     2+GSIN(NY,NX)*YCOS(N)*DGAZI))
240   CONTINUE
      IF(ASP(NY,NX).GT.90.0.AND.ASP(NY,NX).LT.270.0)THEN
      SLOPE(1,NY,NX)=SIN(SL(1,NY,NX)/57.29577951)
      ELSE
      SLOPE(1,NY,NX)=-SIN(SL(1,NY,NX)/57.29577951)
      ENDIF
      IF(ASP(NY,NX).GT.0.0.AND.ASP(NY,NX).LT.180.0)THEN
      SLOPE(2,NY,NX)=SIN(SL(2,NY,NX)/57.29577951)
      ELSE
      SLOPE(2,NY,NX)=-SIN(SL(2,NY,NX)/57.29577951)
      ENDIF
      SLOPE(3,NY,NX)=-1.0
      IF(NX.EQ.NHW)THEN
      IF(NY.EQ.NVN)THEN
      ALT(NY,NX)=0.5*DH(NY,NX)*SLOPE(1,NY,NX)
     2+0.5*DV(NY,NX)*SLOPE(2,NY,NX)
      ELSE
      ALT(NY,NX)=ALT(NY-1,NX)
     2+0.5*DH(NY,NX)*SLOPE(1,NY,NX)
     4+0.5*DV(NY,NX)*(SLOPE(2,NY,NX))
     5+0.5*DV(NY-1,NX)*SLOPE(2,NY-1,NX)
      ENDIF
      ELSE
      IF(NY.EQ.NVN)THEN
      ALT(NY,NX)=ALT(NY,NX-1)
     2+0.5*DH(NY,NX)*SLOPE(1,NY,NX)
     3+0.5*DH(NY,NX-1)*SLOPE(1,NY,NX-1)
      ELSE
      ALT(NY,NX)=(ALT(NY,NX-1)
     2+0.5*DH(NY,NX)*SLOPE(1,NY,NX)
     3+0.5*DH(NY,NX-1)*SLOPE(1,NY,NX-1)
     4+ALT(NY-1,NX)
     4+0.5*DV(NY,NX)*SLOPE(2,NY,NX)
     5+0.5*DV(NY-1,N)*SLOPE(2,NY-1,NX))/2.0
      ENDIF
      ENDIF
      IF(NX.EQ.NHW.AND.NY.EQ.NVN)THEN
      ALTY=ALT(NY,NX)
      ELSE
      ALTY=MAX(ALTY,ALT(NY,NX))
      ENDIF
      WRITE(18,1111)'ALT',NX,NY,ALT(NY,NX)
     2,DH(NY,NX),DV(NY,NX),ASP(NY,NX),GSIN(NY,NX)
     3,SLOPE(1,NY,NX),SLOPE(2,NY,NX)
1111  FORMAT(A8,2I4,20E12.4)
9980  CONTINUE
9985  CONTINUE
C
C     INITIALIZE ACCUMULATORS AND MASS BALANCE CHECKS
C     OF EACH GRID CELL
C
      ALTZG=0.0
      CDPTHG=0.0
      DO 9995 NX=NHW,NHE
      DO 9990 NY=NVN,NVS
      DO 600 N=1,12
      TDTPX(NY,NX,N)=0.0
      TDTPN(NY,NX,N)=0.0
      TDRAD(NY,NX,N)=1.0
      TDWND(NY,NX,N)=1.0
      TDHUM(NY,NX,N)=1.0
      TDPRC(NY,NX,N)=1.0
      TDIRI(NY,NX,N)=1.0
      TDCO2(NY,NX,N)=1.0
      TDCN4(NY,NX,N)=1.0
      TDCNO(NY,NX,N)=1.0
600   CONTINUE
      IUTYP(NY,NX)=0
      IFNHB(NY,NX)=0
      IFNOB(NY,NX)=0
      IFPOB(NY,NX)=0
      IFLGS(NY,NX)=1
      IFLGT(NY,NX)=0
      ATCA(NY,NX)=ATCAI(NY,NX)
      ATCS(NY,NX)=ATCAI(NY,NX)
      ATKA(NY,NX)=ATCA(NY,NX)+273.15
      ATKS(NY,NX)=ATCS(NY,NX)+273.15
      URAIN(NY,NX)=0.0
      UCO2G(NY,NX)=0.0
      UCH4G(NY,NX)=0.0
      UOXYG(NY,NX)=0.0
      UN2GG(NY,NX)=0.0
      UN2OG(NY,NX)=0.0
      UNH3G(NY,NX)=0.0
      UN2GS(NY,NX)=0.0
      UCO2F(NY,NX)=0.0
      UCH4F(NY,NX)=0.0
      UOXYF(NY,NX)=0.0
      UN2OF(NY,NX)=0.0
      UNH3F(NY,NX)=0.0
      UPO4F(NY,NX)=0.0
      UORGF(NY,NX)=0.0
      UFERTN(NY,NX)=0.0
      UFERTP(NY,NX)=0.0
      UVOLO(NY,NX)=0.0
      UEVAP(NY,NX)=0.0
      URUN(NY,NX)=0.0
      USEDOU(NY,NX)=0.0
      UCOP(NY,NX)=0.0
      UDOCQ(NY,NX)=0.0
      UDOCD(NY,NX)=0.0
      UDONQ(NY,NX)=0.0
      UDOND(NY,NX)=0.0
      UDOPQ(NY,NX)=0.0
      UDOPD(NY,NX)=0.0
      UDICQ(NY,NX)=0.0
      UDICD(NY,NX)=0.0
      UDINQ(NY,NX)=0.0
      UDIND(NY,NX)=0.0
      UDIPQ(NY,NX)=0.0
      UDIPD(NY,NX)=0.0
      UIONOU(NY,NX)=0.0
      UXCSN(NY,NX)=0.0
      UXZSN(NY,NX)=0.0
      UXPSN(NY,NX)=0.0
      UDRAIN(NY,NX)=0.0
      ZDRAIN(NY,NX)=0.0
      PDRAIN(NY,NX)=0.0
      DPNH4(NY,NX)=0.0
      DPNO3(NY,NX)=0.0
      DPPO4(NY,NX)=0.0
      TCS(0,NY,NX)=ATCS(NY,NX)
      TKS(0,NY,NX)=TCS(0,NY,NX)+273.15
      OXYS(0,NY,NX)=0.0
      FRADG(NY,NX)=1.0
      THRMG(NY,NX)=0.0
      THRMC(NY,NX)=0.0
      TRN(NY,NX)=0.0
      TLE(NY,NX)=0.0
      TSH(NY,NX)=0.0
      TGH(NY,NX)=0.0
      TLEC(NY,NX)=0.0
      TSHC(NY,NX)=0.0
      TLEX(NY,NX)=0.0
      TSHX(NY,NX)=0.0
      TCNET(NY,NX)=0.0
      TVOLWC(NY,NX)=0.0
      ARLFC(NY,NX)=0.0
      ARSTC(NY,NX)=0.0
      TFLWC(NY,NX)=0.0
      PPT(NY,NX)=0.0
      DYLN(NY,NX)=12.0
      DENS0(NY,NX)=0.100
      DENS1(NY,NX)=1.0
      VOLSS(NY,NX)=DPTHS(NY,NX)*DENS0(NY,NX)*DH(NY,NX)*DV(NY,NX)
      VOLWS(NY,NX)=0.0
      VOLIS(NY,NX)=0.0
      VOLS(NY,NX)=VOLSS(NY,NX)/DENS0(NY,NX)+VOLWS(NY,NX)+VOLIS(NY,NX)
      DPTHA(NY,NX)=9999.0
      TCW(NY,NX)=0.0
      TKW(NY,NX)=TCW(NY,NX)+273.15
      ALBX(NY,NX)=ALBS(NY,NX)
      XHVSTC(NY,NX)=0.0
      XHVSTN(NY,NX)=0.0
      XHVSTP(NY,NX)=0.0
      ALT(NY,NX)=ALT(NY,NX)-ALTY
      IF(NX.EQ.NHW.AND.NY.EQ.NVN)THEN
      ALTZG=ALT(NY,NX)
      ELSE
      ALTZG=MIN(ALTZG,ALT(NY,NX))
      ENDIF
      CDPTHG=AMAX1(CDPTHG,CDPTH(NU(NY,NX),NY,NX))
C
C     INITIALIZE ATMOSPHERE VARIABLES
C
      CCO2EI(NY,NX)=CO2EI(NY,NX)*5.36E-04*273.15/ATKA(NY,NX)
      CCO2E(NY,NX)=CO2E(NY,NX)*5.36E-04*273.15/ATKA(NY,NX)
      CCH4E(NY,NX)=CH4E(NY,NX)*5.36E-04*273.15/ATKA(NY,NX)
      COXYE(NY,NX)=OXYE(NY,NX)*1.43E-03*273.15/ATKA(NY,NX) 
      CZ2GE(NY,NX)=Z2GE(NY,NX)*1.25E-03*273.15/ATKA(NY,NX)
      CZ2OE(NY,NX)=Z2OE(NY,NX)*1.25E-03*273.15/ATKA(NY,NX)
      CNH3E(NY,NX)=ZNH3E(NY,NX)*6.25E-04*273.15/ATKA(NY,NX)
      CH2GE(NY,NX)=H2GE(NY,NX)*8.92E-05*273.15/ATKA(NY,NX)
C
C     CALCULATE THERMAL ADAPTATION
C
      OFFSET(NY,NX)=0.33*(12.5-AMAX1(0.0,AMIN1(25.0,ATCS(NY,NX))))
      WRITE(*,2222)'OFFSET',OFFSET(NY,NX),ATCS(NY,NX)
2222  FORMAT(A8,2E12.4)
C
C     CALCULATE WHETHER BOUNDARY SLOPES ALLOW RUNOFF
C
      DO 9575 N=1,2
      DO 9575 NN=1,2
      IF(N.EQ.1)THEN
      IF(NN.EQ.1)THEN
      IF(NX.EQ.NHE)THEN
      IF(ASP(NY,NX).GT.90.0.AND.ASP(NY,NX).LT.270.0
     2.AND.SL(2,NY,NX).GT.0.0)THEN
      IRCHG(NN,N,NY,NX)=0
      ELSE
      IRCHG(NN,N,NY,NX)=1
      ENDIF
      ELSE
      GO TO 9575
      ENDIF
      ELSEIF(NN.EQ.2)THEN
      IF(NX.EQ.NHW)THEN
      IF(ASP(NY,NX).LT.90.0.OR.ASP(NY,NX).GT.270.0 
     2.AND.SL(2,NY,NX).GT.0.0)THEN
      IRCHG(NN,N,NY,NX)=0
      ELSE
      IRCHG(NN,N,NY,NX)=1
      ENDIF
      ELSE
      GO TO 9575
      ENDIF
      ENDIF
      ELSEIF(N.EQ.2)THEN
      IF(NN.EQ.1)THEN
      IF(NY.EQ.NVS)THEN
      IF(ASP(NY,NX).LT.180.0.AND.ASP(NY,NX).GT.0.0 
     2.AND.SL(1,NY,NX).GT.0.0)THEN
      IRCHG(NN,N,NY,NX)=0
      ELSE
      IRCHG(NN,N,NY,NX)=1
      ENDIF
      ELSE
      GO TO 9575
      ENDIF
      ELSEIF(NN.EQ.2)THEN
      IF(NY.EQ.NVN)THEN
      IF(ASP(NY,NX).EQ.0)THEN
      ASP2=360.0
      ELSE
      ASP2=ASP(NY,NX)
      ENDIF
      IF(ASP2.GT.180.0.AND.ASP2.LT.360.0 
     2.AND.SL(1,NY,NX).GT.0.0)THEN
      IRCHG(NN,N,NY,NX)=0
      ELSE
      IRCHG(NN,N,NY,NX)=1
      ENDIF
      ELSE
      GO TO 9575
      ENDIF
      ENDIF
      ENDIF
9575  CONTINUE
C
C     INITIALIZE WATER AND TEMPERATURE VARIABLES FOR SOIL LAYERS
C
      PSIMS(NY,NX)=LOG(-PSIPS)
      PSIMX(NY,NX)=LOG(-PSIFC(NY,NX))
      PSIMN(NY,NX)=LOG(-PSIWP(NY,NX))
      PSISD(NY,NX)=PSIMX(NY,NX)-PSIMS(NY,NX)
      PSIMD(NY,NX)=PSIMN(NY,NX)-PSIMX(NY,NX)
      NW(NY,NX)=0
      CORGC(0,NY,NX)=0.5E+06
C
C     DISTRIBUTION OF OM AMONG FRACTIONS OF DIFFERING
C     BIOLOGICAL ACTIVITY
C
      DO 1195 L=0,NL(NY,NX)
C
C     LAYER DEPTHS AND THEIR PHYSICAL PROPOERTIES
C
      DLYR(1,L,NY,NX)=DH(NY,NX)
      DLYR(2,L,NY,NX)=DV(NY,NX)
      AREA(3,L,NY,NX)=DLYR(1,L,NY,NX)*DLYR(2,L,NY,NX)
      IF(L.EQ.0)THEN
      TAREA=TAREA+AREA(3,L,NY,NX)
      CDPTH(L,NY,NX)=0.0
      CDPTHZ(L,NY,NX)=0.0
      ORGC(L,NY,NX)=(RSC(0,L,NY,NX)+RSC(1,L,NY,NX)+RSC(2,L,NY,NX))
     2*AREA(3,L,NY,NX)
      VOLR(NY,NX)=(RSC(0,L,NY,NX)*1.0E-06/BKRS(0)
     2+RSC(1,L,NY,NX)*1.0E-06/BKRS(1)+RSC(2,L,NY,NX)*1.0E-06/BKRS(2))
     2*AREA(3,L,NY,NX)
      VOLT(L,NY,NX)=VOLR(NY,NX)
      VOLX(L,NY,NX)=VOLT(L,NY,NX)
      BKVL(L,NY,NX)=2.00E-06*ORGC(L,NY,NX)
      DLYR(3,L,NY,NX)=VOLX(L,NY,NX)/AREA(3,L,NY,NX)
      ELSE
      DLYR(3,L,NY,NX)=(CDPTH(L,NY,NX)-CDPTH(L-1,NY,NX))
      DPTH(L,NY,NX)=0.5*(CDPTH(L,NY,NX)+CDPTH(L-1,NY,NX))
      CDPTHZ(L,NY,NX)=CDPTH(L,NY,NX)-CDPTH(NU(NY,NX),NY,NX)
     2+DLYR(3,NU(NY,NX),NY,NX)
      DPTHZ(L,NY,NX)=0.5*(CDPTHZ(L,NY,NX)+CDPTHZ(L-1,NY,NX))
      VOLT(L,NY,NX)=AREA(3,L,NY,NX)*DLYR(3,L,NY,NX)
      VOLX(L,NY,NX)=VOLT(L,NY,NX)*FMPR(L,NY,NX)
      BKVL(L,NY,NX)=BKDS(L,NY,NX)*VOLX(L,NY,NX)
      YDPTH(L,NY,NX)=ALT(NY,NX)-DPTH(L,NY,NX)
      RTDNT(L,NY,NX)=0.0
      IF(BKDS(L,NY,NX).GT.0.0.AND.NW(NY,NX).EQ.0)NW(NY,NX)=L
      ENDIF
      AREA(1,L,NY,NX)=DLYR(3,L,NY,NX)*DLYR(2,L,NY,NX)
      AREA(2,L,NY,NX)=DLYR(3,L,NY,NX)*DLYR(1,L,NY,NX)
1195  CONTINUE
C
C     SURFACE WATER STORAGE AND LOWER HEAT SINK
C
      VHCPW(NY,NX)=2.095*VOLSS(NY,NX)+4.19*VOLWS(NY,NX)
     2+1.9274*VOLIS(NY,NX)
      VHCPWX(NY,NX)=10.5E-03*AREA(3,NU(NY,NX),NY,NX)
      VHCPRX(NY,NX)=10.5E-05*AREA(3,NU(NY,NX),NY,NX)
      DPTHSK(NY,NX)=AMAX1(10.0,CDPTH(NL(NY,NX),NY,NX)+1.0)
      TCNDG=8.1E-03
      TKSD(NY,NX)=ATKS(NY,NX)+2.052E-04*DPTHSK(NY,NX)/TCNDG
C
C     INITIALIZE COMMUNITY CANOPY
C
      ZT(NY,NX)=0.0
      ZL(0,NY,NX)=0.0
      DO 1925 L=1,JC
      ZL(L,NY,NX)=0.0
      ARLFT(L,NY,NX)=0.0
      ARSTT(L,NY,NX)=0.0
      WGLFT(L,NY,NX)=0.0
1925  CONTINUE
9990  CONTINUE
9995  CONTINUE
C
C     INITIALIZE GRID CELL DIMENSIONS
C
      DO 9895 NX=NHW,NHE
      DO 9890 NY=NVN,NVS
      ALTZ(NY,NX)=ALTZG
      IF(BKDS(NU(NY,NX),NY,NX).GT.0.0)THEN
      DTBLZ(NY,NX)=DTBLI(NY,NX)-(ALTZ(NY,NX)-ALT(NY,NX))
     2*(1.0-DTBLG(NY,NX))
      DDRG(NY,NX)=AMAX1(0.0,DDRGI(NY,NX)-(ALTZ(NY,NX)-ALT(NY,NX))
     2*(1.0-DTBLG(NY,NX)))
      ELSE
      DTBLZ(NY,NX)=0.0
      DDRG(NY,NX)=0.0
      ENDIF
      DPTHT(NY,NX)=DTBLZ(NY,NX)
      DO 4400 L=1,NL(NY,NX)
      N1=NX
      N2=NY
      N3=L
      DO 4320 N=NCN(N2,N1),3
      IF(N.EQ.1)THEN
      IF(NX.EQ.NHE)THEN
      GO TO 4320
      ELSE
      N4=NX+1
      N5=NY
      N6=L
      ENDIF
      ELSEIF(N.EQ.2)THEN
      IF(NY.EQ.NVS)THEN
      GO TO 4320
      ELSE
      N4=NX
      N5=NY+1
      N6=L
      ENDIF
      ELSEIF(N.EQ.3)THEN
      IF(L.EQ.NL(NY,NX))THEN
      GO TO 4320
      ELSE
      N4=NX
      N5=NY
      N6=L+1
      ENDIF
      ENDIF
      DIST(N,N6,N5,N4)=0.5*(DLYR(N,N3,N2,N1)+DLYR(N,N6,N5,N4))
      XDPTH(N,N6,N5,N4)=AREA(N,N3,N2,N1)/DIST(N,N6,N5,N4)
      DISP(N,N6,N5,N4)=0.20*DIST(N,N6,N5,N4)**1.07
4320  CONTINUE
      IF(L.EQ.NU(NY,NX))THEN
      DIST(3,N3,N2,N1)=0.5*DLYR(3,N3,N2,N1)
      XDPTH(3,N3,N2,N1)=AREA(3,N3,N2,N1)/DIST(3,N3,N2,N1)
      DISP(3,N3,N2,N1)=0.20*DIST(3,N3,N2,N1)**1.07
      ENDIF
4400  CONTINUE
C
C     INITIALIZE SOM FROM ORGANIC INPUTS IN SOIL FILE FROM 'READS'
C
      TORGC=0.0
      DO 1190 L=NU(NY,NX),NL(NY,NX)
      CORGCZ=CORGC(L,NY,NX)
      CORGRZ=CORGR(L,NY,NX)
      CORGNZ=CORGN(L,NY,NX)
      CORGPZ=CORGP(L,NY,NX)
      CORGCX(3)=CORGRZ
      CORGCX(4)=AMAX1(0.0,CORGCZ-CORGCX(3))
      CORGNX(3)=AMIN1(CNRH(3)*CORGCX(3),CORGNZ)
      CORGNX(4)=AMAX1(0.0,CORGNZ-CORGNX(3))
      CORGPX(3)=AMIN1(CPRH(3)*CORGCX(3),CORGPZ)
      CORGPX(4)=AMAX1(0.0,CORGPZ-CORGPX(3)) 
      CORGL=AMAX1(0.0,CORGC(L,NY,NX)-CORGR(L,NY,NX))
      TORGL(L)=TORGC+CORGL*BKVL(L,NY,NX)/AREA(3,L,NY,NX)*0.5
      TORGC=TORGC+CORGL*BKVL(L,NY,NX)/AREA(3,L,NY,NX)
1190  CONTINUE
      TORGM=AMIN1(0.5E+04,0.25*TORGL(NJ(NY,NX)))
      IF(TORGM.GT.ZERO)THEN
      HCX=LOG(0.5)/TORGM
      ELSE
      HCX=0.0
      ENDIF
      DO 1200 L=0,NL(NY,NX)
      IF(BKVL(L,NY,NX).GT.0.0)THEN
      CORGCX(0)=RSC(0,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGCX(1)=RSC(1,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGCX(2)=RSC(2,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGNX(0)=RSN(0,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGNX(1)=RSN(1,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGNX(2)=RSN(2,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGPX(0)=RSP(0,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGPX(1)=RSP(1,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      CORGPX(2)=RSP(2,L,NY,NX)*AREA(3,L,NY,NX)/BKVL(L,NY,NX)
      ELSE
      CORGCX(0)=0.5E+06
      CORGCX(1)=0.5E+06
      CORGCX(2)=0.5E+06
      CORGNX(0)=0.5E+05
      CORGNX(1)=0.5E+05
      CORGNX(2)=0.5E+05
      CORGPX(0)=0.5E+04
      CORGPX(1)=0.5E+04
      CORGPX(2)=0.5E+04
      ENDIF
      IF(L.GT.0)THEN
      CORGCZ=CORGC(L,NY,NX)
      CORGRZ=CORGR(L,NY,NX)
      CORGNZ=CORGN(L,NY,NX)
      CORGPZ=CORGP(L,NY,NX)
      IF(CORGCZ.GT.ZERO)THEN
      CORGCX(3)=CORGRZ
      CORGCX(4)=AMAX1(0.0,CORGCZ-CORGCX(3))
      CORGNX(3)=AMIN1(CNRH(3)*CORGCX(3),CORGNZ)
      CORGNX(4)=AMAX1(0.0,CORGNZ-CORGNX(3))
      CORGPX(3)=AMIN1(CPRH(3)*CORGCX(3),CORGPZ)
      CORGPX(4)=AMAX1(0.0,CORGPZ-CORGPX(3)) 
      ELSE
      CORGCX(3)=0.0
      CORGCX(4)=0.0
      CORGNX(3)=0.0
      CORGNX(4)=0.0
      CORGPX(3)=0.0
      CORGPX(4)=0.0
      ENDIF
      ELSE
      CORGCX(3)=0.0
      CORGCX(4)=0.0
      CORGNX(3)=0.0
      CORGNX(4)=0.0
      CORGPX(3)=0.0
      CORGPX(4)=0.0
      ENDIF
C
C     SURFACE RESIDUE
C
      IF(L.EQ.0)THEN
C
C     PREVIOUS COARSE WOODY RESIDUE
C
      CFOSC(1,0,L,NY,NX)=0.000
      CFOSC(2,0,L,NY,NX)=0.045
      CFOSC(3,0,L,NY,NX)=0.660
      CFOSC(4,0,L,NY,NX)=0.295
C
C     MAIZE
C
      IF(IXTYP(1,NY,NX).EQ.1)THEN
      CFOSC(1,1,L,NY,NX)=0.080
      CFOSC(2,1,L,NY,NX)=0.245
      CFOSC(3,1,L,NY,NX)=0.613
      CFOSC(4,1,L,NY,NX)=0.062
C
C     WHEAT
C
      ELSEIF(IXTYP(1,NY,NX).EQ.2)THEN
      CFOSC(1,1,L,NY,NX)=0.125
      CFOSC(2,1,L,NY,NX)=0.171
      CFOSC(3,1,L,NY,NX)=0.560
      CFOSC(4,1,L,NY,NX)=0.144
C
C     SOYBEAN
C
      ELSEIF(IXTYP(1,NY,NX).EQ.3)THEN
      CFOSC(1,1,L,NY,NX)=0.138
      CFOSC(2,1,L,NY,NX)=0.426
      CFOSC(3,1,L,NY,NX)=0.316
      CFOSC(4,1,L,NY,NX)=0.120
C
C     NEW STRAW
C
      ELSEIF(IXTYP(1,NY,NX).EQ.4)THEN
      CFOSC(1,1,L,NY,NX)=0.036
      CFOSC(2,1,L,NY,NX)=0.044
      CFOSC(3,1,L,NY,NX)=0.767
      CFOSC(4,1,L,NY,NX)=0.153
C
C     OLD STRAW
C
      ELSEIF(IXTYP(1,NY,NX).EQ.5)THEN
      CFOSC(1,1,L,NY,NX)=0.075
      CFOSC(2,1,L,NY,NX)=0.125
      CFOSC(3,1,L,NY,NX)=0.550
      CFOSC(4,1,L,NY,NX)=0.250
C
C     COMPOST
C
      ELSEIF(IXTYP(1,NY,NX).EQ.6)THEN
      CFOSC(1,1,L,NY,NX)=0.143
      CFOSC(2,1,L,NY,NX)=0.015
      CFOSC(3,1,L,NY,NX)=0.640
      CFOSC(4,1,L,NY,NX)=0.202
C
C     GREEN MANURE
C
      ELSEIF(IXTYP(1,NY,NX).EQ.7)THEN
      CFOSC(1,1,L,NY,NX)=0.202
      CFOSC(2,1,L,NY,NX)=0.013
      CFOSC(3,1,L,NY,NX)=0.560
      CFOSC(4,1,L,NY,NX)=0.225
C
C     NEW DECIDUOUS FOREST
C
      ELSEIF(IXTYP(1,NY,NX).EQ.8)THEN
      CFOSC(1,1,L,NY,NX)=0.07
      CFOSC(2,1,L,NY,NX)=0.41
      CFOSC(3,1,L,NY,NX)=0.36
      CFOSC(4,1,L,NY,NX)=0.16
C
C     NEW CONIFEROUS FOREST
C
      ELSEIF(IXTYP(1,NY,NX).EQ.9)THEN
      CFOSC(1,1,L,NY,NX)=0.07
      CFOSC(2,1,L,NY,NX)=0.25
      CFOSC(3,1,L,NY,NX)=0.38
      CFOSC(4,1,L,NY,NX)=0.30
C
C     OLD DECIDUOUS FOREST
C
      ELSEIF(IXTYP(1,NY,NX).EQ.10)THEN
      CFOSC(1,1,L,NY,NX)=0.02
      CFOSC(2,1,L,NY,NX)=0.06
      CFOSC(3,1,L,NY,NX)=0.34
      CFOSC(4,1,L,NY,NX)=0.58
C
C     OLD CONIFEROUS FOREST
C
      ELSEIF(IXTYP(1,NY,NX).EQ.11)THEN
      CFOSC(1,1,L,NY,NX)=0.02
      CFOSC(2,1,L,NY,NX)=0.06
      CFOSC(3,1,L,NY,NX)=0.34
      CFOSC(4,1,L,NY,NX)=0.58
C
C     DEFAULT
C
      ELSE
      CFOSC(1,1,L,NY,NX)=0.075
      CFOSC(2,1,L,NY,NX)=0.125
      CFOSC(3,1,L,NY,NX)=0.550
      CFOSC(4,1,L,NY,NX)=0.250
      ENDIF
C
C     PREVIOUS COARSE (K=0) AND FINE (K=1) ROOTS
C
      ELSE
      CFOSC(1,0,L,NY,NX)=0.00
      CFOSC(2,0,L,NY,NX)=0.00
      CFOSC(3,0,L,NY,NX)=0.20
      CFOSC(4,0,L,NY,NX)=0.80
      CFOSC(1,1,L,NY,NX)=0.02
      CFOSC(2,1,L,NY,NX)=0.06
      CFOSC(3,1,L,NY,NX)=0.34
      CFOSC(4,1,L,NY,NX)=0.58
      ENDIF
C
C     ANIMAL MANURE
C
C
C     RUMINANT
C
      IF(IXTYP(2,NY,NX).EQ.1)THEN
      CFOSC(1,2,L,NY,NX)=0.036
      CFOSC(2,2,L,NY,NX)=0.044
      CFOSC(3,2,L,NY,NX)=0.630
      CFOSC(4,2,L,NY,NX)=0.290
C
C     NON-RUMINANT
C
      ELSEIF(IXTYP(2,NY,NX).EQ.2)THEN
      CFOSC(1,2,L,NY,NX)=0.138
      CFOSC(2,2,L,NY,NX)=0.401
      CFOSC(3,2,L,NY,NX)=0.316
      CFOSC(4,2,L,NY,NX)=0.145
C
C     OTHER
C
      ELSE 
      CFOSC(1,2,L,NY,NX)=0.138
      CFOSC(2,2,L,NY,NX)=0.401
      CFOSC(3,2,L,NY,NX)=0.316
      CFOSC(4,2,L,NY,NX)=0.145
      ENDIF
C
C     POM
C
      IF(L.NE.0)THEN
      CFOSC(1,3,L,NY,NX)=1.00
      CFOSC(2,3,L,NY,NX)=0.00
      CFOSC(3,3,L,NY,NX)=0.00
      CFOSC(4,3,L,NY,NX)=0.00
C
C     HUMUS PARTITIONED TO DIFFERENT FRACTIONS
C     BASED ON SOC ACCUMULATION
C
C     NATURAL SOILS
C
C
      IF(ISOILR(NY,NX).EQ.0)THEN
C
C     DRYLAND
C
      IF(DPTH(L,NY,NX).LE.DTBLZ(NY,NX)
     2+CDPTH(NU(NY,NX),NY,NX)-CDPTHG)THEN
      FCY=0.60
      IF(CORGCX(4).GT.1.0E-32)THEN
      FC0=FCY*EXP(-5.0*(AMIN1(CORGNX(4),10.0*CORGPX(4))
     2/CORGCX(4)))
      ELSE
      FCO=FCY
      ENDIF
      FCX=EXP(HCX*TORGL(L))
C
C     WETLAND
C
      ELSE
      FCY=0.60
      IF(CORGCX(4).GT.1.0E-32)THEN
      FC0=FCY*EXP(-5.0*(AMIN1(CORGNX(4),10.0*CORGPX(4))
     2/CORGCX(4)))
      ELSE
      FCO=FCY
      ENDIF
      FCX=(EXP(HCX*TORGL(L)))**0.50
      ENDIF
      ELSE
C
C     RECONSTRUCTED SOILS
C
      FCY=0.60
      IF(CORGCX(4).GT.1.0E-32)THEN
      FC0=FCY*EXP(-5.0*(AMIN1(CORGNX(4),10.0*CORGPX(4))
     2/CORGCX(4)))
      ELSE
      FCO=FCY
      ENDIF
      FCX=0.10
      ENDIF
      FC1=FC0*FCX 
      CFOSC(1,4,L,NY,NX)=FC1
      CFOSC(2,4,L,NY,NX)=1.0-FC1
      CFOSC(3,4,L,NY,NX)=0.00
      CFOSC(4,4,L,NY,NX)=0.00
C
C     MICROBIAL DETRITUS TO HUMUS MAINTAINS EXISTING PARTITIONING
C
      CFOMC(1,L,NY,NX)=3.0*FC1/(2.0*FC1+1.0)
      CFOMC(2,L,NY,NX)=1.0-CFOMC(1,L,NY,NX)
      WRITE(*,5432)'PART',L,FC0,FC1,FCX,TORGM,TORGL(L),HCX
     2,CORGCX(4),CORGNX(4),CORGPX(4),DPTH(L,NY,NX),DTBLZ(NY,NX)
     3,CDPTH(NU(NY,NX),NY,NX),CDPTHG 
5432  FORMAT(A8,I4,20E12.4)
      ENDIF
C
C     LAYER SOIL, HEAT, WATER, ICE, GAS AND AIR CONTENTS
C
      PSISE(L,NY,NX)=PSIPS
      ROXYF(L,NY,NX)=0.0
      RCO2F(L,NY,NX)=0.0
      ROXYL(L,NY,NX)=0.0
      RCH4F(L,NY,NX)=0.0
      RCH4L(L,NY,NX)=0.0
      IF(L.GT.0)THEN
      HYST(L,NY,NX)=1.0
      CORGCM=AMIN1(0.5E+06
     2,(CORGCX(1)+CORGCX(2)+CORGCX(3)+CORGCX(4)))/0.5
      PTDS=1.0E-06*(1.30*CORGCM+2.66*(1.0E+06-CORGCM))
      POROS(L,NY,NX)=1.0-(BKDS(L,NY,NX)/PTDS)
      VOLA(L,NY,NX)=POROS(L,NY,NX)*VOLX(L,NY,NX)
      VOLAH(L,NY,NX)=FHOL(L,NY,NX)*VOLT(L,NY,NX)
      IF(ISOIL(1,L,NY,NX).EQ.0.AND.ISOIL(2,L,NY,NX).EQ.0)THEN
      IF(THW(L,NY,NX).GT.1.0.OR.DPTH(L,NY,NX).GE.DTBLZ(NY,NX))THEN
      THW(L,NY,NX)=POROS(L,NY,NX)
      ELSEIF(THW(L,NY,NX).EQ.1.0)THEN 
      THW(L,NY,NX)=FC(L,NY,NX)
      ELSEIF(THW(L,NY,NX).LE.0.0)THEN 
      THW(L,NY,NX)=WP(L,NY,NX)
      ENDIF
      IF(THI(L,NY,NX).GT.1.0.OR.DPTH(L,NY,NX).GE.DTBLZ(NY,NX))THEN
      THI(L,NY,NX)=AMAX1(0.0,AMIN1(POROS(L,NY,NX)
     2,POROS(L,NY,NX)-THW(L,NY,NX)))
      ELSEIF(THI(L,NY,NX).EQ.1.0)THEN 
      THI(L,NY,NX)=AMAX1(0.0,AMIN1(FC(L,NY,NX)
     2,POROS(L,NY,NX)-THW(L,NY,NX)))
      ELSEIF(THI(L,NY,NX).LT.0.0)THEN 
      THI(L,NY,NX)=AMAX1(0.0,AMIN1(WP(L,NY,NX)
     2,POROS(L,NY,NX)-THW(L,NY,NX)))
      ENDIF
      THETW(L,NY,NX)=THW(L,NY,NX)
      VOLW(L,NY,NX)=THETW(L,NY,NX)*VOLX(L,NY,NX)
      VOLWX(L,NY,NX)=VOLW(L,NY,NX)
      VOLWH(L,NY,NX)=THETW(L,NY,NX)*VOLAH(L,NY,NX)
      THETI(L,NY,NX)=THI(L,NY,NX)
      VOLI(L,NY,NX)=THETI(L,NY,NX)*VOLX(L,NY,NX)
      VOLIH(L,NY,NX)=THETI(L,NY,NX)*VOLAH(L,NY,NX)
      ENDIF
      VOLP(L,NY,NX)=AMAX1(0.0,VOLA(L,NY,NX)-VOLW(L,NY,NX)
     2-VOLI(L,NY,NX))+AMAX1(0.0,VOLAH(L,NY,NX)-VOLWH(L,NY,NX)
     3-VOLIH(L,NY,NX))
      SAND(L,NY,NX)=CSAND(L,NY,NX)*BKVL(L,NY,NX)
      SILT(L,NY,NX)=CSILT(L,NY,NX)*BKVL(L,NY,NX)
      CLAY(L,NY,NX)=CCLAY(L,NY,NX)*BKVL(L,NY,NX)
      VORGC=CORGCM*1.0E-06*BKDS(L,NY,NX)/PTDS
      VMINL=(CSILT(L,NY,NX)+CCLAY(L,NY,NX))*BKDS(L,NY,NX)/PTDS
      VSAND=CSAND(L,NY,NX)*BKDS(L,NY,NX)/PTDS
      VHCM(L,NY,NX)=((2.496*VORGC+2.385*VMINL+2.128*VSAND)
     2*FMPR(L,NY,NX)+2.128*ROCK(L,NY,NX))*VOLT(L,NY,NX)
      VHCP(L,NY,NX)=VHCM(L,NY,NX)+4.19*(VOLW(L,NY,NX)
     2+VOLWH(L,NY,NX))+1.9274*(VOLI(L,NY,NX)+VOLIH(L,NY,NX))
      TCS(L,NY,NX)=ATCS(NY,NX)
      TKS(L,NY,NX)=TCS(L,NY,NX)+273.15
      PSISA(L,NY,NX)=-2.5E-03
      ELSE
      VOLW(L,NY,NX)=1.0E-06*ORGC(L,NY,NX)
      VOLWX(L,NY,NX)=VOLW(L,NY,NX)
      VOLI(L,NY,NX)=0.0
      IF(VOLX(L,NY,NX).GT.0.0)THEN
      THETW(L,NY,NX)=AMAX1(0.001,VOLW(L,NY,NX)/VOLX(L,NY,NX))
      ELSE
      THETW(L,NY,NX)=0.001
      ENDIF
      THETP(L,NY,NX)=0.95-THETW(L,NY,NX)
      THETI(L,NY,NX)=0.0
      VHCPR(NY,NX)=2.496E-06*ORGC(L,NY,NX)+4.19*VOLW(L,NY,NX)
     2+1.9274*VOLI(L,NY,NX)
      ENDIF
C
C     INITIALIZE SOM VARIABLES
C
      DO 975 K=0,2
      CNOSCT(K)=0.0
      CPOSCT(K)=0.0
      IF(RSC(K,L,NY,NX).GT.ZEROS(NY,NX))THEN
      RNT=0.0
      RPT=0.0
      DO 970 M=1,4
      RNT=RNT+RSC(K,L,NY,NX)*CFOSC(M,K,L,NY,NX)*CNOFC(M,K)
      RPT=RPT+RSC(K,L,NY,NX)*CFOSC(M,K,L,NY,NX)*CPOFC(M,K)
970   CONTINUE
      FRNT=RSN(K,L,NY,NX)/RNT
      FRPT=RSP(K,L,NY,NX)/RPT
      DO 960 M=1,4
      CNOSC(M,K,L,NY,NX)=CNOFC(M,K)*FRNT
      CPOSC(M,K,L,NY,NX)=CPOFC(M,K)*FRPT
      CNOSCT(K)=CNOSCT(K)+CFOSC(M,K,L,NY,NX)*CNOSC(M,K,L,NY,NX)
      CPOSCT(K)=CPOSCT(K)+CFOSC(M,K,L,NY,NX)*CPOSC(M,K,L,NY,NX)
960   CONTINUE
      ELSE
      DO 965 M=1,4
      CNOSC(M,K,L,NY,NX)=CNRH(K)
      CPOSC(M,K,L,NY,NX)=CPRH(K)
965   CONTINUE
      CNOSCT(K)=CNRH(K)
      CPOSCT(K)=CPRH(K)
      ENDIF
975   CONTINUE
      DO 990 K=3,4
      CNOSCT(K)=0.0
      CPOSCT(K)=0.0
      IF(CORGCX(K).GT.ZERO)THEN
      DO 985 M=1,4
      CNOSC(M,K,L,NY,NX)=CORGNX(K)/CORGCX(K)
      CPOSC(M,K,L,NY,NX)=CORGPX(K)/CORGCX(K)
      CNOSCT(K)=CNOSCT(K)+CFOSC(M,K,L,NY,NX)*CNOSC(M,K,L,NY,NX)
      CPOSCT(K)=CPOSCT(K)+CFOSC(M,K,L,NY,NX)*CPOSC(M,K,L,NY,NX)
985   CONTINUE
      ELSE
      DO 980 M=1,4
      CNOSC(M,K,L,NY,NX)=CNRH(K)
      CPOSC(M,K,L,NY,NX)=CPRH(K)
980   CONTINUE
      CNOSCT(K)=CNRH(K)
      CPOSCT(K)=CPRH(K)
      ENDIF
990   CONTINUE
      TOSCI=0.0
      TOSNI=0.0
      TOSPI=0.0
      DO 995 K=0,4
      IF(L.EQ.0)THEN
      KK=K
      ELSE
      KK=4
      ENDIF
      OSCI(K)=CORGCX(K)*BKVL(L,NY,NX)
      OSNI(K)=CORGNX(K)*BKVL(L,NY,NX)
      OSPI(K)=CORGPX(K)*BKVL(L,NY,NX)
      TOSCK(K)=OMCK(K)+ORCK(K)+OQCK(K)+OHCK(K)
      TOSNK(K)=OMCI(1,K)*CNOMC(1,1,K)+OMCI(2,K)*CNOMC(2,1,K)
     2+ORCK(K)*CNRH(K)+OQCK(K)*CNOSCT(KK)+OHCK(K)*CNOSCT(KK)
      TOSPK(K)=OMCI(1,K)*CPOMC(1,1,K)+OMCI(2,K)*CPOMC(2,1,K)
     2+ORCK(K)*CPRH(K)+OQCK(K)*CPOSCT(KK)+OHCK(K)*CPOSCT(KK)
      TOSCI=TOSCI+OSCI(K)*TOSCK(K)
      TOSNI=TOSNI+OSCI(K)*TOSNK(K)
      TOSPI=TOSPI+OSCI(K)*TOSPK(K)
      OSCX(K)=0.0
      OSNX(K)=0.0
      OSPX(K)=0.0
995   CONTINUE
      TOMC=0.0
      DO 8995 K=0,4
      IF(L.EQ.0)THEN
      OSCM(K)=DCKR*CORGCX(K)*BKVL(L,NY,NX)
      X=0.0
      KK=K
      FOSCI=1.0
      FOSNI=1.0
      FOSPI=1.0
C     WRITE(*,2424)'OSCM',NX,NY,L,K,OSCM(K),CORGCX(K)
C    2,BKVL(L,NY,NX),CORGCX(K)*BKVL(L,NY,NX),FCX
      ELSE
      IF(K.LE.2)THEN
      OSCM(K)=DCKR*CORGCX(K)*BKVL(L,NY,NX)
      ELSE
      OSCM(K)=FCX*CORGCX(K)*BKVL(L,NY,NX)*DCKM/(CORGCX(4)+DCKM) 
      ENDIF
2424  FORMAT(A8,4I4,12E12.4)
      X=1.0
      KK=4
      IF(TOSCI.GT.ZEROS(NY,NX))THEN
      FOSCI=AMIN1(1.0,OSCI(KK)/TOSCI)
      FOSNI=AMIN1(1.0,OSCI(KK)*CNOSCT(KK)/TOSNI)
      FOSPI=AMIN1(1.0,OSCI(KK)*CPOSCT(KK)/TOSPI)
      ELSE
      FOSCI=0.0
      FOSNI=0.0
      FOSPI=0.0
      ENDIF
      ENDIF
C
C     MICROBIAL C, N AND P
C
      DO 7990 N=1,7
      DO 7985 M=1,3
      OMC(M,N,5,L,NY,NX)=0.0 
      OMN(M,N,5,L,NY,NX)=0.0 
      OMP(M,N,5,L,NY,NX)=0.0
7985  CONTINUE
7990  CONTINUE
      DO 8990 N=1,7
      DO 8991 M=1,3
      OMC1=AMAX1(0.0,OSCM(K)*OMCI(M,K)*OMCF(N)*FOSCI)
      OMN1=AMAX1(0.0,OMC1*CNOMC(M,N,K)*FOSNI)
      OMP1=AMAX1(0.0,OMC1*CPOMC(M,N,K)*FOSPI)
      OMC(M,N,K,L,NY,NX)=OMC1 
      OMN(M,N,K,L,NY,NX)=OMN1 
      OMP(M,N,K,L,NY,NX)=OMP1 
      OSCX(KK)=OSCX(KK)+OMC1
      OSNX(KK)=OSNX(KK)+OMN1
      OSPX(KK)=OSPX(KK)+OMP1
      DO 8992 NN=1,7
      OMC(M,NN,5,L,NY,NX)=OMC(M,NN,5,L,NY,NX)+OMC1*OMCA(NN) 
      OMN(M,NN,5,L,NY,NX)=OMN(M,NN,5,L,NY,NX)+OMN1*OMCA(NN) 
      OMP(M,NN,5,L,NY,NX)=OMP(M,NN,5,L,NY,NX)+OMP1*OMCA(NN) 
      OSCX(KK)=OSCX(KK)+OMC1*OMCA(NN)
      OSNX(KK)=OSNX(KK)+OMN1*OMCA(NN)
      OSPX(KK)=OSPX(KK)+OMP1*OMCA(NN)
8992  CONTINUE
8991  CONTINUE
8990  CONTINUE
C
C     MICROBIAL RESIDUE C, N AND P
C
      DO 8985 M=1,2
      ORC(M,K,L,NY,NX)=X*AMAX1(0.0,OSCM(K)*ORCI(M,K)*FOSCI)
      ORN(M,K,L,NY,NX)=AMAX1(0.0,ORC(M,K,L,NY,NX)*CNOMC(M,1,K)*FOSNI)
      ORP(M,K,L,NY,NX)=AMAX1(0.0,ORC(M,K,L,NY,NX)*CPOMC(M,1,K)*FOSPI)
      OSCX(KK)=OSCX(KK)+ORC(M,K,L,NY,NX)
      OSNX(KK)=OSNX(KK)+ORN(M,K,L,NY,NX)
      OSPX(KK)=OSPX(KK)+ORP(M,K,L,NY,NX)
8985  CONTINUE
C
C     DOC, DON AND DOP
C
      OQC(K,L,NY,NX)=X*AMAX1(0.0,OSCM(K)*OQCK(K)*FOSCI)
      OQN(K,L,NY,NX)=AMAX1(0.0,OQC(K,L,NY,NX)*CNOSCT(KK)*FOSNI)
      OQP(K,L,NY,NX)=AMAX1(0.0,OQC(K,L,NY,NX)*CPOSCT(KK)*FOSPI)
      OQA(K,L,NY,NX)=0.0
      OQCH(K,L,NY,NX)=0.0
      OQNH(K,L,NY,NX)=0.0
      OQPH(K,L,NY,NX)=0.0
      OQAH(K,L,NY,NX)=0.0
      OSCX(KK)=OSCX(KK)+OQC(K,L,NY,NX)
      OSNX(KK)=OSNX(KK)+OQN(K,L,NY,NX)
      OSPX(KK)=OSPX(KK)+OQP(K,L,NY,NX)
C
C     ADSORBED C, N AND P
C
      OHC(K,L,NY,NX)=X*AMAX1(0.0,OSCM(K)*OHCK(K)*FOSCI)
      OHN(K,L,NY,NX)=AMAX1(0.0,OHC(K,L,NY,NX)*CNOSCT(KK)*FOSNI)
      OHP(K,L,NY,NX)=AMAX1(0.0,OHC(K,L,NY,NX)*CPOSCT(KK)*FOSPI)
      OHA(K,L,NY,NX)=0.0
      OSCX(KK)=OSCX(KK)+OHC(K,L,NY,NX)+OHA(K,L,NY,NX)
      OSNX(KK)=OSNX(KK)+OHN(K,L,NY,NX)
      OSPX(KK)=OSPX(KK)+OHP(K,L,NY,NX)
C
C     HUMUS C, N AND P
C
      DO 8980 M=1,4
      OSC(M,K,L,NY,NX)=AMAX1(0.0,CFOSC(M,K,L,NY,NX)*(OSCI(K)-OSCX(K)))
      IF(CNOSCT(K).GT.ZERO)THEN
      OSN(M,K,L,NY,NX)=AMAX1(0.0,CFOSC(M,K,L,NY,NX)*CNOSC(M,K,L,NY,NX)
     2/CNOSCT(K)*(OSNI(K)-OSNX(K)))
      ELSE
      OSN(M,K,L,NY,NX)=0.0
      ENDIF
      IF(CPOSCT(K).GT.ZERO)THEN
      OSP(M,K,L,NY,NX)=AMAX1(0.0,CFOSC(M,K,L,NY,NX)*CPOSC(M,K,L,NY,NX)
     2/CPOSCT(K)*(OSPI(K)-OSPX(K)))
      ELSE
      OSP(M,K,L,NY,NX)=0.0
      ENDIF
      IF(K.EQ.0)THEN
      OSA(M,K,L,NY,NX)=0.0
      ELSE
      OSA(M,K,L,NY,NX)=OSC(M,K,L,NY,NX)
      ENDIF
8980  CONTINUE
8995  CONTINUE
      OC=0.0
      ON=0.0
      OP=0.0
      RC=0.0
      IF(L.EQ.0)THEN
      DO 6975 K=0,5
      RC0(K,NY,NX)=0.0
      RA0(K,NY,NX)=0.0
6975  CONTINUE
      ENDIF
      DO 6990 K=0,5
      DO 6990 N=1,7
      OC=OC+OMC(3,N,K,L,NY,NX)
      ON=ON+OMN(3,N,K,L,NY,NX)
      OP=OP+OMP(3,N,K,L,NY,NX)
      IF(K.LE.2)THEN
      RC=RC+OMC(3,N,K,L,NY,NX)
      ENDIF
      ROXYS(N,K,L,NY,NX)=0.0
      RVMX4(N,K,L,NY,NX)=0.0
      RVMX3(N,K,L,NY,NX)=0.0
      RVMX2(N,K,L,NY,NX)=0.0
      RVMX1(N,K,L,NY,NX)=0.0
      RINHO(N,K,L,NY,NX)=0.0
      RINOO(N,K,L,NY,NX)=0.0
      RIPOO(N,K,L,NY,NX)=0.0
      IF(L.EQ.0)THEN
      RINHOR(N,K,NY,NX)=0.0
      RINOOR(N,K,NY,NX)=0.0
      RIPOOR(N,K,NY,NX)=0.0
      ENDIF
      DO 6990 M=1,3
      OC=OC+OMC(M,N,K,L,NY,NX)
      ON=ON+OMN(M,N,K,L,NY,NX)
      OP=OP+OMP(M,N,K,L,NY,NX)
      IF(K.LE.2)THEN
      RC=RC+OMC(M,N,K,L,NY,NX)
      ENDIF
      RC0(K,NY,NX)=RC0(K,NY,NX)+OMC(M,N,K,L,NY,NX)
      RA0(K,NY,NX)=RA0(K,NY,NX)+OMC(M,N,K,L,NY,NX)
6990  CONTINUE
      DO 6995 K=0,4
      DO 6985 M=1,2
      OC=OC+ORC(M,K,L,NY,NX)
      ON=ON+ORN(M,K,L,NY,NX)
      OP=OP+ORP(M,K,L,NY,NX)
      IF(K.LE.2)THEN
      RC=RC+ORC(M,K,L,NY,NX)
      ENDIF
      IF(L.EQ.0)THEN
      RC0(K,NY,NX)=RC0(K,NY,NX)+ORC(M,K,L,NY,NX)
      RA0(K,NY,NX)=RA0(K,NY,NX)+ORC(M,K,L,NY,NX)
      ENDIF
6985  CONTINUE
      OC=OC+OQC(K,L,NY,NX)+OQCH(K,L,NY,NX)+OHC(K,L,NY,NX)
     2+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)+OHA(K,L,NY,NX)
      ON=ON+OQN(K,L,NY,NX)+OQNH(K,L,NY,NX)+OHN(K,L,NY,NX)
      OP=OP+OQP(K,L,NY,NX)+OQPH(K,L,NY,NX)+OHP(K,L,NY,NX)
      OC=OC+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)
      IF(K.LE.2)THEN
      RC=RC+OQC(K,L,NY,NX)+OQCH(K,L,NY,NX)+OHC(K,L,NY,NX)
     2+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)+OHA(K,L,NY,NX)
      RC=RC+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)
      ENDIF
      IF(L.EQ.0)THEN
      RC0(K,NY,NX)=RC0(K,NY,NX)+OQC(K,L,NY,NX)+OQCH(K,L,NY,NX)
     2+OHC(K,L,NY,NX)+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)+OHA(K,L,NY,NX)
      RA0(K,NY,NX)=RA0(K,NY,NX)+OQC(K,L,NY,NX)+OQCH(K,L,NY,NX)
     2+OHC(K,L,NY,NX)+OQA(K,L,NY,NX)+OQAH(K,L,NY,NX)+OHA(K,L,NY,NX)
      ENDIF
      DO 6980 M=1,4
      OC=OC+OSC(M,K,L,NY,NX)
      ON=ON+OSN(M,K,L,NY,NX)
      OP=OP+OSP(M,K,L,NY,NX)
      IF(K.LE.2)THEN
      RC=RC+OSC(M,K,L,NY,NX)
      ENDIF
      IF(L.EQ.0)THEN
      RC0(K,NY,NX)=RC0(K,NY,NX)+OSC(M,K,L,NY,NX)
      RA0(K,NY,NX)=RA0(K,NY,NX)+OSA(M,K,L,NY,NX)
      ENDIF
6980  CONTINUE
6995  CONTINUE
      ORGC(L,NY,NX)=OC
      ORGR(L,NY,NX)=RC
C
C     INITIALIZE FERTILIZER ARRAYS
C
      ZNH4FA(L,NY,NX)=0.0
      ZNH3FA(L,NY,NX)=0.0
      ZNHUFA(L,NY,NX)=0.0
      ZNO3FA(L,NY,NX)=0.0
      IF(L.GT.0)THEN
      ZNH4FB(L,NY,NX)=0.0
      ZNH3FB(L,NY,NX)=0.0
      ZNHUFB(L,NY,NX)=0.0
      ZNO3FB(L,NY,NX)=0.0
      WDNHB(L,NY,NX)=0.0
      DPNHB(L,NY,NX)=0.0
      WDNOB(L,NY,NX)=0.0
      DPNOB(L,NY,NX)=0.0
      WDPOB(L,NY,NX)=0.0
      DPPOB(L,NY,NX)=0.0
      ENDIF
      VLNH4(L,NY,NX)=1.0
      VLNO3(L,NY,NX)=1.0
      VLPO4(L,NY,NX)=1.0
      VLNHB(L,NY,NX)=0.0
      VLNOB(L,NY,NX)=0.0
      VLPOB(L,NY,NX)=0.0
      ROXYX(L,NY,NX)=0.0
      RNH4X(L,NY,NX)=0.0
      RNO3X(L,NY,NX)=0.0
      RNO2X(L,NY,NX)=0.0
      RN2OX(L,NY,NX)=0.0
      RPO4X(L,NY,NX)=0.0
      RP14X(L,NY,NX)=0.0
      RVMXC(L,NY,NX)=0.0
      RNHBX(L,NY,NX)=0.0
      RN3BX(L,NY,NX)=0.0
      RN2BX(L,NY,NX)=0.0
      RPOBX(L,NY,NX)=0.0
      RP1BX(L,NY,NX)=0.0
      RVMBC(L,NY,NX)=0.0
      DO 1250 K=0,4
      IF(L.GT.0)THEN
      COCU(K,L,NY,NX)=0.0
      CONU(K,L,NY,NX)=0.0
      COPU(K,L,NY,NX)=0.0
      COAU(K,L,NY,NX)=0.0
      ENDIF
1250  CONTINUE
      ZNHUI(L,NY,NX)=0.0
      ZNHU0(L,NY,NX)=0.0
      ZNFNG(L,NY,NX)=1.0
      ZNFNI(L,NY,NX)=0.0
      ZNFN0(L,NY,NX)=0.0
1200  CONTINUE
9890  CONTINUE
9895  CONTINUE
      RETURN
      END

