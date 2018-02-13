      SUBROUTINE REGENT(LESTB,ITRNIN)
      IMPLICIT NONE
C----------
C  **REGENT--EC   DATE OF LAST REVISION:  05/09/12
C----------
C  THIS SUBROUTINE COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES
C  THAT ARE LESS THAN 10 INCHES DBH (5 INCHES FOR LODGEPOLE PINE),
C  AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 3 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 2 INCHES
C  DBH (1 INCH FOR LODGEPOLE PINE), HEIGHT INCREMENT PREDICTIONS
C  ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C  HEIGHT INCREMENT IS A FUNCTION OF SITE HEIGHT, CALCULATED
C  IN **SMHTGF**, AND MODIFIED BY VIGOR AND DENSITY FUNCTIONS
C  OF CCF, TOP HEIGHT AND CROWN RATIO. DIAMETER IS ASSIGNED FROM
C  A HEIGHT-DIAMETER FUNCTION WITH ADJUSTMENTS FOR RELATIVE SIZE
C  AND STAND DENSITY.  INCREMENT IS COMPUTED BY SUBTRACTION.
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **TREGRO** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.  ZERO FOR ALL
C             SPECIES IN THIS VARIANT
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      CHARACTER SPEC*2
      INTEGER NUMCAL(MAXSP)
      INTEGER IREFI,ISPEC,KOUT,KK,MODE1
      INTEGER ITRNIN,ISPC,I1,I2,I3,I,IPCCF,K,L,N
      REAL H,BARK,VIGOR,TEMT,POTHTG,HTGR,ZZRAN,X1,XPPMLT,XWT,DAT45
      REAL CON,XMX,XMN,SI,DGMX,D,CR,RAN,BACHLO,BRATIO,HK,DK,DKK
      REAL BX,AX,DDS,HTNEW,SCALE3,CORNEW,SNP,SNX,SNY,EDH,P,TERM
      REAL REGYR,FNT,SCALE,SCALE2,CCF,AVHT,X,PCTRED,XRHGRO,XRDGRO
      REAL CORTEM(MAXSP)
      REAL XMAX(MAXSP),XMIN(MAXSP)
      REAL SLO(MAXSP),SHI(MAXSP),AB(9),DGMAX(MAXSP),DIAM(MAXSP)
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
C  DATA STATEMENTS.
C----------
      DATA DGMAX/
     & 2.8, 2.8, 2.4, 3.6, 2.5, 2.5, 3.5, 3.6, 3.6, 2.8,
     & 5.0, 2.8, 5.0, 5.0, 5.0, 2.5, 5.0, 5.0, 5.0, 5.0,
     & 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
     & 2.8, 5.0/
C
      DATA XMAX/
     & 4.0, 4.0, 4.0, 4.0,10.0, 4.0, 5.0, 4.0, 6.0, 6.0,
     & 4.0, 6.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
     & 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
     & 6.0, 4.0/
C
      DATA XMIN/
     & 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 2.0, 2.0, 2.0,
     & 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
     & 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
     & 2.0, 2.0/
C
      DATA SLO/
     &  20.,  50.,  50.,  50.,  15.,  50.,  30.,  40.,  50.,  70.,
     &   0.,  15.,   0.,   0.,   0.,  50.,   0.,   0.,   0.,   0.,
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
     &  15.,   0./
C
      DATA SHI/
     &  80., 110., 110., 110.,  30., 110.,  70., 120., 150., 140.,
     & 999.,  30., 999., 999., 999., 110., 999., 999., 999., 999.,
     & 999., 999., 999., 999., 999., 999., 999., 999., 999., 999.,
     &  30., 999./
C
      DATA DIAM/
     & 0.4, 0.3, 0.3, 0.3, 0.2, 0.3, 0.4, 0.3, 0.3, 0.5,
     & 0.2, 0.2, 0.2, 0.4, 0.3, 0.3, 0.3, 0.2, 0.2, 0.2,
     & 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2,
     & 0.2, 0.2/
