subroutine hmlvga(yachai, option, meca, ther, hydr,&
                  imate, ndim, dimdef, dimcon, nbvari,&
                  yamec, yate, addeme, adcome, advihy,&
                  advico, vihrho, vicphi, vicpvp, vicsat,&
                  addep1, adcp11, adcp12, addep2, adcp21,&
                  adcp22, addete, adcote, congem, congep,&
                  vintm, vintp, dsde, epsv, depsv,&
                  p1, p2, dp1, dp2, t,&
                  dt, phi, padp, pvp, h11,&
                  h12, kh, rho11, phi0, pvp0,&
                  sat, retcom, thmc, tbiot, rinstp,&
                  angmas, deps, aniso, phenom)
! ======================================================================
! ======================================================================
! person_in_charge: sylvie.granet at edf.fr
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! **********************************************************************
! ROUTINE HMLVAG : CETTE ROUTINE CALCULE LES CONTRAINTES GENERALISE
!   ET LA MATRICE TANGENTE DES GRANDEURS COUPLEES, A SAVOIR CELLES QUI
!   NE SONT PAS DES GRANDEURS DE MECANIQUE PURE OU DES FLUX PURS
!   DANS LE CAS OU THMC = 'LIQU_AD_GAZ_VAPE'
! **********************************************************************
! OUT RETCOM : RETOUR LOI DE COMPORTEMENT
! COMMENTAIRE DE NMCONV :
!                       = 0 OK
!                       = 1 ECHEC DANS L'INTEGRATION : PAS DE RESULTATS
!                       = 3 SIZZ NON NUL (DEBORST) ON CONTINUE A ITERER
!  VARIABLES IN / OUT
! ======================================================================
! aslint: disable=W1504
    implicit none
! aslint: disable=W1306
#include "asterf_types.h"
#include "asterc/r8maem.h"
#include "asterfort/appmas.h"
#include "asterfort/calor.h"
#include "asterfort/capaca.h"
#include "asterfort/dhdt.h"
#include "asterfort/dhw2dt.h"
#include "asterfort/dhw2p1.h"
#include "asterfort/dhw2p2.h"
#include "asterfort/dilata.h"
#include "asterfort/dileau.h"
#include "asterfort/dilgaz.h"
#include "asterfort/dmadp1.h"
#include "asterfort/dmadp2.h"
#include "asterfort/dmadt.h"
#include "asterfort/dmasdt.h"
#include "asterfort/dmasp1.h"
#include "asterfort/dmasp2.h"
#include "asterfort/dmdepv.h"
#include "asterfort/dmvdp1.h"
#include "asterfort/dmvdp2.h"
#include "asterfort/dmvpdt.h"
#include "asterfort/dmwdp1.h"
#include "asterfort/dmwdp2.h"
#include "asterfort/dmwdt.h"
#include "asterfort/dplvga.h"
#include "asterfort/dqdeps.h"
#include "asterfort/dqdp.h"
#include "asterfort/dqdt.h"
#include "asterfort/dspdp1.h"
#include "asterfort/dspdp2.h"
#include "asterfort/enteau.h"
#include "asterfort/entgaz.h"
#include "asterfort/inithm.h"
#include "asterfort/majpad.h"
#include "asterfort/majpas.h"
#include "asterfort/masvol.h"
#include "asterfort/netbis.h"
#include "asterfort/sigmap.h"
#include "asterfort/thmrcp.h"
#include "asterfort/unsmfi.h"
#include "asterfort/viemma.h"
#include "asterfort/viporo.h"
#include "asterfort/vipvp2.h"
#include "asterfort/vipvpt.h"
#include "asterfort/virhol.h"
#include "asterfort/visatu.h"
    integer :: ndim, dimdef, dimcon, nbvari, imate, yamec
    integer :: yate, retcom, adcome, adcp11, adcp12, advihy, advico
    integer :: vihrho, vicphi, vicpvp, vicsat
    integer :: adcp21, adcp22, adcote, addeme, addep1, addep2, addete
    real(kind=8) :: congem(dimcon), congep(dimcon), vintm(nbvari)
    real(kind=8) :: vintp(nbvari), dsde(dimcon, dimdef), epsv, depsv
    real(kind=8) :: p1, dp1, p2, dp2, t, dt, phi, padp, pvp, h11, h12
    real(kind=8) :: rho11, phi0, pvp0, kh, rinstp, angmas(3)
    character(len=16) :: option, meca, ther, hydr, thmc, phenom
    aster_logical :: yachai
