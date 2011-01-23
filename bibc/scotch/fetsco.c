/*           CONFIGURATION MANAGEMENT OF EDF VERSION                  */
/* MODIF fetsco scotch  DATE 24/01/2011   AUTEUR BOITEAU O.BOITEAU */
/* ================================================================== */
/* COPYRIGHT (C) 1991 - 2011  EDF R&D              WWW.CODE-ASTER.ORG */
/*                                                                    */
/* THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR      */
/* MODIFY IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS     */
/* PUBLISHED BY THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE */
/* LICENSE, OR (AT YOUR OPTION) ANY LATER VERSION.                    */
/* THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,    */
/* BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF     */
/* MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU   */
/* GENERAL PUBLIC LICENSE FOR MORE DETAILS.                           */
/*                                                                    */
/* YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE  */
/* ALONG WITH THIS PROGRAM; IF NOT, WRITE TO : EDF R&D CODE_ASTER,    */
/*    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.     */
/* ================================================================== */
#include <stdio.h>
#include "aster.h"

#ifndef _DISABLE_SCOTCH
#include "scotch.h"
#endif


void DEFPPPPPPPPPP(FETSCO,fetsco, INTEGER *nbmato, INTEGER *nblien,
                                 int *connect, int *idconnect, INTEGER *nbpart,
                                 int *mapsd, int *edlo, int *velo, 
				 INTEGER *numver, INTEGER *ier)
{
#ifndef _DISABLE_SCOTCH
  int err,numv;
  int version=0;
  int release=0;
  int patch=0;
  SCOTCH_Graph        grafdat;
  SCOTCH_Arch         archdat; 
  SCOTCH_Strat        mapstrat;  
  SCOTCH_Mapping      mapdat;  


  err=0;
  err = SCOTCH_graphInit (&grafdat);

/* Cet appel a SCOTCH_version n'est licite qu'� partir de la v5.0.0*/  
  if ( err== 0){
    SCOTCH_version(&version,&release,&patch);
/*    printf("SCOTCH VERSION= %d.%d.%d\n",version,release,patch);
    printf("\n");*/
  }  
  if ( err == 0 )
    err = SCOTCH_graphBuild(&grafdat,1,(int)*nbmato,idconnect,NULL,velo,NULL,(int)*nblien,connect,edlo);

  if ( err == 0 ) 
    err = SCOTCH_graphCheck (&grafdat);

  if ( err == 0 ) 
    err = SCOTCH_archInit (&archdat);                     

  if ( err == 0 ) 
    err = SCOTCH_archCmplt (&archdat,(int)*nbpart);   

  if ( err == 0 ) 
    err = SCOTCH_stratInit (&mapstrat);                     

  if ( err == 0 ) 
    err = SCOTCH_graphMapInit (&grafdat, &mapdat, &archdat,mapsd);

  if ( err == 0 ) 
    err =  SCOTCH_graphMapCompute (&grafdat, &mapdat, &mapstrat);

  if ( err == 0 ) {
    SCOTCH_stratExit (&mapstrat);
    SCOTCH_graphMapExit (&grafdat, &mapdat);
    SCOTCH_archExit     (&archdat);
    SCOTCH_graphExit    (&grafdat);
  }
  
   numv=version*10000+release*100+patch;
  *numver = (INTEGER)numv;
  *ier = (INTEGER)err;
#endif
}

