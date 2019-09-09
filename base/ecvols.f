      SUBROUTINE ECVOLS
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C  THIS SUBROUTINE IS CALLED TWICE PER CYCLE.
C  IT CALCULATES VALUES FOR THE CURRENT STAND AND ALSO
C  FOR REMOVALS WHEN THEY OCCUR.
C  ENTRY POINTS FOR OTHER ECONOMIC ANALYSIS RELATED SUBROUTINES
C  ARE ALSO CONTAINED WITHIN THIS SUBROUTINE.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'ECON.F77'
C
C
COMMONS
C
      REAL P,D
      INTEGER I,ICLASS,IOAGE,IYEAR,II,ISPC,J,K,IDBH
      CHARACTER REV*10
      LOGICAL LREMOV,LACTV,LLAST
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES.
C----------
      INTEGER*4 ICVOLT,ICVOLC,ICVOLB,ICTREE,ICBA
      REAL CVOLT(MAXSP),CVOLC(MAXSP),CVOLB(MAXSP),CTREE(MAXSP),
     &          CBA(MAXSP)
C
      LLAST=.FALSE.
      LREMOV=.FALSE.
C
   10 CONTINUE
      DO 100 I=1,MAXSP
         CVOLT(I)=0.0
         CVOLC(I)=0.0
         CVOLB(I)=0.0
         CTREE(I)=0.0
         CBA(I)=0.0
  100 CONTINUE
      ICLASS=0
      IOAGE=IAGE+IY(ICYC)-IY(1)
      IYEAR=IY(ICYC)
      IF (ITRN .LE. 0 ) GO TO 550
      DO 500 II=1,ITRN
         I=IND(II)
         P=PROB(I)
         IF (LREMOV) P=WK3(I)
         IF( P .LT. 0.0 ) P=0.0
         D=DBH(I)
         IDBH=INT(DBH(I))
         ISPC=ISP(I)
         IF (II .EQ. 1) GOTO 400
         IF (IDBH .EQ. ICLASS) GO TO 400
         IF (LECBUG)WRITE(JOSTND,8000) JOSUME,LECON,ICLASS,LREMOV,
     >      (CVOLT(J),CVOLC(J),CVOLB(J),CTREE(J),CBA(J),J=1,MAXSP)
 8000 FORMAT(' IN **ECVOLS** ',
     >       '  JOSUME=',I3,' LECON=',L1,' ICLASS=',I3,' LREMOV=',L1/
     >        ((1X,F6.1,2X,F6.1,2X,F6.1,2X,F8.2,2X,F6.2/)))
C----------
C   ROUND VALUES AND OUTPUT FOR CURRENT DBH CLASS
C----------
         DO 300 K=1,MAXSP
            IF ( CTREE(K) .LE. 0.0) GO TO 200
            ICVOLT=INT((CVOLT(K)/GROSPC)*10.0 + 0.5)
            ICVOLC=INT((CVOLC(K)/GROSPC)*10.0 + 0.5)
            ICVOLB=INT((CVOLB(K)/GROSPC)*10.0 + 0.5)
            ICTREE=INT((CTREE(K)/GROSPC)*100.0 + 0.5)
            ICBA=INT((CBA(K)/GROSPC)*100.0 + 0.5)
      IF (LREMOV) THEN
            WRITE(JOSUME,8002)IYEAR,K,ICLASS,ICVOLT,ICVOLC,
     >               ICVOLB,ICTREE,ICBA,IOAGE,NPLT,MGMID
      ELSE 
            WRITE(JOSUME,8001)IYEAR,K,ICLASS,ICVOLT,ICVOLC,ICVOLB,
     >           ICTREE,ICBA,IOAGE,NPLT,MGMID
      ENDIF
 8001 FORMAT(I4,1X,I3,2X,I3,2X,I5,2X,I5,2X,I6,2X,I7,2X,I5,2X,'1',2X,I6,
     >       ' 1 ',A26,1X,A4,:,T81,A)
 8002 FORMAT(I4,1X,I3,2X,I3,2X,I5,2X,I5,2X,I6,2X,I7,2X,I5,2X,'2',2X,I6,
     >       ' 1 ',A26,1X,A4,:,T81,A)
  200       CONTINUE
            CVOLT(K)=0.0
            CVOLC(K)=0.0
            CVOLB(K)=0.0
            CTREE(K)=0.0
            CBA(K)=0.0
  300    CONTINUE
C----------
C   SUM WITHIN DBH CLASS
C----------
  400    CONTINUE
         ICLASS=IDBH
         IF (P .LE. 0.0) GOTO 500
         CVOLT(ISPC)=CVOLT(ISPC)+CFV(I)*P
         CVOLC(ISPC)=CVOLC(ISPC)+WK1(I)*P
         CVOLB(ISPC)=CVOLB(ISPC)+BFV(I)*P
         CTREE(ISPC)=CTREE(ISPC)+P
         CBA(ISPC)=CBA(ISPC)+ P*D*D*.005454
  500 CONTINUE
         IF (LECBUG) WRITE(JOSTND,8000) JOSUME,LECON,ICLASS,LREMOV,
     >      (CVOLT(J),CVOLC(J),CVOLB(J),CTREE(J),CBA(J),J=1,MAXSP)
C----------
C   ROUND AND OUTPUT LAST DBH CLASS
C----------
  550    CONTINUE
         DO 600 K=1,MAXSP
            IF ( CTREE(K) .LE. 0.0  .AND.  K .LT. MAXSP ) GO TO 600
            IF ( CTREE(K) .LE. 0.0  .AND.  ITRN .GT. 0 ) GO TO 600
            ICVOLT=IFIX((CVOLT(K)/GROSPC)*10.0 + 0.5 )
            ICVOLC=IFIX((CVOLC(K)/GROSPC)*10.0 + 0.5 )
            ICVOLB=IFIX((CVOLB(K)/GROSPC)*10.0 + 0.5 )
            ICTREE=IFIX((CTREE(K)/GROSPC)*100.0 + 0.5 )
            ICBA=IFIX((CBA(K)/GROSPC)*100.0 + 0.5 )
      IF (LREMOV) THEN
            WRITE(JOSUME,8002)IYEAR,K,ICLASS,ICVOLT,ICVOLC,
     >               ICVOLB,ICTREE,ICBA,IOAGE,NPLT,MGMID
      ELSE              
            WRITE(JOSUME,8001)IYEAR,K,ICLASS,ICVOLT,ICVOLC,ICVOLB,
     >            ICTREE,ICBA,IOAGE,NPLT,MGMID
      ENDIF
  600    CONTINUE
C----------
C   OUTPUT FLAG FOR END OF STAND SUMMARY DATA
C----------
      IF( LLAST ) WRITE(JOSUME,8003)
 8003 FORMAT('-999')
      RETURN
      ENTRY ECREMS
      LLAST=.FALSE.
      LREMOV=.TRUE.
      GOTO 10
      ENTRY ECOUT
      RETURN
      ENTRY ECEND
      LLAST=.TRUE.
      LREMOV=.FALSE.
      GOTO 10
      ENTRY ECACTV (LACTV)
      LACTV=LECON
      RETURN
      ENTRY ECAVAL
      RETURN
      ENTRY ECLBL
C----------
C   OUTPUT FLAG FOR END OF ACTIVITY SUMMARY DATA AND STAND LABELS
C----------
      CALL REVISE (VARACD,REV)
      WRITE(JOSUME,8004) NPLT,MGMID,VARACD,REV
 8004     FORMAT('-999'/A26,T10,A4,2(1X,A))
      RETURN
      END
