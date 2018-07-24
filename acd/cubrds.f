      BLOCK DATA CUBRDS
      IMPLICIT NONE
C----------
C ACD $Id$
C----------
C  DEFAULT PARAMETERS FOR THE CUBIC AND BOARD FOOT VOLUME EQUATIONS.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, EACH ROW HAS 7 COEFFS.
C----------
      DATA CFVEQS/ 756 * 0.0 /
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, EACH ROW HAS 7 COEFFS.
C----------
      DATA CFVEQL/ 756 * 0.0 /
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C  1 PER SPECIES.
C----------
      DATA ICTRAN/ 108 * 0 /
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL COEFFICIENTS
C  FOR LARGER SIZE TREES.  1 PER SPECIES.
C----------
      DATA CTRAN/ 108 * 0.0 /
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, 7 COEFFS PER ROW.
C----------
      DATA BFVEQS/ 756 * 0.0 /
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, 7 COEFFS PER ROW.
C----------
      DATA BFVEQL/ 756 * 0.0 /
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C  1 PER SPECIES.
C----------
      DATA IBTRAN/ 108 * 0 /
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL USE
C  COEFFICIENTS FOR LARGER SIZE TREES.  1 PER SPECIES.
C----------
      DATA BTRAN/ 108 * 0.0 /
      END
