/*           CONFIGURATION MANAGEMENT OF EDF VERSION                  */
/* MODIF MEMPID utilitai  DATE 06/07/2009   AUTEUR LEFEBVRE J-P.LEFEBVRE */
/* ================================================================== */
/* COPYRIGHT (C) 1991 - 2009  EDF R&D              WWW.CODE-ASTER.ORG */
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
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "aster.h"
/*
** Cette fonction permet de consulter le systeme de fichier /proc sous Unix
** et renvoie la memoire en octets consommee par le processus.
** Elle accede aux valeurs VmData et VmSize .
** La valeur retournee vaut VmStk.
**
** Le numero du processus est recupere par getpid
*/
INTEGER DEFP (MEMPID, mempid, INTEGER *val) 
{
        static char filename[80];
        static char sbuf[1024];
        char* S;
	int fd, num_read;
	long *numpro,lmem;
#ifdef _POSIX
        pid_t getpid(void);
	
	numpro = getpid();

        sprintf(filename, "/proc/%ld/status", numpro);
        fd = open(filename, O_RDONLY, 0);
        if (fd==-1) return -1;
	num_read=read(fd,sbuf,(sizeof sbuf)-1);
/*	printf (" contenu du buffer = %s\n",sbuf); */	
        close(fd);
	
        S=strstr(sbuf,"VmData:")+8;
        val[0] = atoi(S); 

	S=strstr(sbuf,"VmSize:")+8;
        val[1] = atoi(S); 

	S=strstr(sbuf,"VmStk:")+7;
        lmem = atoi(S);

        return lmem ;
#else
/* 
** Pour retourner des valeurs sous Windows
*/
        val[0] = 0 ;
	val[1] = 0 ;
        return -1 ;
#endif
}
