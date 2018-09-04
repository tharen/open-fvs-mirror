      SUBROUTINE SMDGF(ISPC,H,CR,RD,SDIAM)
      IMPLICIT NONE
C----------
C EM $Id$
C----------
C  THIS SUBROUTINE COMPUTES THE DIAMETER FOR SMALL TREES.  PREDICTIONS
C  ARE BASED ON SPECIES, HEIGHT, CROWN RATIO, AND POINT CCF;
C  CALLED FROM REGENT.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
COMMONS
C----------
      REAL SDHTCR(MAXSP),SDHPCF(MAXSP),SDCR(MAXSP),SDHL4(MAXSP)
      REAL SDIAM,RD,CR,H,HLESS4,DLESS3
      INTEGER ISPC
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
C  SDHTCR COEFFICIENTS WERE SCALED FOR SPECIES 1, 2, 4, 5,
C  6,10, AND 11 TO MAINTAIN CONSISTENCY WITH **SMHTGF**;
C  CR IS SCALED 0-100 (WRW--3/26/91).
C----------
      DATA SDHTCR /
     & 0.000231,  0.000231, -0.28654,       0.0,       0.0,      0.0,
     & -0.41227,   0.04125, -0.15906,  0.000335,       0.0,      0.0,
     &      0.0,       0.0,      0.0,       0.0,       0.0, 0.000231,
     &      0.0/
      DATA SDHPCF /
     & -0.00005,  -0.00005,  0.13469,       0.0,       0.0,      0.0,
     &  0.16944,   0.17486,  0.15323,  -0.00020,       0.0,      0.0,
     &      0.0,       0.0,      0.0,       0.0,       0.0, -0.00005,
     &      0.0/
C----------
C  CROWN RATIO COEFFICIENTS WERE SCALED TO MAINTAIN CONSISTENCY
C  WITH **SMHTGF**; CR IS SCALED 0-100 (WRW--3/26/91).
C----------
      DATA SDCR /
     & 0.001711,  0.001711, 0.002736,  0.001711,  0.001711, 0.003191,
     & 0.003191, -0.002371, 0.000000,  0.002621,       0.0,      0.0,
     &      0.0,       0.0,      0.0,       0.0,       0.0, 0.001711,
     &      0.0/
      DATA SDHL4 /
     &  0.17023,   0.17023,  0.00036,   0.17023,   0.17023, -0.00220,
     & -0.00220,  -0.00070,  0.00000,   0.15622,       0.0,      0.0,
     &      0.0,       0.0,      0.0,       0.0,       0.0,  0.17023,
     &      0.0/
C----------
C
C FOR DF,LP,ES,AF USE ALTERNATE DIAMETER MODEL.
C SDHTCR USED FOR CONSTANT COEFFICIENT
C SDHPCF USED FOR HEIGHT COEFFICIENT
C SDCR USED FOR CROWN RATIO COEFFICIENT
C SDHL4 USED FOR RELATIVE DENSITY COEFFICIENT (I.E. PCCF)
C
      IF(ISPC.EQ.3 .OR. ISPC.EQ.7 .OR. ISPC.EQ.8
     & .OR. ISPC.EQ.9)THEN
        SDIAM = SDHTCR(ISPC) + SDHPCF(ISPC)*H + SDCR(ISPC)*CR
     &  + SDHL4(ISPC)*RD
      ELSE
        HLESS4 = H - 4.5
        DLESS3 = SDHTCR(ISPC)*HLESS4*CR
     &   + SDHPCF(ISPC) * HLESS4 * RD
     &   + SDCR(ISPC) * CR
     &   + SDHL4(ISPC) * HLESS4
        SDIAM = DLESS3 + 0.3
      ENDIF
      RETURN
      END