! ======================================================================
! --- VARIABLES LOCALES ------------------------------------------------
! ======================================================================
    integer :: i, aniso
    real(kind=8) :: satm, epsvm, phim, rho11m, rho12m, rho21m, pvpm, rho22m
    real(kind=8) :: tbiot(6), cs, alpliq, cliq, rho110
    real(kind=8) :: cp11, cp12, cp21, sat, dsatp1, mamolv, mamolg
    real(kind=8) :: r, rho0, coeps, csigm, alp11, alp12, alp21
    real(kind=8) :: dp11t, dp11p1, dp11p2, dp12t, dp12p1, dp12p2
    real(kind=8) :: dp21t, dp21p1, dp21p2
    real(kind=8) :: rho12, rho21, cp22
    real(kind=8) :: padm, rho22, em, alpha0
    real(kind=8) :: eps, deps(6), mdal(6), dalal, alphfi, cbiot, unsks
    parameter  ( eps = 1.d-21 )
    aster_logical :: emmag
! ======================================================================
! --- DECLARATIONS PERMETTANT DE RECUPERER LES CONSTANTES MECANIQUES ---
! ======================================================================
    real(kind=8) :: rbid1, rbid2, rbid3, rbid4, rbid5, rbid6, rbid7
    real(kind=8) :: rbid8, rbid10, rbid14(3)
    real(kind=8) :: rbid15(ndim, ndim), rbid16, rbid17, rbid18, rbid19
    real(kind=8) :: rbid21, rbid22, rbid23, rbid24, rbid25, rbid26, rbid20
    real(kind=8) :: rbid27, rbid28, rbid29, rbid32(ndim, ndim)
    real(kind=8) :: rbid33(ndim, ndim), rbid34, rbid35, rbid38
    real(kind=8) :: rbid39, rbid45, rbid46, rbid49, rbid50(ndim, ndim)
    real(kind=8) :: signe, pvp1, pvp1m, dpad, pas
    real(kind=8) :: m11m, m12m, m21m, m22m
    real(kind=8) :: dmdeps(6), dsdp1(6)
    real(kind=8) :: pinf, sigmp(6)
    real(kind=8) :: dqeps(6), dsdp2(6), rac2
!
    aster_logical :: net, bishop
!
    rac2 = sqrt(2.d0)
!
! =====================================================================
! --- BUT : RECUPERER LES DONNEES MATERIAUX THM -----------------------
! =====================================================================
    call netbis(meca, net, bishop)
    call thmrcp('INTERMED', imate, thmc, meca, hydr,&
                ther, rbid1, rbid2, rbid3, rbid4,&
                rbid5, t, p1, p1-dp1, rbid6,&
                rbid7, rbid8, rbid10, r, rho0,&
                csigm, tbiot, satm, sat, dsatp1,&
                rbid14, rbid15, rbid16, rbid17, rbid18,&
                rbid19, rbid20, rbid21, rbid22, rbid23,&
                rbid24, rbid25, rho110, cliq, alpliq,&
                cp11, rbid26, rbid27, rbid28, rbid29,&
                mamolg, cp21, rbid32, rbid33, rbid34,&
                rbid35, mamolv, cp12, rbid38, rbid39,&
                rbid45, rbid46, cp22, kh, rbid49,&
                em, rbid50, rinstp, retcom,&
                angmas, aniso, ndim)
! ======================================================================
! --- INITIALISATIONS --------------------------------------------------
! ======================================================================
    emmag = .false.
    alp11 = 0.0d0
    alp12 = 0.0d0
    alp21 = 0.0d0
    signe = 1.0d0
    m11m = congem(adcp11)
    m12m = congem(adcp12)
    m21m = congem(adcp21)
    m22m = congem(adcp22)
    rho11 = vintm(advihy+vihrho) + rho110
    rho11m = vintm(advihy+vihrho) + rho110
    pvp = vintm(advico+vicpvp) + pvp0
    pvpm = vintm(advico+vicpvp) + pvp0
    phi = vintm(advico+vicphi) + phi0
    phim = vintm(advico+vicphi) + phi0
    retcom = 0
