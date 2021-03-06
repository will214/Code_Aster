subroutine skeleton_of_nullbasis( mat_c, mat_z, nnzmax )
#include "asterf_types.h"
#include "asterf_petsc.h"
!
implicit none
!
! person_in_charge: natacha.bereux at edf.fr
! aslint:disable=W1003
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
#include "jeveux.h"
#include "asterc/asmpi_comm.h"
#include "asterc/r8prem.h"
#include "asterfort/assert.h"
#include "asterfort/infniv.h"
!
! ---------------------------------------------------------------
! Préallocation et initialisation de la matrice mat_z
! destinée à contenir la base du noyau de la matrice mat_c
! ---------------------------------------------------------------
#ifdef HAVE_PETSC
!
    Mat, intent(in)                               :: mat_c
    Mat, intent(out)                              :: mat_z
    PetscInt, intent(out)                         :: nnzmax
!
!================================================================
!
    integer :: ifm, niv
    aster_logical :: debug
    aster_logical, dimension(:), allocatable :: is_constrained
    mpi_int :: mpicomm
    PetscInt :: mc, nc, ic, ii, jj, kk, ncol, maxloc_free_c, passe
    PetscInt :: ncons, nfree, nelim, nnz, loop
    PetscErrorCode :: ierr
    PetscScalar :: eps
    PetscInt, dimension(:), allocatable :: idfree_c, idcons_c
    PetscInt, dimension(:), allocatable :: col_c, colnorm_c
    PetscScalar, dimension(:), allocatable :: valnorm, val
    PetscScalar :: norm_v, norm, valmax, norm_row
    PetscInt, dimension(:), allocatable :: nnz_of_row
    PetscScalar, parameter :: rzero = 0.d0, rone = 1.d0
    PetscInt, parameter :: ione = 1
    !----------------------------------------------------------------------
    eps=r8prem()
    call asmpi_comm('GET_WORLD', mpicomm)
    call infniv(ifm,niv)
    debug = .false.
!
!   La matrice des contraintes mat_c est de taille mc x nc
!
    call MatGetSize(mat_c, mc, nc, ierr)
    ASSERT(ierr == 0 )
    if (debug) then
        write(ifm,*),' -- Build skeleton of Z, such that CZ = 0 '
        write(ifm,*),'       Matrix C has ', mc, ' row(s) and ', nc,' column(s).'
    endif
!
    ASSERT( nc > 0 )
!   is_constrained(ii)=true si le degré de liberté ii
!   est fixé par une contrainte déjà éliminée
    allocate(is_constrained (nc), stat = ierr)
    ASSERT( ierr == 0)
!   On ne connaît pas le nombre maximal de termes non-nuls par lignes
!   de la matrice Z : on dimensionne les tableaux à nc
    allocate( val(nc), stat = ierr)
    ASSERT( ierr == 0 )
    allocate( col_c ( nc ), stat = ierr )
    ASSERT( ierr == 0 )
    allocate( valnorm( nc ), stat = ierr )
    ASSERT( ierr == 0 )
    allocate( colnorm_c( nc ), stat = ierr )
    ASSERT( ierr == 0 )
    allocate( idfree_c( nc ), stat = ierr )
    ASSERT( ierr == 0 )
    allocate( idcons_c( nc ), stat = ierr )
    ASSERT( ierr == 0 )
    allocate( nnz_of_row( nc ), stat = ierr)
    ASSERT( ierr == 0 )
!
! On effectue deux passes sur les contraintes (lignes de mat_c)
! La première passe permet de calculer le profil de la matrice mat_z
! (i.e. de remplir le tableau nnz_of_row)
! La seconde passe permet d'allouer mat_z et d'initialiser les
! termes prévus dans le profil (1 pour les termes diagonaux, 0 sinon)
! Cette opération a pour but de garder la structure creuse allouée au
! cours de MatAssemblyBegin/End de nullbasis
! -------------------------
!                         !
    do passe = 1, 2
!                         !
!--------------------------
!
        if ( passe == 2 ) then
! On vérifie qu'on n'a jamais prévu de ligne avec plus de termes non-nuls que de colonnes
            do ii = 1, nc
                nnz_of_row( ii ) = min( nnz_of_row(ii) , nc )
            enddo
! On alloue la matrice mat_z
            call MatCreateSeqAIJ(mpicomm, nc, nc, PETSC_DEFAULT_INTEGER, nnz_of_row,&
                                 mat_z, ierr)
            ASSERT( ierr == 0 )
            call MatSetOption( mat_z, MAT_NEW_NONZERO_ALLOCATION_ERR, PETSC_FALSE, ierr )
            ASSERT( ierr == 0 )
! Et on l'initialise à l'identité (1 sur la diagonale)
            do ii=1, nc
                call MatSetValues( mat_z, ione, [to_petsc_int(ii-1)], ione, [to_petsc_int(ii-1)], &
                    [rone], INSERT_VALUES, ierr )
                ASSERT( ierr == 0 )
            enddo
        endif
!
      nnz_of_row(:) = 1
      is_constrained(:)=.false.
!--------------------------------!
!--                            --!
!-- Boucle sur les contraintes --!
!--                            --!
!--------------------------------!
!
! On parcourt deux fois les contraintes
! le premier parcours permet de traiter
! les contraintes qui portent sur un seul ddl
!
    do loop=1,2
       do ic = 1, mc
       !
        if (debug) write(ifm,'(A18,I6)'),'  --  CONTRAINTE : ',ic
        if (debug) write(ifm,*) "Passe = ", passe, "Loop = ", loop
!
! On lit la ligne ic de la matrice C
!
       call MatGetRow( mat_c, to_petsc_int(ic-1), ncol, col_c, val, &
                       ierr)