C
      DATA AB/
     & 1.11436,-.011493,.43012E-4,-.72221E-7,.5607E-10,-.1641E-13,3*0./
C
      DATA REGYR/10.0/
C-----------
C  CHECK FOR DEBUG.
C-----------
      LSKIPH=.FALSE.
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,9980)ICYC
 9980 FORMAT('ENTERING SUBROUTINE REGENT  CYCLE =',I5)
C----------
C  IF THIS IS THE FIRST CALL TO REGENT, BRANCH TO STATEMENT 40 FOR
C  MODEL CALIBRATION.
C----------
      IF(LSTART) GOTO 40
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      IF (ITRN.LE.0) GO TO 91
C----------
C  HEIGHT INCREMENT IS DERIVED FROM A HEIGHT-AGE CURVE AND IS NOMINALLY
C  BASED ON A 10-YEAR GROWTH PERIOD.  THE VARIABLE SCALE IS USED TO CONVERT
C  HEIGHT INCREMENT PREDICTIONS TO A FINT-YEAR PERIOD.  DIAMETER
C  INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT, AND IS SCALED TO A 10-
C  YEAR PERIOD BY APPLICATION OF THE VARIABLE SCALE2.  DIAMETER INCREMENT
C  IS CONVERTED TO A FINT-YEAR BASIS IN **UPDATE**.
C----------
      FNT=FINT
      IF(LESTB) THEN
        IF(FINT.LE.5.0) THEN
          LSKIPH=.TRUE.
        ELSE
          FNT=FNT-5.0
        ENDIF
      ENDIF
      SCALE=FNT/REGYR
      SCALE2=YR/FNT
C----------
C  IF CALLED FROM **ESTAB** INTERPOLATE MID-PERIOD CCF AND TOP HT
C  FROM VALUES AT START AND END OF PERIOD.
C----------
      CCF=RELDEN
      AVHT=AVH
      IF(LESTB.AND.FNT.GT.0.0) THEN
        CCF=(5.0/FINT)*RELDEN +((FINT-5.0)/FINT)*ATCCF
        AVHT=(5.0/FINT)*AVH +((FINT-5.0)/FINT)*ATAVH
      ENDIF
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C---------
      X=AVHT*(CCF/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01) PCTRED = 0.01
      IF(DEBUG) WRITE(JOSTND,9982) AVHT,CCF,X,PCTRED
 9982 FORMAT('IN REGENT AVHT,CCF,X,PCTRED = ',4F10.4)
C----------
C  ENTER GROWTH PREDICTION LOOP.  PROCESS EACH SPECIES AS A GROUP;
C  LOAD CONSTANTS FOR NEXT SPECIES.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)
      XRDGRO=XRDMLT(ISPC)
      CON=RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      SI=SITEAR(ISISP)
      IF(SI .GT. SHI(ISISP)) SI=SHI(ISISP)
      IF(SI .LE. SLO(ISISP)) SI=SLO(ISISP) + 0.5
C----------
C     PUT A CEILING ON DIAMETER GROWTH BASED ON OLIVER AND COCHRAN EMPR.
C     RJ 11/28/88
C----------
      DGMX = DGMAX(ISPC) * SCALE
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
C----------
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  ASSIGN CROWN RATIO FOR NEWLY ESTABLISHED TREES.
C----------
        IPCCF=ITRE(I)
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
    1   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 1
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=(CR*100.0)+0.5
      ENDIF
      K=I
      L=0
