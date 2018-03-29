      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,
     &                  HTMAX2,DEBUG)
      IMPLICIT NONE
C----------
C TT $Id: findag.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  THIS ROUTINE SET EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  SUCH AS TREE HEIGHT.
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C  CALLED FROM **REGENT
C  CALLED FORM **SMHTGF
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,ICLS
      REAL BAUTBA,SITE,EFFAGE
      REAL D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,HTMAX2
      REAL AG,DIFF,HGUESS,SINDX,TOLER
      REAL AGMAX(MAXSP),HTMAX(MAXSP)
      REAL DANUW
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C----------
C  DATA STATEMENTS
C----------
      DATA AGMAX/
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
     &   0.,   0., 100.,   0.,   0.,  50.,   0.,   0./
C
      DATA HTMAX/
     &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
     &   0.,   0., 100.,   0.,   0.,  20.,   0.,   0./
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = HTMAX2
C----------
C  PRINT DEBUG INFORMATION
C----------
      IF(DEBUG)WRITE(JOSTND,*)' ENTERING FINDAG I,ISPC,D1,D2,H= ',
     & I,ISPC,D1,D2,H
C----------
C  INITIALIZATIONS
C----------
      AGMAX1 = AGMAX(ISPC)
      HTMAX1 = HTMAX(ISPC)
      AGERNG = 1000.
C
      SELECT CASE (ISPC)       
C
C
C---------
C  COMPUTE AGE FOR ASPEN.
C  EQUATIONS FORMULATED BY
C  WAYNE SHEPPERD, ROCKY MTN FOREST EXP STATION, FT COLLINS, CO.
C----------
      CASE(6,14)
        SITAGE = (H*2.54*12.0/26.9825)**(1.0/1.1752)
        SITHT = H
C
C
C----------
C  SPECIES USING SURROGATE EQUATIONS FROM CR VARIANT
C  VIA UT VARIANT FOR TT
C  15 (NC), 18 (OH)
C----------
      CASE(15,18)
        ICLS = IFIX(D1+1.0)
        IF(ICLS .GT. 41) ICLS = 41
        BAUTBA = BAU(ICLS)/BA
        IF(BAUTBA.LT.0.0)BAUTBA=0.0
        SITE = SITEAR(ISPC)
        CALL FNDAG(EFFAGE,SITE,H,BAUTBA,DEBUG)
        IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG EFFAGE,SITE,H,',
     &  'BAUTBA= ',EFFAGE,SITE,H,BAUTBA
        SITAGE = EFFAGE
        IF(SITAGE .LE. 0.0) SITAGE=1.0
C
C
C----------
C  MC AND BI USE LOGIC FROM THE SO VARIANT
C----------
      CASE(13,16)
        TOLER=2.0
        SINDX = SITEAR(ISPC)
C----------
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMMING TREES HAVING H>=HMAX IS CALCULATED BY
C  ASSUMEING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HMAX.
C  TREES REACHING HMAX DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
        IF(H .GE. HTMAX1) THEN
          SITAGE = AGMAX1 + (H - HTMAX1)/0.10
          SITHT = H
          IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,AGEMAX,H,HTMAX1= ',I,ISPC,
     $    AGMAX1,H,HTMAX1
          GO TO 29
        ENDIF
C
        AG=2.0
C
   75   CONTINUE
        HGUESS = (SINDX - 4.5) / ( 0.6192 - 5.3394/(SINDX - 4.5)
     &   + 240.29 * AG**(-1.4) +(3368.9/(SINDX - 4.5))*AG**(-1.4))
        HGUESS = HGUESS + 4.5
        IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AG,HGUESS,H
91200   FORMAT(' FINDAG,I,ISPC,AGE,HGUESS,H ',2I5,3F10.2)
C
        DIFF=ABS(HGUESS-H)
        IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
          SITAGE = AG
          SITHT = HGUESS
C
C        IF(DEBUG)WRITE(JOSTND,91201)I,AG,HGUESS,H
C91201    FORMAT(' FOUND AN AGE--I,AGE,HGUESS,H ',I5,3F10.2)
C
          GO TO 29
        END IF
        AG = AG + 2.
C
        IF(AG .GT. AGMAX1) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
          SITAGE = AGMAX1
          SITHT = H
          GO TO 29
        ELSE
          GO TO 75
        ENDIF
C----------
C  REMAINING SPECIES FOR WHICH AGE DOESN'T MATTER.
C----------
      CASE DEFAULT
        SITAGE = 0.
        SITHT = H 
C        
      END SELECT
C----------
C   END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   29 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG I,ISPC,H,SITAGE,SITHT =
     & ',I,ISPC,H,SITAGE,SITHT
C
      IF(DEBUG)WRITE(JOSTND,50)
   50 FORMAT(' LEAVING SUBROUTINE FINDAG')
C
      RETURN
      END
C**END OF CODE SEGMENT