! Copie et normalisation de C(ic,:) => colnorm_c & valnorm
!
       norm_row = sqrt( dot_product(val(1:ncol), val(1:ncol)) )
! TODO
       ASSERT( norm_row > eps )
       nnz = 0
       do ii = 1, ncol
          if ( abs(val( ii )/norm_row)  > eps ) then
             nnz = nnz + 1
             valnorm( nnz ) = val( ii )/norm_row
             colnorm_c(nnz) = col_c( ii )
          endif
       enddo
!
! Libération de la ligne ic de la matrice C
!
       call MatRestoreRow( mat_c, to_petsc_int( ic-1 ), ncol, col_c, val,&
                       ierr)
        ASSERT( ierr == 0 )
!
! >>>>>>
! Cas 1 : la contrainte a un seul terme non-nul (Single Point Constraint)
! <<<<<<
       if ( nnz == 1 ) then
! la contrainte est colinéaire à un vecteur de la base standard
! => ce vecteur n'est pas dans la base du noyau, on l'enlève de Z
         is_constrained ( colnorm_c( nnz ) + 1 ) = .true.
       else
! >>>>>>
! Cas 2:  la contrainte a plusieurs termes non-nuls (Multi Point Constraint)
! <<<<<<
!    On traite ce cas seulement au second passage (loop =2)
         if (loop == 2) then
! On partitionne les indices des termes non-nuls
! en deux ensembles :
! ceux qui ont été impliqués dans une contrainte précédemment
! éliminée et ceux que l'on n'a jamais rencontré
!
         ncons = 0
         nfree = 0
         valmax = 0.d0
         maxloc_free_c = 0
!
         do jj = 1, nnz
          if ( is_constrained( colnorm_c( jj ) + 1 ) ) then
             ncons = ncons + 1
             idcons_c( ncons ) = colnorm_c( jj )
          else
             nfree = nfree + 1
             idfree_c( nfree ) = colnorm_c( jj )
             if ( abs(valnorm( jj )) > abs(valmax) ) then
                valmax =  valnorm( jj )
                maxloc_free_c =   colnorm_c( jj )
               endif
             endif
         enddo
         ASSERT( nfree + ncons == nnz )
! Z_free_free contient au plus nfree termes par ligne

         do ii = 1, nfree
            nnz_of_row( idfree_c(ii)+1 ) =   nnz_of_row( idfree_c(ii)+1 ) + nfree
            if ( passe == 2 ) then
               call MatSetValues( mat_z, ione, [idfree_c(ii)], nfree, idfree_c(1:nfree), &
                (/ (rzero, jj=1, nfree) /), &
                INSERT_VALUES, ierr )
                ASSERT( ierr == 0 )
            endif
         enddo
! De plus, si ncons > 0 et nfree > 0
! la contrainte courante implique à la fois des degrés de liberté
! "constrained" déjà rencontrés  au cours des éliminations
! précédentes et des degrés de liberté "free", encore jamais
! rencontrés.
! On ne sait pas évaluer précisément le remplissage de la ligne
! Une estimation basse est ncons.
! On utilise cette estimation et on autorisera l'insertion de termes
! supplémentaires
         nelim = count( is_constrained(:))
         nnz_of_row( maxloc_free_c +1 ) = nnz_of_row( maxloc_free_c +1 ) + ncons
         if ( passe == 2 ) then
            call MatSetValues( mat_z, ione, [maxloc_free_c], ncons, idcons_c(1:ncons), &
                                       (/(rzero, jj=1,ncons)/), INSERT_VALUES, ierr )
            ASSERT( ierr == 0 )
         endif
! On marque comme éliminés les dls "free"
         is_constrained( idfree_c(1:nfree) + 1 ) = .true.
! Fin de la boucle : if loop == 2
       endif
! Find de la boucle if ( nnz == 1 ) else ...
     endif
! Fin de la boucle sur les lignes de mat_c
  enddo
! Fin de la boucle "loop"
 enddo
! -----
! Fin de la boucle sur les passes
  enddo
!
   call MatAssemblyBegin(mat_z, MAT_FINAL_ASSEMBLY, ierr)
   ASSERT( ierr == 0 )
   call MatAssemblyEnd(mat_z, MAT_FINAL_ASSEMBLY, ierr)
   ASSERT( ierr == 0 )
!
! Nombre maximum de termes non-nuls dans une ligne de mat_z
  nnzmax = maxval( nnz_of_row )
!
! Libération de la mémoire
  if (allocated( is_constrained ) ) then
    deallocate( is_constrained, stat=ierr )
    ASSERT( ierr == 0 )
  endif
  if (allocated( val )) then
    deallocate( val, stat = ierr )
    ASSERT( ierr == 0 )
  endif
  if (allocated( valnorm )) then
     deallocate( valnorm, stat = ierr )
     ASSERT( ierr == 0 )
  endif
  if (allocated( col_c )) then
  deallocate( col_c, stat = ierr )
  ASSERT( ierr == 0 )
  endif
  if (allocated( colnorm_c )) then
  deallocate( colnorm_c, stat = ierr )
  ASSERT( ierr == 0 )
  endif
  if ( allocated( idfree_c )) then
  deallocate( idfree_c, stat = ierr )
  ASSERT( ierr == 0 )
  endif
  if ( allocated( idcons_c )) then
  deallocate( idcons_c, stat = ierr )
  ASSERT( ierr == 0 )
  endif
  if ( allocated ( nnz_of_row )) then
  deallocate( nnz_of_row, stat = ierr )
  ASSERT( ierr == 0 )
  endif
!
#else
    integer :: mat_c, mat_z, nnzmax
    integer :: idummy
    idummy = mat_c + mat_z + nnzmax
    ASSERT(.false.)
#endif
end subroutine