C---------
C COMPUTE VIGOR MODIFIER FROM CROWN RATIO.
C---------
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)
      IF(LSKIPH) THEN
        HTG(K)=0.0
        GO TO 4
      ENDIF
      X=FLOAT(ICR(I))/100.
      VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
      IF(VIGOR .GT. 1.0)VIGOR=1.0
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
C----------
C  CALL SMHTGF, THE SMALL TREE HEIGHT GROWTH ROUTINE.  SMHTGF IS ALSO
C  CALLED FROM ESSUBH TO GROW PLANTED AND NATURAL TREES FROM
C  ESTABLISHMENT TO 5 YEARS INTO THE CYCLE.
C----------
      IF(DEBUG) WRITE(JOSTND,*)'ABIRTH(I)= ',ABIRTH(I)
      TEMT=10.
      MODE1= 1
      CALL SMHTGF(MODE1,ICYC,ISPC,H,TEMT,POTHTG,JOSTND,DEBUG)
C
      HTGR=POTHTG*PCTRED*VIGOR*CON
      IF(DEBUG) WRITE(JOSTND,9983) X,VIGOR,HTGR,CON
 9983 FORMAT('IN REGENT X,VIGOR,HTGR,CON = ',4F10.4)
    3 CONTINUE
      ZZRAN = 0.0
      IF(DGSD.GE.1.0) ZZRAN=BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 0.5) .OR. (ZZRAN .LT. -2.0)) GO TO 3
      IF(DEBUG)WRITE(JOSTND,9984) HTGR,ZZRAN,XRHGRO,SCALE,WK4(I)
 9984 FORMAT('IN REGENT 9984 FORMAT',5(F10.4,2X))
C
C  NOTE: WK4 IS A CLIMATE MODIFIER CALCULATED IN **CLGMULT**
C
      SELECT CASE (ISPC)
      CASE(1:10,12,16,31)
        HTGR = (HTGR +ZZRAN*0.1)*XRHGRO * SCALE
        IF(HTGR .LT. 0.0) HTGR = 0.0
      CASE(11,13:15,17:30,32)
        HTGR = (HTGR +ZZRAN*0.1)*XRHGRO * SCALE * WK4(I)
        IF(HTGR .LT. 0.1) HTGR = 0.1
      END SELECT
C
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C
      X1=0.
      XPPMLT=0.
      CALL PPREGT (XPPMLT,X1,X1,X1,X1)
C
      HTGR = HTGR + XPPMLT
C-------------
C     COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C     ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN, THE LARGE TREE
C     PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=(D-XMN)/(XMX-XMN)
      IF(D.LE.XMN .OR. LESTB) XWT = 0.0
C----------
C     COMPUTE WEIGHTED HEIGHT INCREMENT FOR NEXT TRIPLE.
C----------
      IF(DEBUG)WRITE(JOSTND,9985)XWT,HTGR,HTG(K),I,K
 9985 FORMAT('IN REGENT 9985 FORMAT',3(F10.4,2X),2I7)
      HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      IF(HTG(K) .LT. .1) HTG(K) = .1
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
    4 CONTINUE
