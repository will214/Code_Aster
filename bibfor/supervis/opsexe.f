      SUBROUTINE OPSEXE( NUOPER )
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER            NUOPER
      INTEGER VALI
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 14/02/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     EXECUTION DES PROCEDURES SUPERVISEUR
C     ------------------------------------------------------------------
      GOTO (  1,  2,  3,  4,  5,  6,  7,  8,  9  ,10,
     +       11, 12, 13, 14, 15, 16, 17, 18, 19 , 20,
     +       21, 22, 23, 24, 25, 26, 27, 28, 29 , 30,
     +       31, 32, 33, 34, 35, 36, 37, 38, 39 , 40,
     +       41, 42, 43, 44, 45, 46, 47, 48, 49 , 50,
     +       51, 52, 53, 54, 55, 56, 57, 58, 59 , 60,
     +       61, 62, 63, 64, 65, 66, 67, 68, 69 , 70,
     +       71, 72, 73, 74, 75, 76, 77, 78, 79 , 80,
     +       81, 82, 83, 84, 85, 86, 87, 88, 89 , 90,
     +       91, 92, 93, 94, 95, 96, 97, 98, 99      ) NUOPER
         VALI = -NUOPER
         CALL U2MESG('E','SUPERVIS_60',0,' ',1,VALI,0,0.D0)
      GOTO 99999
C
   1  CONTINUE
         CALL OPS001()
      GOTO 99999
C
   2  CONTINUE
         CALL OPS002()
      GOTO 99999
C
   3  CONTINUE
         CALL OPS003()
      GOTO 99999
C
   4  CONTINUE
         CALL OPS004()
      GOTO 99999
C
   5  CONTINUE
         CALL OPS005()
      GOTO 99999
C
   6  CONTINUE
         CALL OPS006()
      GOTO 99999
C
   7  CONTINUE
         CALL OPS007()
      GOTO 99999
C
   8  CONTINUE
         CALL OPS008()
      GOTO 99999
C
   9  CONTINUE
         CALL OPS009()
      GOTO 99999
C
  10  CONTINUE
         CALL OPS010()
      GOTO 99999
C
  11  CONTINUE
         CALL OPS011()
      GOTO 99999
C
  12  CONTINUE
         CALL OPS012()
      GOTO 99999
C
  13  CONTINUE
         CALL OPS013()
      GOTO 99999
C
  14  CONTINUE
         CALL OPS014()
      GOTO 99999
C
  15  CONTINUE
         CALL OPS015()
      GOTO 99999
C
  16  CONTINUE
         CALL OPS016()
      GOTO 99999
C
  17  CONTINUE
         CALL OPS017()
      GOTO 99999
C
  18  CONTINUE
         CALL OPS018()
      GOTO 99999
C
  19  CONTINUE
         CALL OPS019()
      GOTO 99999
C
  20  CONTINUE
         CALL OPS020()
      GOTO 99999
C
  21  CONTINUE
         CALL OPS021()
      GOTO 99999
C
  22  CONTINUE
         CALL OPS022()
      GOTO 99999
C
  23  CONTINUE
         CALL OPS023()
      GOTO 99999
C
  24  CONTINUE
         CALL OPS024()
      GOTO 99999
C
  25  CONTINUE
         CALL OPS025()
      GOTO 99999
C
  26  CONTINUE
         CALL OPS026()
      GOTO 99999
C
  27  CONTINUE
         CALL OPS027()
      GOTO 99999
C
  28  CONTINUE
         CALL OPS028()
      GOTO 99999
C
  29  CONTINUE
         CALL OPS029()
      GOTO 99999
C
  30  CONTINUE
         CALL OPS030()
      GOTO 99999
C
  31  CONTINUE
         CALL OPS031()
      GOTO 99999
C
  32  CONTINUE
         CALL OPS032()
      GOTO 99999
C
  33  CONTINUE
         CALL OPS033()
      GOTO 99999
C
  34  CONTINUE
         CALL OPS034()
      GOTO 99999
C
  35  CONTINUE
         CALL OPS035()
      GOTO 99999
C
  36  CONTINUE
         CALL OPS036()
      GOTO 99999
C
  37  CONTINUE
         CALL OPS037()
      GOTO 99999
C
  38  CONTINUE
         CALL OPS038()
      GOTO 99999
C
  39  CONTINUE
         CALL OPS039()
      GOTO 99999
C
  40  CONTINUE
         CALL OPS040()
      GOTO 99999
C
  41  CONTINUE
         CALL OPS041()
      GOTO 99999
