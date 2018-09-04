      BLOCK DATA MPBLKD
      IMPLICIT NONE
C----------
C LPMPB $Id$
C----------
C
C     MOUNTAIN PINE BEETLE --
C     SEE MPBCUP OR MPBMOD FOR VARIABLE DISCRIPTIONS.
C
C Revision History
C   04/14/10 LANCE DAVID (FMSC)
C     CREATED THIS TETON VARIANT VERSION TO ACCOMODATE THE 18 SPECIES
C     NOW REPRESENTED. SURROGATE SPECIES ASSIGNMENTS ARE BASED ON
C     THOSE MADE IN THE CENTRAL ROCKIES AND UTAH VARIANTS.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C   08/22/14 Lance R. David (FMSC)
C     Function name was used as variable name.
C     changed variable INT to INCRS
C----------------------------------------------------------------------
C
COMMONS

      INCLUDE 'PRGPRM.F77'

      INCLUDE 'MPBCOM.F77'

      DATA  JOMPB  / 7 /

      DATA IPLTNO/ 1 /,IMPROB/ 1 /,NATR/ 2 /, KEYMPB/ 2,3,6*0,1 /,
     >     INCRS/ 10 /

C     SPECIES LIST FOR TETON VARIANT. ***** 18 species *****
C     
C  vv---- MPB surface area calculation surrogate specie (surfce.f)
C  !!   
C  !!  SPECIES LIST FOR UT VARIANT.
C  !!  ------FVS UT VARIANT-------  
C  !!   # CD COMMON NAME            SCIENTIFIC NAME
C  !!  -- -- ---------------------  --------------------- 
C  WP   1 WB WHITEBARK PINE         PINUS ALBICAULIS          
C  WL   2 LM LIMBER PINE            PINUS FLEXILIS            
C  DF   3 DF DOUGLAS-FIR            PSEUDOTSUGA MENZIESII     
C  WL   4 PM SINLELEAF PINYON       PINUS MONOPHYLLA      
C  WP   5 BS BLUE SPRUCE            PICEA PUNGENS             
C  WL   6 AS QUAKING ASPEN          POPULUS TREMULOIDES       
C  LP   7 LP LODGEPOLE PINE         PINUS CONTORTA            
C  WP   8 ES ENGLEMANN SPRUCE       PICEA ENGELMANNII         
C  DF   9 AF SUBALPINE FIR          ABIES LASIOCARPA          
C  PP  10 PP PONDEROSA PINE         PINUS PONDEROSA           
C  WL  11 UJ UTAH JUNIPER           JUNIPERUS OSTEOSPERMA
C  WL  12 RM ROCKY MOUNTAIN JUNIPER JUNIPERUS SCOPULORUM
C  DF  13 BI BIGTOOTH MAPLE         ACER GRANDIDENTATUM
C  DF  14 MM ROCK MOUNTAIN MAPLE    ACER GLABRUM
C  DF  15 NC NARROWLEAF COTTONWOOD  POPULUS ANGUSTIFOLIA
C  DF  16 MC CURLLEAF MOUNTAIN-     CERCOCARPUS LEDIFOLIUS
C            MAHOGANY
C  WL  17 OS OTHER SOFTWOODS        
C  DF  18 OH OTHER HARDWOODS        
C
C     LPMPB SPECIES INDICES FOR TT LIST ABOVE

      DATA IDXWP,IDXWL,IDXDF,IDXLP,IDXPP/1,2,3,7,10/

C     ASSIGN LPMPB SURROGATE SPECIES FOR CALCULATIONS IN SURFCE.F
C
C     TT 18 SPECIES LIST
C                  WB LM DF PM BS AS LP ES AF PP   -- TT 18 species
      DATA MPBSPM / 1, 2, 3, 2, 1, 3, 7, 1, 3,10,
C                  UJ RM BI MM NC MC OS OH         -- TT 18 species
     &              2, 2, 2, 2, 3, 3, 2, 3/
      END