C----------
C     ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C     THAN 3 INCHES (COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C     PROJECTION PERIOD LENGTH).
C----------
      IF(D.GE.3.0) GO TO 23
      HK=H + HTG(K)
      IF(HK .LE. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
C----------
C   BEGIN THE DIAMETER LOOKUP SECTION
C      DKK = DIAMETER AT THE START OF THE PROJECTION
C      DK  = DIAMETER WITH HTG ADDED TO THE STARTING HEIGHT
C   DAT45  = DIAMETER AT 4.5 FEET PREDICTED FROM EQUATION.
C----------
C
        DAT45 = 0.
        DK = 0.
        DKK = 0.
        SELECT CASE (ISPC)
C
C  SPECIES USING WC LOGIC
C
        CASE(11,13:15,17:30,32)
C
          SELECT CASE (ISPC)
C
          CASE(11)
            DAT45 = -0.674 + 1.522*ALOG(4.5)
            DKK = -0.674 + 1.522*ALOG(H)
            DK = -0.674 + 1.522*ALOG(HK)
C
          CASE(13:15,17)
            DAT45 = -2.089 + 1.980*ALOG(4.5)
            DKK = -2.089 + 1.980*ALOG(H)
            DK = -2.089 + 1.980*ALOG(HK)
C
          CASE(18,19)
            DAT45 = -0.532 + 1.531*ALOG(4.5)
            DKK = -0.532 + 1.531*ALOG(H)
            DK = -0.532 + 1.531*ALOG(HK)
C
          CASE(20:30,32)
            DAT45 = 3.102 + 0.021*4.5
            DKK = 3.102 + 0.021*H
            DK = 3.102 + 0.021*HK
C
          END SELECT
C
          IF(DKK .LT. 0.0) DK=D
          IF(DK .LT. DK) DKK=DK+.01
          IF(DEBUG)WRITE(JOSTND,*)'I,ISPC,DBH,H,HK,DKK,DK= ',
     &    I,ISPC,DBH(I),H,HK,DKK,DK
C
C  PONDEROSA PINE (EC LOGIC)
C
        CASE(10)
          DK=(HK-8.31485+.59200*7.)/3.03659
          DKK=(H-8.31485+.59200*7.)/3.03659
          IF(H .LT. 4.5) DKK=D
C
C  OTHER SPECIES USING EC LOGIC (1-9,12,16,31)
C
        CASE DEFAULT
          BX=HT2(ISPC)
          IF(IABFLG(ISPC).EQ.1) THEN
            AX=HT1(ISPC)
          ELSE
            AX=AA(ISPC)
          ENDIF
          DK=(BX/(ALOG(HK-4.5)-AX))-1.0
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            DKK=(BX/(ALOG(H-4.5)-AX))-1.0
          ENDIF
          IF(DEBUG)WRITE(JOSTND,9986) AX,BX,ISPC,HK,BARK,
     &                                XRDGRO,DK,DKK
 9986     FORMAT('IN REGENT 9986 FORMAT AX,BX,ISPC,HK',
     &    ' BARK,XRDGRO,DK,DKK= '/T12, F10.3,2X,F10.3,2X,I5,2X,5F10.3)
C
        END SELECT
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
        IF(.NOT.LHTDRG(ISPC) .OR. 
     &     (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
          CALL HTDBH(IFOR,ISPC,DK,HK,1)
          IF(H .LE. 4.5) THEN
            DKK=D
        ELSE
          CALL HTDBH(IFOR,ISPC,DKK,H,1)
        ENDIF
        IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING I,IFOR,ISPC,H,HK,DK,'
     &  ,'DKK= ',I,IFOR,ISPC,H,HK,DK,DKK
          IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &    ISPC,LHTDRG(ISPC),IABFLG(ISPC)
        ENDIF
C----------
C         IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
C----------
C         ADJUST REGRESSION TO PASS THROUGH BUD WIDTH AT 4.5 FEET.
C----------
          IF(DAT45.GT.0.0 .AND. HK.GE.4.5 .AND. LHTDRG(ISPC) .AND.
     &       IABFLG(ISPC).EQ.0) THEN
            DBH(K)=DK - DAT45 + DIAM(ISPC)
          ELSE
            DBH(K)=DK
          ENDIF
          IF(DBH(K).LT.DIAM(ISPC) .OR. HK.LT.4.5) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K)+0.001*HK
          DG(K)=DBH(K)
        ELSE
C----------
C         COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C         SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C         IS WITHIN BOUNDS.
C----------
          IF(DEBUG)WRITE(JOSTND,*)'BARK,XRDGRO= ',BARK,XRDGRO
          IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
            DG(K)=HTG(K)*0.2*BARK*XRDGRO
            DK=D+DG(K)
          ELSE
            DG(K)=(DK-DKK)*BARK*XRDGRO
          ENDIF
C----------
C PROBLEM WITH HARDWOOD EQN, REDUCES TO .021*HG. SET TO RULE
C OF THUMB VALUE .1*HG FOR NOW. DIXON 11-04-92
C DON'T USE R.O.T. IF USING INVENTORY EQNS.  DIXON 03-31-98
C----------
          SELECT CASE (ISPC)
          CASE(20:30,32)
            IF(LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.0)
     &       DG(K)=0.1*HTG(K)*XRDGRO
          END SELECT
C
          IF(DG(K) .LT. 0.0) DG(K)=0.0
          IF (DG(K) .GT. DGMX) DG(K)=DGMX
          IF(DEBUG)WRITE(JOSTND,*)'K,DKK,DK,DG,DGMX= ',
     &    K,DKK,DK,DG(K),DGMX
C----------
C         SCALE DIAMETER INCREMENT TO 10-YR ESTIMATE.
C         SCALE ADJUSTMENT IS ON GROWTH IN DDS RATHER THAN INCHES
C         OF DG TO BE CONSISTENT WITH GRADD.
C----------
          DDS=DG(K)*(2.0*BARK*D+DG(K))*SCALE2
          DG(K)=SQRT((D*BARK)**2.0+DDS)-BARK*D
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
      IF(DEBUG)THEN
      HTNEW=HT(I)+HTG(I)
      WRITE(JOSTND,9987) I,ISPC,HT(I),HTG(I),HTNEW,DBH(I),DG(I)
 9987 FORMAT('IN REGENT, I=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC=',F7.4)
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
   23 CONTINUE
C----------
C  RETURN TO PROCESS NEXT TRIPLE IF TRIPLING.  OTHERWISE,
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TREE.
C----------
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 22
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 2
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   22 CONTINUE
   25 CONTINUE
   30 CONTINUE
      GO TO 91
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) GO TO 91
      IF(IFINTH .EQ. 0)  GOTO 95
      SCALE3 = REGYR / FINTH
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C---------
      X=AVH*(RELDEN/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01)PCTRED = 0.01
      IF(DEBUG)WRITE(JOSTND,9989)AVH,RELDEN,X,PCTRED
 9989 FORMAT('IN REGENT AVH,RELDEN,X,PCTRED = ',4F10.4)
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 100 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 100
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      SI=SITEAR(ISISP)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
C----------
C  DIA GT 3 INCHES INCLUDED IN OVERALL MEAN
C----------
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
      IF(SI .GT. SHI(ISISP)) SI=SHI(ISISP)
      IF(SI .LE. SLO(ISISP)) SI=SLO(ISISP) + 0.5
C----------
C  COMPUTE VIGOR MODIFIER FROM CROWN RATIO.
C----------
      X=FLOAT(ICR(I))/100.
      VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
      IF(VIGOR .GT. 1.0)VIGOR=1.0
C
      MODE1= 1
      CALL SMHTGF(MODE1,ICYC,ISPC,H,REGYR,POTHTG,JOSTND,DEBUG)
C
      EDH=POTHTG*PCTRED*VIGOR*RHCON(ISPC)
      IF(EDH .LT. 0.1) EDH=0.1
      IF(DEBUG)WRITE(JOSTND,9990) X,VIGOR,EDH
 9990 FORMAT('IN REGENT X,VIGOR,EDH = ',3F10.4)
      P=PROB(I)
      IF(HTG(I).LT.0.001) GO TO 60
      TERM=HTG(I) * SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)WRITE(JOSTND,9991) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),ATCCF,RHCON(ISPC),EDH,TERM
 9991 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9992) ISPC,SNP,SNX,SNY
 9992 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';  SNX=',F10.2,';  SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE POPULATION AND FOR THE SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  CALCULATE RATIO ESTIMATOR.
C----------
      CORNEW = SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE 
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES 
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
  100 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9993) (NUMCAL(I),I=1,NUMSP)
 9993 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
   95 CONTINUE
      WRITE(JOSTND,9994) (CORTEM(I),I=1,NUMSP)
 9994 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
   91 IF(DEBUG)WRITE(JOSTND,9995)ICYC
 9995 FORMAT('LEAVING SUBROUTINE REGENT  CYCLE =',I5)
      RETURN
C
C
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC) = RCOR2(ISPC)
   90 CONTINUE
      RETURN
      END
