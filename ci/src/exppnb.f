      SUBROUTINE EXPPNB
      IMPLICIT NONE
C----------
C CI $Id: exppnb.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C     VARIANT DEPENDENT EXTERNAL REFERENCES FOR THE
C     PARALLEL PROCESSING EXTENSION
C
C----------
      REAL XPPDDS,BALO,CCFO,BAO,DBH,BCCF,BSBA,BDBL
      REAL XPPMLT,BRHT,BBAL
      REAL DANUW
C----------
C     CALLED TO COMPUTE THE DDS MODIFIER THAT ACCOUNTS FOR THE DENSITY
C     OF NEIGHBORING STANDS (CALLED FROM DGF).
C----------
      ENTRY PPDGF (XPPDDS,BALO,CCFO,BAO,DBH,BCCF,BSBA,BDBL)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = XPPDDS
      DANUW = BALO
      DANUW = CCFO
      DANUW = BAO
      DANUW = DBH
      DANUW = BCCF
      DANUW = BSBA
      DANUW = BDBL
C
      RETURN
C----------
C     CALLED TO COMPUTE THE REGENT MULTIPLIER THAT ACCOUNTS FOR
C     THE DENSITY OF NEIGHBORING STANDS (CALLED FROM REGENT).
C----------
      ENTRY PPREGT (XPPMLT,BAO,BALO,BRHT,BSBA,BBAL)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = XPPMLT
      DANUW = BAO
      DANUW = BALO
      DANUW = BRHT
      DANUW = BSBA
      DANUW = BBAL
C
      RETURN
C
      END