! =====================================================================
! --- RECUPERATION DES COEFFICIENTS MECANIQUES ------------------------
! =====================================================================
    if ((em.gt.eps) .and. (yamec.eq.0)) then
        emmag = .true.
    endif
!
    call inithm(imate, yachai, yamec, phi0, em,&
                cs, tbiot, t, epsv, depsv,&
                epsvm, angmas, aniso, mdal, dalal,&
                alphfi, cbiot, unsks, alpha0, ndim,&
                phenom)
! *********************************************************************
! *** LES VARIABLES INTERNES ******************************************
! *********************************************************************
    if ((option.eq.'RAPH_MECA') .or. (option.eq.'FORC_NODA') .or.&
        (option(1:9).eq.'FULL_MECA')) then
! =====================================================================
! --- CALCUL DE LA VARIABLE INTERNE DE POROSITE SELON FORMULE DOCR ----
! =====================================================================
        if ((yamec.eq.1)) then
            call viporo(nbvari, vintm, vintp, advico, vicphi,&
                        phi0, deps, depsv, alphfi, dt,&
                        dp1, dp2, signe, sat, cs,&
                        tbiot, phi, phim, retcom, cbiot,&
                        unsks, alpha0, aniso, phenom)
        endif
        if (emmag) then
            call viemma(nbvari, vintm, vintp, advico, vicphi,&
                        phi0, dp1, dp2, signe, sat,&
                        em, phi, phim, retcom)
        endif
! =====================================================================
! --- CALCUL DE LA PRESSION DE VAPEUR TILDE SELON FORMULE DOCR --------
! --- ETAPE INTERMEDIAIRE AU CALCUL DE LA VARIABLE INTERNE ------------
! --- NB : CE CALCUL SE FAIT AVEC LA MASSE VOLUMIQUE DU FLUIDE --------
! ---    : A L INSTANT MOINS ------------------------------------------
! =====================================================================
        pinf = r8maem()
        call vipvpt(nbvari, vintm, vintp, advico, vicpvp,&
                    dimcon, pinf, congem, adcp11, adcp12,&
                    ndim, pvp0, dp1, dp2, t,&
                    dt, mamolv, r, rho11m, kh,&
                    signe, cp11, cp12, yate, pvp1,&
                    pvp1m, retcom)
        if (retcom .ne. 0) then
            goto 30
        endif
! =====================================================================
! --- CALCUL DE LA VARIABLE INTERNE DE PRESSION DE VAPEUR -------------
! --- SELON FORMULE DOCR ----------------------------------------------
! =====================================================================
        call vipvp2(nbvari, vintm, vintp, advico, vicpvp,&
                    pvp0, pvp1, p2, dp2, t,&
                    dt, kh, mamolv, r, rho11m,&
                    yate, pvp, pvpm, retcom)
! =====================================================================
! --- MISE A JOUR DE LA PRESSION D AIR DISSOUS SELON FORMULE DOCR -----
! =====================================================================
        call majpad(p2, pvp, r, t, kh,&
                    dp2, pvpm, dt, padp, padm,&
                    dpad)
! =====================================================================
! --- CALCUL DE LA VARIABLE INTERNE DE MASSE VOLUMIQUE DU FLUIDE ------
! --- SELON FORMULE DOCR ----------------------------------------------
! =====================================================================
        call virhol(nbvari, vintm, vintp, advihy, vihrho,&
                    rho110, dp1, dp2, dpad, cliq,&
                    dt, alpliq, signe, rho11, rho11m,&
                    retcom)
! =====================================================================
! --- RECUPERATION DE LA VARIABLE INTERNE DE SATURATION ---------------
! =====================================================================
        call visatu(nbvari, vintp, advico, vicsat, sat)
    else
! =====================================================================
! --- MISE A JOUR DE LA PRESSION D AIR DISSOUS SELON FORMULE DOCR -----
! =====================================================================
        call majpad(p2, pvp, r, t, kh,&
                    dp2, pvpm, dt, padp, padm,&
                    dpad)
    endif
! =====================================================================
! --- PROBLEME DANS LE CALCUL DES VARIABLES INTERNES ? ----------------
! =====================================================================
    if (retcom .ne. 0) then
        goto 30
    endif
