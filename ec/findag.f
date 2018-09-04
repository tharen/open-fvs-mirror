      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,
     &                  HTMAX2,DEBUG)
      IMPLICIT NONE
C----------
C EC $Id$
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C
C  SITAGE  --  LOADED WITH EFECTIVE AGE BASED ON CURRENT H
C  SITHT   --  LOADED WITH POTENTIAL HEIGHT CORRESPONDING TO
C              AGE IN SITAGE ARRAY
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PLOT.F77'
C
COMMONS
C----------
C  LOCAL VARIABLE DEFINITIONS:
C----------
C  INCRNG = HAS A VALUE OF 1 WHEN THE SITE CURVE HAS BEEN MONOTONICALLY
C           INCREASING IN PREVIOUS ITERATIONS.
C   OLDHG = HEIGHT GUESS FROM PREVIOUS ITERATION.
C----------
C  DECLARATIONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,INCRNG
      REAL AGMAX(MAXSP),AHMAX(MAXSP),BHMAX(MAXSP),AGMAX1,HTMAX1,HTMAX2
      REAL AG,DIFF,H,HGUESS,SINDX,TOLER,SITAGE,SITHT,D1,D2,OLDHG
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
C  DATA STATEMENTS
C----------
      DATA AGMAX/
     &  200.,  110.,  180.,  130.,  250.,
     &  130.,  140.,  150.,  150.,  200.,
     &  200.,  180.,  200.,  200.,  200.,
     &  130.,  200.,  200.,  200.,  200.,
     &  200.,  200.,  200.,  200.,  200.,
     &  200.,  200.,  200.,  200.,  200.,
     &  180.,  200./
C
      DATA AHMAX/
     &        2.3,      12.86,      -2.86,      21.29,      52.27,
     &      21.29,        2.3,        20.,      45.27,      -5.00,
     &  4.0156013,      -2.06,  3.2412923,  3.2412923,  4.3149844,
     &      21.29,  3.2412923,  3.2412923,  3.2412923,  3.9033821,
     &  3.9033821,  3.9033821,  3.9033821,  3.9033821,  3.9033821,
     &  3.9033821,  3.9033821,  3.9033821,  3.9033821,  3.9033821,
     &      -2.06,  3.9033821/
C
      DATA BHMAX/
     &       2.39,       1.32,       1.54,       1.24,       1.14,
     &       1.24,       1.75,        1.1,       1.24,       1.30,
     & 51.9732476,       1.54, 62.7139427, 62.7139427, 39.6317079,
     &       1.24, 62.7139427, 62.7139427, 62.7139427, 59.3370816,
     & 59.3370816, 59.3370816, 59.3370816, 59.3370816, 59.3370816,
     & 59.3370816, 59.3370816, 59.3370816, 59.3370816, 59.3370816,
     &       1.54, 59.3370816/
C----------
C  INITIALIZATIONS
C----------
      TOLER=2.0
      SINDX = SITEAR(ISPC)
      AGMAX1 = AGMAX(ISPC)
      HTMAX1 = 0.0
      HTMAX2 = 0.0
C
      SELECT CASE (ISPC)
C----------
C  SPECIES USING EC LOGIC
C----------
      CASE(1:10,16)
        AG = 0.5
C----------
C THE FOLLOWING LINES ARE AN RJ FIX 7-28-88
C----------
        IF(ISPC .EQ. 10) AG=(98.38*EXP(SINDX*(-0.0422)))+1.0
        IF(AG .LT. 0.5)AG = 0.5
        IF(ISPC .EQ. 3)AG=18.0
C
        HTMAX1 = AHMAX(ISPC) + BHMAX(ISPC)*SINDX
      CASE(12,31)
        AG=0.5
        HTMAX1 = AHMAX(ISPC) + BHMAX(ISPC)*SINDX*3.281
C----------
C  SPECIES USING WC LOGIC
C----------
      CASE(11,13:15,17:30,32)
        AG=2.0
        HTMAX1=AHMAX(ISPC)*D1 + BHMAX(ISPC)
        HTMAX2=AHMAX(ISPC)*D2 + BHMAX(ISPC)
      END SELECT
C----------
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMING TREES HAVING H>=HMAX IS CALCULATED BY
C  ASSUMEING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HMAX.
C  TREES REACHING HMAX DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
      IF(H .GE. HTMAX1) THEN
        SITAGE = AGMAX1 + (H - HTMAX1)/0.10
        SITHT = H
        IF(DEBUG)WRITE(JOSTND,*)' ISPC,H,HTMAX1,AGMAX1,SITAGE,SITHT= ',
     &  ISPC,H,HTMAX1,AGMAX1,SITAGE,SITHT
        GO TO 30
      ENDIF
C
      INCRNG = 0
      HGUESS = 0.
   75 CONTINUE
      OLDHG = HGUESS
C----------
C  CALL HTCALC TO CALCULATE POTENTIAL HT GROWTH
C----------
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG, CALLING HTCALC'
      CALL HTCALC(SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AG,HGUESS,H
91200 FORMAT(' FINDAG I,ISPC,AG,HGUESS,H ',2I5,3F10.2)
C----------
C  AVOID NEGATIVE PREDICTED HEIGHTS AT SMALL AGES FROM SOME SI CURVES
C  GED 4/20/18
C----------
      IF(HGUESS .LT. 1.)GO TO 175
C
      DIFF=ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        IF(DEBUG)THEN
          WRITE(JOSTND, *)' DIFF,TOLER,H,HGUESS,AG,SITAGE,SITHT= ',
     &    DIFF,TOLER,H,HGUESS,AG,SITAGE,SITHT
        ENDIF
        GO TO 30
      END IF
C----------
C  SOME SITE CURVES DECREASE AT THE START BEFORE INCREASING. IF DECREASING,
C  KEEP GOING; IF SITE CURVE WAS INCREASING, BUT NOW HAS FLATTENED OFF, STOP 
C  THE ITERATION GED 04/19/18
C----------
      DIFF = (HGUESS-OLDHG)
      IF(OLDHG.NE.0.0 .AND. DIFF.GE.0.05) INCRNG=1
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG OLDHG,DIFF,INCRNG= ',
     &OLDHG,DIFF,INCRNG 
      IF(INCRNG.EQ.1 .AND. DIFF .LT. 0.05)THEN
        SITAGE = AG
        SITHT = HGUESS
        IF(DEBUG)THEN
          WRITE(JOSTND, *)' SITE CURVE FLAT OLDHG,AG,HGUESS,SITAGE,',
     &    'SITHT= ',OLDHG,AG,HGUESS,SITAGE,SITHT
        ENDIF
        GO TO 30
      END IF
C
  175 CONTINUE
      AG = AG + 2.
C
      IF(AG .GT. AGMAX1) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX1
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT,AGMAX1,HTMAX1
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT,AGMAX1,',
     &'HTMAX1 = ',I5,4F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT