      SUBROUTINE EXPPE
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C     ENTRY EXTERNAL REGERENCES FOR THE PARALLEL PROCESSING EXTENSION.
C----------
      LOGICAL L
      CHARACTER C*8,CISN*11
      INTEGER IA(*), JA(*)
      INTEGER I,J,I2,I3
      REAL R,X,R2,X1,X2
      REAL DANUW
      CHARACTER*8 CDANUW
C----------
C     CALLED BY INSCYC TO FIND OUT IF IS LEGAL TO INSERT A CYCLE AT
C     YEAR I
C
      ENTRY PPECYC (I,L)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
C
      L=.TRUE.
      RETURN
C
C     RETURNS L, TO INDECATE THAT PPE IS NOT PART OF THE PROGRAM.
C
      ENTRY PPEATV (L)
      L=.FALSE.
      RETURN
C
C     EVENT MONITOR/PPE INTERFACE. SIMPLY RETURNS.
C
      ENTRY PPEVMI (I,IA,JA,J)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
      DANUW = REAL(J)
      DANUW = REAL(IA(1))
      DANUW = REAL(JA(1))
C
      RETURN
C
C     LOAD THE EVENT MONITOR PPE VARIABLES.
C
      ENTRY PPLDEV
      RETURN
C
C     CALLED TO LOAD PPE VARIALBES FOR EXPRESSION EVALUATION.  RETURN
C     A CODE INDICATING THAT THE REQUESTED VARIABLE IS UNDEFINED.
C
      ENTRY PPLDX (R,I,I2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
      DANUW = R
C
      I2=1
      RETURN
C
C     CALLED TO FIND THE NUMBER OF USER-DEFINED VARIALBES.  PASS BACK
C     A CODE INDICATING THAT THE VARIABLE COULD NOT BE FOUND.
C
      ENTRY PPKEY (C,I,I2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
      CDANUW(1:8) = C(1:8)
C
      I2=1
      RETURN
C
C     CALLED BY TREGRO TO FIND OUT IF SOME PARTS OF TREGRO NEED TO
C     BE SKIPPED.
C
      ENTRY PPBRPH (I)
      I=0
      RETURN
C
C     NEEDED BY CVOUT AND OTHER ROUTINES TO WRITE THE CORRECT LABELS
C
      ENTRY PPLABS (J)
C
C     WRITE THE STAND POLICY LABEL...
C
      CALL LBSPLW (J)
      RETURN
C
C     RETURN THE CURRENT ISN.
C
      ENTRY PPISN (CISN)
      CISN='00000000000'
      RETURN
C
C     RETURN THE CURRENT STAND NUMBER.
C
      ENTRY PPISND (I)
      I=0
      RETURN
C
C     CALLED BY PRTRLS TO GET THE SAMPLING WEIGHT FOR THE TREELIST.
C
      ENTRY PPWEIG (I,X)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
C
      X=0.0
      RETURN
C
C     CALLED BY GROHED TO CLOSE THE OPTION OUTPUT TABLE, IF NEEDED.
C
      ENTRY PPCLOP (I)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
C
      RETURN
      ENTRY MSTRGT
      RETURN
      ENTRY MSTRPT
      RETURN
      ENTRY GPNEW (I,I2,I3,R,R2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(I)
      DANUW = REAL(I2)
      DANUW = REAL(I3)
      DANUW = R
      DANUW = R2
C
      RETURN
      ENTRY GPCLOS
      RETURN
C
C     CALLED TO MODIFIY THE POINT DENSITY STATISTICS FOR THE ESTAB
C     MODEL FOR MODELING EFFECTS OF NEIGHBORING DENSITY.
C     (CALLED FROM GRADD).
C
      ENTRY PPPDEN
C
C     CALLED BY THE FFE POTENTIAL FIRE PROGRAM TO STORE SOME DATA
C
      ENTRY FMPPHV_REPORT(X1,X2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = X1
      DANUW = X2
C
      RETURN
      END