! =====================================================================
! --- ACTUALISATION DE CS ET ALPHFI -----------------------------------
! =====================================================================
    if (yamec .eq. 1) then
        call dilata(imate, phi, alphfi, t, aniso,&
                    angmas, tbiot, phenom)
        call unsmfi(imate, phi, cs, t, tbiot,&
                    aniso, ndim, phenom)
    endif
! **********************************************************************
! *** LES CONTRAINTES GENERALISEES *************************************
! **********************************************************************
! ======================================================================
! --- CALCUL DES MASSES VOLUMIQUES DE PRESSION DE VAPEUR ---------------
! ----------------------------------- AIR SEC --------------------------
! ----------------------------------- AIR DISSOUS ----------------------
! ======================================================================
    rho12 = masvol(mamolv,pvp ,r,t )
    rho12m = masvol(mamolv,pvpm ,r,t-dt)
    rho21 = masvol(mamolg,p2-pvp ,r,t )
    rho21m = masvol(mamolg,p2-dp2-pvpm,r,t-dt)
    rho22 = masvol(mamolg,padp ,r,t )
    rho22m = masvol(mamolg,padm ,r,t-dt)
    pas = majpas(p2,pvp)
! =====================================================================
! --- CALCULS UNIQUEMENT SI PRESENCE DE THERMIQUE ---------------------
! =====================================================================
    if (yate .eq. 1) then
! =====================================================================
! --- CALCUL DES COEFFICIENTS DE DILATATIONS ALPHA SELON FORMULE DOCR -
! =====================================================================
        alp11 = dileau(sat,phi,alphfi,alpliq)
        alp12 = dilgaz(sat,phi,alphfi,t )
        alp21 = dilgaz(sat,phi,alphfi,t )
        h11 = congem(adcp11+ndim+1)
        h12 = congem(adcp12+ndim+1)
! ======================================================================
! --- CALCUL DE LA CAPACITE CALORIFIQUE SELON FORMULE DOCR -------------
! ======================================================================
        call capaca(rho0, rho11, rho12, rho21, rho22,&
                    sat, phi, csigm, cp11, cp12,&
                    cp21, cp22, dalal, t, coeps,&
                    retcom)
! =====================================================================
! --- PROBLEME LORS DU CALCUL DE COEPS --------------------------------
! =====================================================================
        if (retcom .ne. 0) then
            goto 30
        endif
! ======================================================================
! --- CALCUL DES ENTHALPIES SELON FORMULE DOCR -------------------------
! ======================================================================
        if ((option.eq.'RAPH_MECA') .or. (option(1:9).eq.'FULL_MECA')) then
            congep(adcp11+ndim+1) = congep(adcp11+ndim+1) + enteau(dt, alpliq,t,rho11,dp2,dp1,dpa&
                                    &d,signe,cp11)
            congep(adcp12+ndim+1) = congep(adcp12+ndim+1) + entgaz(dt, cp12)
            congep(adcp21+ndim+1) = congep(adcp21+ndim+1) + entgaz(dt, cp21)
            congep(adcp22+ndim+1) = congep(adcp22+ndim+1) + entgaz(dt, cp22)
            h11 = congep(adcp11+ndim+1)
            h12 = congep(adcp12+ndim+1)
! ======================================================================
! --- CALCUL DE LA CHALEUR REDUITE Q' SELON FORMULE DOCR ---------------
! ======================================================================
            congep(adcote) = congep(adcote) + calor(mdal,t,dt,deps, dp1,dp2,signe,alp11,alp12,coe&
                             &ps,ndim)
        endif
    endif
! ======================================================================
! --- CALCUL SI PAS RIGI_MECA_TANG -------------------------------------
! ======================================================================
    if ((option.eq.'RAPH_MECA') .or. (option(1:9).eq.'FULL_MECA')) then
! ======================================================================
! --- CALCUL DES CONTRAINTES DE PRESSIONS ------------------------------
! ======================================================================
        if (yamec .eq. 1) then
            call sigmap(net, bishop, sat, signe, tbiot,&
                        dp2, dp1, sigmp)
            do 10 i = 1, 3
                congep(adcome+6+i-1)=congep(adcome+6+i-1)+sigmp(i)
 10         continue
            do 11 i = 4, 6
                congep(adcome+6+i-1)=congep(adcome+6+i-1)+sigmp(i)*&
                rac2
 11         continue
        endif