C
  42  CONTINUE
         CALL OPS042()
      GOTO 99999
C
  43  CONTINUE
         CALL OPS043()
      GOTO 99999
C
  44  CONTINUE
         CALL OPS044()
      GOTO 99999
C
  45  CONTINUE
         CALL OPS045()
      GOTO 99999
C
  46  CONTINUE
         CALL OPS046()
      GOTO 99999
C
  47  CONTINUE
         CALL OPS047()
      GOTO 99999
C
  48  CONTINUE
         CALL OPS048()
      GOTO 99999
C
  49  CONTINUE
         CALL OPS049()
      GOTO 99999
C
  50  CONTINUE
         CALL OPS050()
      GOTO 99999
C
  51  CONTINUE
         CALL OPS051()
      GOTO 99999
C
  52  CONTINUE
         CALL OPS052()
      GOTO 99999
C
  53  CONTINUE
         CALL OPS053()
      GOTO 99999
C
  54  CONTINUE
         CALL OPS054()
      GOTO 99999
C
  55  CONTINUE
         CALL OPS055()
      GOTO 99999
C
  56  CONTINUE
         CALL OPS056()
      GOTO 99999
C
  57  CONTINUE
         CALL OPS057()
      GOTO 99999
C
  58  CONTINUE
         CALL OPS058()
      GOTO 99999
C
  59  CONTINUE
         CALL OPS059()
      GOTO 99999
C
  60  CONTINUE
         CALL OPS060()
      GOTO 99999
C
  61  CONTINUE
         CALL OPS061()
      GOTO 99999
C
  62  CONTINUE
         CALL OPS062()
      GOTO 99999
C
  63  CONTINUE
         CALL OPS063()
      GOTO 99999
C
  64  CONTINUE
         CALL OPS064()
      GOTO 99999
C
  65  CONTINUE
         CALL OPS065()
      GOTO 99999
C
  66  CONTINUE
         CALL OPS066()
      GOTO 99999
C
  67  CONTINUE
         CALL OPS067()
      GOTO 99999
C
  68  CONTINUE
         CALL OPS068()
      GOTO 99999
C
  69  CONTINUE
         CALL OPS069()
      GOTO 99999
C
  70  CONTINUE
         CALL OPS070()
      GOTO 99999
C
  71  CONTINUE
         CALL OPS071()
      GOTO 99999
C
  72  CONTINUE
         CALL OPS072()
      GOTO 99999
C
  73  CONTINUE
         CALL OPS073()
      GOTO 99999
C
  74  CONTINUE
         CALL OPS074()
      GOTO 99999
C
  75  CONTINUE
         CALL OPS075()
      GOTO 99999
C
  76  CONTINUE
         CALL OPS076()
      GOTO 99999
C
  77  CONTINUE
         CALL OPS077()
      GOTO 99999
C
  78  CONTINUE
         CALL OPS078()
      GOTO 99999
C
  79  CONTINUE
         CALL OPS079()
      GOTO 99999
C
  80  CONTINUE
         CALL OPS080()
      GOTO 99999
C
  81  CONTINUE
         CALL OPS081()
      GOTO 99999
C
  82  CONTINUE
         CALL OPS082()
      GOTO 99999
C
  83  CONTINUE
         CALL OPS083()
      GOTO 99999
C
  84  CONTINUE
         CALL OPS084()
      GOTO 99999
C
  85  CONTINUE
         CALL OPS085()
      GOTO 99999
C
  86  CONTINUE
         CALL OPS086()
      GOTO 99999
C
  87  CONTINUE
         CALL OPS087()
      GOTO 99999
C
  88  CONTINUE
         CALL OPS088()
      GOTO 99999
C
  89  CONTINUE
         CALL OPS089()
      GOTO 99999
C
  90  CONTINUE
         CALL OPS090()
      GOTO 99999
C
  91  CONTINUE
         CALL OPS091()
      GOTO 99999
C
  92  CONTINUE
         CALL OPS092()
      GOTO 99999
C
  93  CONTINUE
         CALL OPS093()
      GOTO 99999
C
  94  CONTINUE
         CALL OPS094()
      GOTO 99999
C
  95  CONTINUE
         CALL OPS095()
      GOTO 99999
C
  96  CONTINUE
         CALL OPS096()
      GOTO 99999
C
  97  CONTINUE
         CALL OPS097()
      GOTO 99999
C
  98  CONTINUE
         CALL OPS098()
      GOTO 99999
C
  99  CONTINUE
         CALL OPS099()
      GOTO 99999
C ------------------------------------------------------------------
99999 CONTINUE
C
      END
