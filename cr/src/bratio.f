      FUNCTION BRATIO(IS,D,H)
      IMPLICIT NONE
C----------
C CR $Id: bratio.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C FUNCTION TO COMPUTE BARK RATIOS AS A FUNCTION OF DIAMETER AND SPECIES.
C REPLACES ARRAY BKRAT IN BASE MODEL. COEFFICIENTS FOR BARK1 AND BARK2
C ARE SET IN BLKDAT AND SITSET.  IF BARK1 AND BARK2 ARE BOTH ZERO THEN
C ITS THE BLACK HILL MODEL TYPE AND USE CORMIER'S FMSC MODEL.
C----------
C  COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C  COMMONS
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
      INTEGER IMAP(MAXSP),IEQN,IS
      REAL H,D,BRATIO,TEMD
      REAL RDANUW
C
      DATA IMAP/ 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 
     &           3, 1, 1, 3, 2, 1, 3, 3, 3, 2,
     &           3, 3, 3, 3, 3, 3, 3, 2, 1, 1,
     &           1, 1, 1, 1, 1, 1, 1, 3/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = H
C----------
C  PI, PP, UJ, AJ, RM, OJ, ER AND OS USE PP BARK EQUATION.
C  PP EQN IS DIFFERENT FOR BHPP, S-F, AND LP MODEL TYPES.
C  BARKi() COEFFICIENTS SET TO ZERO IN SITSET TO TRIGGER
C  DIFFERENT EQUATION IN THESE MODEL TYPES.
C  PP EQN FOR BLACK HILLS WAS FIT BY CORMIER, FMSC
C  PP FOR MODEL TYPES 1 & 2 USES EQUATION FROM CA VARIANT
C  AF, CB, GF, WF USE THE CONSTANT RATIO FROM NI VARIANT
C----------
      IEQN=IMAP(IS)
      TEMD=D
      IF(TEMD.LT.1.)TEMD=1.
C
      IF(IEQN .EQ. 1) THEN
        IF(BARK1(IS).EQ.0.0 .AND. BARK2(IS).EQ.0.0)THEN
          IF(TEMD.GT.19.)TEMD=19.
          BRATIO = 0.9002 - 0.3089*(1/TEMD)
        ELSE
          BRATIO=BARK1(IS)+BARK2(IS)*(1/TEMD)
        ENDIF
C
      ELSEIF(IEQN .EQ. 2)THEN
        BRATIO=BARK1(IS)
C
      ELSEIF(IEQN .EQ. 3)THEN
        BRATIO=BARK1(IS)+BARK2(IS)*(1.0/TEMD)
      ENDIF
C
      IF(BRATIO .GT. 0.99) BRATIO=0.99
      IF(BRATIO .LT. 0.80) BRATIO=0.80
C
      RETURN
      END