! ======================================================================
! --- CALCUL DES APPORTS MASSIQUES SELON FORMULE DOCR ------------------
! ======================================================================
        congep(adcp11) = appmas(m11m,phi,phim,sat,satm,rho11, rho11m, epsv,epsvm)
!
        congep(adcp12) = appmas(m12m,phi,phim,1.0d0-sat, 1.0d0-satm, rho12,rho12m,epsv,epsvm)
        congep(adcp21) = appmas(m21m,phi,phim,1.0d0-sat, 1.0d0-satm, rho21,rho21m,epsv,epsvm)
        congep(adcp22) = appmas(m22m,phi,phim,sat,satm,rho22, rho22m, epsv,epsvm)
    endif
! **********************************************************************
! *** CALCUL DES DERIVEES **********************************************
! **********************************************************************
! ======================================================================
! --- CALCUL DES DERIVEES PARTIELLES DES PRESSIONS SELON FORMULES DOCR -
! --- UNIQUEMENT POUR LES OPTIONS RIGI_MECA ET FULL_MECA ---------------
! ======================================================================
    if ((option(1:9).eq.'RIGI_MECA') .or. (option(1:9).eq.'FULL_MECA')) then
        call dplvga(yate, rho11, rho12, r, t,&
                    kh, congem, dimcon, adcp11, adcp12,&
                    ndim, padp, dp11p1, dp11p2, dp12p1,&
                    dp12p2, dp21p1, dp21p2, dp11t, dp12t,&
                    dp21t)
        if (yamec .eq. 1) then
! ======================================================================
! --- CALCUL UNIQUEMENT EN PRESENCE DE MECANIQUE -----------------------
! ======================================================================
! --- CALCUL DES DERIVEES DE SIGMAP ------------------------------------
! ======================================================================
            call dspdp1(net, bishop, signe, tbiot, sat,&
                        dsdp1)
            call dspdp2(net, bishop, tbiot, dsdp2)
            do 22 i = 1, 3
                dsde(adcome+6+i-1,addep1)=dsde(adcome+6+i-1,addep1)&
                +dsdp1(i)
                dsde(adcome+6+i-1,addep2)=dsde(adcome+6+i-1,addep2)&
                +dsdp2(i)
 22         continue
            do 33 i = 4, 6
                dsde(adcome+6+i-1,addep1)=dsde(adcome+6+i-1,addep1)&
                +dsdp1(i)*rac2
                dsde(adcome+6+i-1,addep2)=dsde(adcome+6+i-1,addep2)&
                +dsdp2(i)*rac2
 33         continue
! ======================================================================
! --- CALCUL DES DERIVEES DES APPORTS MASSIQUES ------------------------
! --- UNIQUEMENT POUR LA PARTIE MECANIQUE ------------------------------
! ======================================================================
            call dmdepv(rho11, sat, tbiot, dmdeps)
            do 12 i = 1, 6
                dsde(adcp11,addeme+ndim-1+i) = dsde(adcp11,addeme+ ndim-1+i) + dmdeps(i)
 12         continue
            call dmdepv(rho12, 1.0d0-sat, tbiot, dmdeps)
            do 13 i = 1, 6
                dsde(adcp12,addeme+ndim-1+i) = dsde(adcp12,addeme+ ndim-1+i) + dmdeps(i)
 13         continue
            call dmdepv(rho21, 1.0d0-sat, tbiot, dmdeps)
            do 14 i = 1, 6
                dsde(adcp21,addeme+ndim-1+i) = dsde(adcp21,addeme+ ndim-1+i) + dmdeps(i)
 14         continue
            call dmdepv(rho22, sat, tbiot, dmdeps)
            do 15 i = 1, 6
                dsde(adcp22,addeme+ndim-1+i) = dsde(adcp22,addeme+ ndim-1+i) + dmdeps(i)
 15         continue
        endif
        if (yate .eq. 1) then
