subroutine uimpba(clas, iunmes)
    implicit none
#include "jeveux.h"
!
#include "asterfort/gettco.h"
#include "asterfort/assert.h"
#include "asterfort/jecreo.h"
#include "asterfort/jecroc.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeecra.h"
#include "asterfort/jelgdq.h"
#include "asterfort/jelira.h"
#include "asterfort/jelstc.h"
#include "asterfort/jenonu.h"
#include "asterfort/jenuno.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
    character(len=*) :: clas
    integer :: iunmes
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: jacques.pellet at edf.fr
! ----------------------------------------------------------------------
! BUT:
!   IMPRIMER LA TAILLE DES CONCEPTS STOCKES SUR UNE BASE
!
!  IN    CLAS  : NOM DE LA BASE : 'G', 'V', ..(' ' -> TOUTES LES BASES)
! ----------------------------------------------------------------------
    character(len=8) :: k8
    character(len=24) :: kbid, obj
    character(len=16) :: typcon
    real(kind=8) :: rlong, mega, taitot
    integer :: i, nbobj, nbval, iexi, nbcon,   nbsv
    integer ::     nstot
    character(len=24), pointer :: liste_obj(:) => null()
    integer, pointer :: vnbobj(:) => null()
    integer, pointer :: nbsvc(:) => null()
    integer, pointer :: nbsvo(:) => null()
    real(kind=8), pointer :: tailcon(:) => null()
    real(kind=8), pointer :: taille(:) => null()
!
!
    mega=1024*1024
!
!
!     -- 1 : NBOBJ + .LISTE_OBJ :LISTE DES OBJETS :
!     ----------------------------------------------
    nbobj=0
    call jelstc(clas, ' ', 0, nbobj, kbid,&
                nbval)
    ASSERT(nbval.le.0)
    if (nbval .eq. 0) goto 9999
    nbobj=-nbval
    AS_ALLOCATE(vk24=liste_obj, size=nbobj+1)
    call jelstc(clas, ' ', 0, nbobj, liste_obj,&
                nbval)
!     NBVAL = NBOBJ (+1 EVENTUELLEMENT A CAUSE DE '&&UIMPBA.LISTE_OBJ')
    ASSERT(nbval.eq.nbobj+1 .or. nbval.eq.nbobj)
    nbobj=nbval
!
!     -- 2 : .TAILLE = TAILLE DES OBJETS :
!     --------------------------------------
    AS_ALLOCATE(vr=taille, size=nbobj)
    AS_ALLOCATE(vi=nbsvo, size=nbobj)
    do i=1,nbobj
        obj=liste_obj(i)
        call jelgdq(obj, rlong, nbsv)
        ASSERT(rlong.gt.0.d0)
        taille(i)=rlong
        nbsvo(i)=nbsv
    end do
!
!
!     -- 3 : .LCONK8 = LISTE DES CONCEPTS (K8) DE .LISTE_OBJ
!     -----------------------------------------------------------
    call jecreo('&&UIMPBA.LCONK8', 'V N K8')
    call jeecra('&&UIMPBA.LCONK8', 'NOMMAX', nbobj)
    do i=1,nbobj
        obj=liste_obj(i)
        k8=obj(1:8)
        call jenonu(jexnom('&&UIMPBA.LCONK8', k8), iexi)
        if (iexi .eq. 0) then
            call jecroc(jexnom('&&UIMPBA.LCONK8', k8))
        endif
    end do
!
!
!     -- 4 : .TAILCON = TAILLE DES CONCEPTS
!     -----------------------------------------------------------
    call jelira('&&UIMPBA.LCONK8', 'NOMUTI', nbcon)
    AS_ALLOCATE(vr=tailcon, size=nbcon)
    AS_ALLOCATE(vi=nbsvc, size=nbcon)
    AS_ALLOCATE(vi=vnbobj, size=nbcon)
    taitot=0.d0
    nstot=0
    do i=1,nbobj
        obj=liste_obj(i)
        k8=obj(1:8)
        call jenonu(jexnom('&&UIMPBA.LCONK8', k8), iexi)
        ASSERT(iexi.gt.0)
        ASSERT(iexi.le.nbcon)
        tailcon(iexi)=tailcon(iexi)+taille(i)
        taitot=taitot+taille(i)
        nbsvc(iexi)=nbsvc(iexi)+nbsvo(i)
        vnbobj(iexi)=vnbobj(iexi)+1
        nstot=nstot+nbsvo(i)
    end do
!
!
!     -- 5 : IMPRESSION DU RESULTAT :
!     -----------------------------------------------------------
    write(iunmes,*) '-----------------------------------------------',&
     &                '----------------------------'
    write(iunmes,*) 'Concepts de la base: ',clas
    write(iunmes,*) '   Nom       Type                 Taille (Mo)',&
     &                '         Nombre      Nombre de'
    write(iunmes,*) '                                            ',&
     &                '        d''objets       segments'
!
    write(iunmes,1000) 'TOTAL   ',' ',taitot/mega,nbobj,nstot
    write(iunmes,*) ' '
!
!     -- ON IMPRIME D'ABORD LES CONCEPTS UTILISATEUR :
    do i=1,nbcon
        call jenuno(jexnum('&&UIMPBA.LCONK8', i), k8)
        call gettco(k8, typcon)
        if (typcon .eq. ' ') cycle
        write(iunmes,1000) k8,typcon,tailcon(i)/mega, vnbobj(i),nbsvc(i)
    end do
    
!     -- ON IMPRIME ENSUITE LES CONCEPTS CACHES  :
    do i=1,nbcon
        call jenuno(jexnum('&&UIMPBA.LCONK8', i), k8)
        call gettco(k8, typcon)
        if (typcon .ne. ' ') cycle
        write(iunmes,1000) k8,typcon,tailcon(i)/mega, vnbobj(i),nbsvc(i)
    end do
    write(iunmes,*) '-----------------------------------------------',&
     &                '----------------------------'
!
!
9999  continue
    AS_DEALLOCATE(vk24=liste_obj)
    AS_DEALLOCATE(vr=taille)
    call jedetr('&&UIMPBA.LCONK8')
    AS_DEALLOCATE(vr=tailcon)
    AS_DEALLOCATE(vi=nbsvo)
    AS_DEALLOCATE(vi=nbsvc)
    AS_DEALLOCATE(vi=vnbobj)
    1000 format (4x,a8,3x,a16,3x,f12.2,3x,i12,3x,i12)
end subroutine