! ======================================================================
! --- CALCUL UNIQUEMENT EN PRESENCE DE THERMIQUE -----------------------
! ======================================================================
! --- CALCUL DES DERIVEES DES ENTHALPIES -------------------------------
! ======================================================================
            dsde(adcp11+ndim+1,addep2) = dsde(adcp11+ndim+1,addep2) + dhw2p2(dp11p2,alpliq,t,rho1&
                                         &1)
            dsde(adcp11+ndim+1,addep1)=dsde(adcp11+ndim+1,addep1)&
            + dhw2p1(signe,dp11p1,alpliq,t,rho11)
            dsde(adcp11+ndim+1,addete)=dsde(adcp11+ndim+1,addete)&
            + dhw2dt(dp11t,alpliq,t,rho11,cp11)
            dsde(adcp12+ndim+1,addete)=dsde(adcp12+ndim+1,addete)&
            + dhdt(cp12)
            dsde(adcp21+ndim+1,addete)=dsde(adcp21+ndim+1,addete)&
            + dhdt(cp21)
            dsde(adcp22+ndim+1,addete)=dsde(adcp22+ndim+1,addete)&
            + dhdt(cp22)
! ======================================================================
! --- CALCUL DES DERIVEES DES APPORTS MASSIQUES ------------------------
! --- UNIQUEMENT POUR LA PARTIR THERMIQUE ------------------------------
! ======================================================================
            dsde(adcp11,addete) = dsde(adcp11,addete) + dmwdt(rho11, phi,sat,cliq,dp11t,alp11)
            dsde(adcp22,addete) = dsde(adcp22,addete) + dmadt(rho22, sat,phi,mamolg,dp21t,kh,alph&
                                  &fi)
            dsde(adcp12,addete) = dsde(adcp12,addete) + dmvpdt(rho12, sat,phi,h11,h12,pvp,t,alp12&
                                  &)
            dsde(adcp21,addete) = dsde(adcp21,addete) + dmasdt(rho12, rho21,sat,phi,pas,h11,h12,t&
                                  &,alp21)
! ======================================================================
! --- CALCUL DE LA DERIVEE DE LA CHALEUR REDUITE Q' --------------------
! ======================================================================
            dsde(adcote,addete)=dsde(adcote,addete)+dqdt(coeps)
            dsde(adcote,addep1)=dsde(adcote,addep1)+dqdp(signe,alp11,&
            t)
            dsde(adcote,addep2)=dsde(adcote,addep2) - dqdp(signe,&
            alp11+alp12,t)
! ======================================================================
! --- CALCUL DE LA DERIVEE DE LA CHALEUR REDUITE Q' --------------------
! --- UNIQUEMENT POUR LA PARTIE MECANIQUE ------------------------------
! ======================================================================
            if (yamec .eq. 1) then
                call dqdeps(mdal, t, dqeps)
                do 20 i = 1, 6
                    dsde(adcote,addeme+ndim-1+i) = dsde(adcote,addeme+ ndim-1+i) + dqeps(i)
 20             continue
            endif
        endif
! ======================================================================
! --- CALCUL DES DERIVEES DES APPORTS MASSIQUES ------------------------
! --- POUR LES AUTRES CAS ----------------------------------------------
! ======================================================================
        dsde(adcp11,addep1) = dsde(adcp11,addep1) + dmwdp1(rho11, signe,sat,dsatp1,phi,cs,cliq,-d&
                              &p11p1, emmag,em)
        dsde(adcp11,addep2) = dsde(adcp11,addep2) + dmwdp2(rho11,sat, phi,cs,cliq,dp11p2, emmag,e&
                              &m)
        dsde(adcp22,addep1) = dsde(adcp22,addep1) + dmadp1(rho22,sat, dsatp1,phi,cs,mamolg,kh,dp2&
                              &1p1, emmag,em)
        dsde(adcp22,addep2) = dsde(adcp22,addep2) + dmadp2(rho22,sat, phi,cs,mamolg,kh,dp21p2, em&
                              &mag,em)
        dsde(adcp12,addep1) = dsde(adcp12,addep1) + dmvdp1(rho11, rho12,sat,dsatp1,phi,cs,pvp, em&
                              &mag,em)
        dsde(adcp12,addep2) = dsde(adcp12,addep2) + dmvdp2(rho11, rho12,sat,phi,cs,pvp, emmag,em)
        dsde(adcp21,addep1) = dsde(adcp21,addep1) + dmasp1(rho11, rho12,rho21,sat,dsatp1,phi,cs,p&
                              &2-pvp, emmag,em)
        dsde(adcp21,addep2) = dsde(adcp21,addep2) + dmasp2(rho11, rho12,rho21,sat,phi,cs,pas, emm&
                              &ag,em)
    endif
! ======================================================================
 30 continue
! ======================================================================
end subroutine
