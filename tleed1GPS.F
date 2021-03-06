
C  file LEEDSATL.M1  Feb. 29, 1996
C
C***************************************************************************
C  Symmetrized Automated Tensor LEED (SATLEED):  program TLEED1.FOR
C  Version 4.1 of Automated Tensor LEED
C
Cga      PROGRAM TLEED1V4
CGPS      subroutine tleed1(dir,rank)
      subroutine tleed1(problem_dir,dir,rank,nerror_report)

      character*(*) problem_dir
      character*(*) dir
      character*(*) rank
c      subroutine tleed1(tleed5i,shortt)
CGPS      character*32 tleed4i, tleed5i, shortt, tleedo
      character*100 tleed4i, tleed5i, shortt, tleedo
      integer nerror_report
C 
C PROGRAM DESCRIPTION: 
C -------------------
C 
C        First pass symmetric Tensor LEED program. 
C This code runs the calculation for
C the reference structure and returns the tensors via the dump file for input
C to TLEED2.
C
C AUTHORS: 
C -------
C 
C        A. Barbieri. Modified version of TLEED1V3 by A. Barbieri.
C                     Original version TLEED1V1.1 by Rous and Wander.
C                     Further modifications by R. Doell.
C
C CREATION DATE:         February 1996
C -------------
C 
C
C Changed in order to correct inconsistencies detected by fortran forcheck
C program "Fortran lint". All changes are marked with
C "C++++" (M. Gierer, 7/97).
C
C ============================================================================
C
C Parameter statements for array dimensions carried over from the 
C Van Hove/Tong package.
C
C ============================================================================
C
C       IPLMAX          The largest l value to be used (LMAX).
C       IPCLM           The number of Clebsch Gorden coefficients required for
C                       the current value of LMAX. (see data statement
C                       for NLMS).
C
C ============================================================================
C
      PARAMETER (IPLMAX=8,IPCLM=23000)
C
C ============================================================================
C
C Additional parameter statements for composite layers.
C
C ============================================================================
C
C     INLAY         Maximum number of subplanes in any composite layer.
C     INTAU         No of chemical elements for which phase shifts are
C                   input
C     IPCAA         Dimension of CAA (see data statement).
C     INST1         Number of Layers for which data is input.
C     INST2         Number of overlayers for which data is input.
C     INST1B        maximum # of symmetry reduced bulk layers
C
C ============================================================================
C
      PARAMETER (INLAY=66,INTAU=4,IPCAA=26000)
      PARAMETER (INST1=5,INST2=2,INST1B=3)
C
C ============================================================================
C
C Parameter statements specific to TLEED
C
C ============================================================================
C
C INT0              Number of beams for which the tensor is to be calculated
C                   (Number of exit beams)
C IPCUT             Maximum size of Q after truncation.
C JSMAX             Maximum L value used in expansion [=< sqrt(2*e)*mod(r)]
C NLMB2             Number of Gaunt coeficients required. (See header of
C                   subroutine GAUNT or comment after DATA).
C NROM              Maximum (symmetry unreduced) dimension of substrate  
C                   matrices computed in MSMFT
C ============================================================================
C
      PARAMETER (INT0=20,IPCUT=45,JSMAX=4)
      PARAMETER (NLMB2=10000,NROM=973)
C
C ============================================================================
C
C Parameter statements related to symmetric calculation
C
C ============================================================================
C
C  INST1B = maximum # of symmetry reduced bulk layers
C  NROMR and NROM2R same of NROM, NROM2 but reduced by symmetry
C            NROMR is the maximum (symmetry reduced) dimension of the overlayer
C            matrices(ROM,TOM,ROP,TOP)
C            This is the maximum number of beams entering the 
C            symmetric RFS calculation at each energy.
C  JLMNI     same as JLMN but reduced by symmetry. It sets the dimension
C            of the matrix TH
C  INLTOT    is the total number of sublayers in all CL's
C  INLIN     Total number of inequivalent subplanes in all composite layers
C
      PARAMETER (INLTOT=68,NROMR=137,NROM2R=85)
      PARAMETER (INLIN=25)
c      PARAMETER (JLMNI=160,JLMNI2=160)
      PARAMETER (JLMNI=320,JLMNI2=550)
C
C ============================================================================
C
C The following parameters are constructed from the Van Hove/Tong parameters.
C
C ============================================================================
C
C       IPNL1          }Superlattice characterization codes
C       IPNL2          }Dimensions are chosen sufficiently large to treat
C                      }a 10x10 superstructure
      PARAMETER (IPNL1=10,IPNL2=10)
      PARAMETER (JPKLM=(2*IPLMAX+1)*(2*IPLMAX+2)/2)
      PARAMETER (JPN=2*IPLMAX+1,JPNN=JPN*JPN)
      PARAMETER (JPNN2=IPLMAX+1,JPNN3=IPLMAX+1,JPNN1=JPNN2+JPNN3-1)
      PARAMETER (JLMMAX=JPNN2*JPNN2,JPL1=JPNN2,JPLEV=JPNN2*(JPNN2+1)/2)
      PARAMETER (JLSMAX=(IPLMAX+JSMAX+1)**2)
      PARAMETER (JPLOD=JLMMAX-JPLEV,JPNL=IPNL1*IPNL2)
      PARAMETER (JLMT=INTAU*JLMMAX)
      PARAMETER (JLMT2=INTAU*JLSMAX)
      PARAMETER (JNLAY2=INLAY*(INLAY-1))
      PARAMETER (JLMN=INLAY*JLMMAX,JLM2N=2*JLMN,JLEV2=2*JPLEV)
      PARAMETER (JLMSN=INLAY*JLSMAX)
      PARAMETER (JSMMAX=(JSMAX+1)*(JSMAX+1))
C
C ============================================================================
C
C Dimension Arrays.
C
C ============================================================================
C
      DIMENSION ARA1(2),ARA2(2),RAR1(2),RAR2(2),ASA(10,3),ARB1(2)
      DIMENSION ARB2(2),RBR1(2),RBR2(2),ASB(INST1,3),ASC(3),ASD(3)
      DIMENSION V(JPNL,2),JJS(JPNL,6)
      DIMENSION KNB(60),NBAL(60),SPQF(2,NROM),SPQ(2,NROM)
      DIMENSION PQFAL(2,NROM),PQAL(2,NROM)
      DIMENSION NTAUAW(INST1)
      DIMENSION ES(90),PHSS(90,80),PHSS2(90,80)
      DIMENSION NLMS(15),CLM(IPCLM),YLM(JPNN),FAC2(JPNN),FAC1(JPN)
      DIMENSION PPP(JPNN1,JPNN2,JPNN3)
      DIMENSION LX2(JLSMAX),LXI2(JLSMAX),LXM2(JLSMAX),LT2(JLSMAX)
      DIMENSION LX(JLMMAX),LXI(JLMMAX),LXM(JLMMAX),LT(JLMMAX)
      DIMENSION FPOS(INLAY,3),VPOS(INST1,INLAY,3),LPS(INLAY)
      DIMENSION LPSS(INLAY)
      DIMENSION CPVPOS(INST1,INLAY,3),LLFLAG(INLTOT)
      DIMENSION LLF2(INLTOT),LLF3(INLTOT),NDIML(INLTOT)
      DIMENSION NL9(INLTOT,INLIN),NEQ(INLIN)
      DIMENSION CAA(IPCAA),NCA(15),LAFLAG(INST1)
      DIMENSION LPSAW(INST1,INLAY),LPSAWS(INST1,INLAY),PSQ(2,INT0)
      DIMENSION POSS(INLAY,3),POSS2(INLAY,3),AK2M(INT0),AK3M(INT0)
      DIMENSION MGH(INLAY,INLAY),NUGH(JNLAY2),IPL(JLMNI)
      DIMENSION TEST(JNLAY2),DRL(JNLAY2,3)
      DIMENSION IT1(5),DRPAR1(5),DR01(5),DRPER1(5)
      DIMENSION PQFEX(2,INT0),PQFEX2(2,INT0),NINSET(20)
      DIMENSION DISP(INLTOT,3),G(2,NROM)
      DIMENSION MICUT(IPCUT),MJCUT(IPCUT),BELM2(NLMB2)
      DIMENSION VICL(INST1),VCL(INST1),FRCL(INST1)
C
C Now complex arrays
C
      COMPLEX CTR(JLMMAX),CTT(JLMMAX)
      COMPLEX VVST(JLMNI)
      COMPLEX TH(JLMNI,JLMNI)
C      COMPLEX TSTORE(2,JLMNI,NROMR,INST2)
      COMPLEX TSTORE(2,JLMNI2,NROMR,INST2)
      COMPLEX TAU(JLMT,JPLEV),RG(4,INLAY,NROMR)
      COMPLEX TS(JLMNI),TS2(JLMNI2),TG(2,JLM2N),VT(JLM2N),TAUG(JLMT)
      COMPLEX TAUGM(JLMT),TAUG2(JLMT2),TAUGM2(JLMT2),VT2(JLSMAX)
      COMPLEX ROP(NROMR,NROMR,INST2),TOP(NROMR,NROMR,INST2)
      COMPLEX ROM(NROMR,NROMR,INST2),TOM(NROMR,NROMR,INST2)
      COMPLEX XEVM(JPLEV,JLEV2),AMPPLW(NROMR,2,INST1)
      COMPLEX AF(JPL1),CAF(JPL1),TSF0(6,16),TSF(6,16)
      COMPLEX XIST(INT0)
      COMPLEX AMULT(NROMR),CYLM(NROMR,JLSMAX)
      COMPLEX VL(JPNL,2),FLMS(JPNL,JPKLM),FLM(JPKLM),QCUT(IPCUT)
      COMPLEX XI(NROMR),PK(NROMR,8),AW(NROMR,2)
      COMPLEX PKCL(NROMR,8,INST1),ANEW(NROMR,30)
      COMPLEX ALM(INLAY,JLSMAX),EXLM(INLAY,JLSMAX),Q(JSMMAX,JSMMAX)
      COMPLEX A0LM(JLSMAX),GA(INLIN,JLMMAX,JSMMAX)
      COMPLEX GB(1,JLMMAX,JSMMAX)
C
C Symmetry arrays
C
      DIMENSION IND1(NROM),IND2(NROM),LPOINT(INLIN),LMNBD(2,INST1)
      DIMENSION LMNBD2(2,INST1)
      DIMENSION LAFLAG2(INLTOT,INST1),ZRED(JLMNI,INST1)
      DIMENSION ZRED2(JLMNI2,INST1)
      DIMENSION ILOOK(12,INLTOT),DIREC(INLTOT,2,2),LSFLAG(INLTOT)
      DIMENSION ACOORD(12,INLTOT,3),INDOM(18),ADISP(INLTOT,3)
      DIMENSION INDBD(9),ILKBD(12,INLAY,INST1),NINEQ(INST1)
      DIMENSION LPBD(INLAY,INST1),LAN(JLSMAX),IKRED(NROMR)
      DIMENSION IKBS(NROMR)
      DIMENSION IDXN(JLMN,INST1),IDXS(JLMN,INST1),IDXK(NROM)
      DIMENSION IDXN2(JLMSN,INST1),IDXS2(JLMSN,INST1)
      DIMENSION IDXK2(NROM),IWK(NROMR),SPWK(2,NROMR)
      DIMENSION IIDXK2(NROMR),IIDXK(NROM),IIKRED(NROMR)
      DIMENSION SPQS(2,NROMR),SPQFS(2,NROMR)
      DIMENSION PQF(2,NROMR),PQ(2,NROMR)
C 20 in NB and KSNB is the maximum number of symmetric beamsets
C 60 in NSHBS,NBAL,KNB and IMIN is the maximum number of beamsets
      DIMENSION NB(20),KOUNT(JLMMAX,JLMMAX),PH4(12,NROMR)
      DIMENSION KSNB(20),NSHBS(60),IMIN(60),VEC(2,INST1B)
      DIMENSION IMAX(60)
      DIMENSION INDK3(NROMR),PH3(36,NROMR),PQ3(2,NROMR)
      COMPLEX TAUINV(JLMT,JPLEV),WBDS(JLMN,INST1)
      COMPLEX WBDS2(JLMSN,INST1)
      COMPLEX RA1R(NROMR,NROM2R,INST1B),TA1R(NROMR,NROM2R,INST1B)
      COMPLEX RA2R(NROMR,NROM2R,INST1B),TA2R(NROMR,NROM2R,INST1B)
      COMPLEX CYTR(JLMNI,NROMR),CYTT(JLMNI,NROMR)

C
C Final character arrays
C
      CHARACTER*4 TITLE(20)
C
C ============================================================================
C
C Common blocks carried over from Van Hove/Tong package. No common blocks are
C used in the routines specific to TLEED.
C
C ============================================================================
C
      COMMON E3,AK21,AK31,VPI1,TV,EMACH
      COMMON /X4/E,VPI,AK2,AK3
      COMMON /SL/ARA1,ARA2,ARB1,ARB2,RBR1,RBR2,NL1,NL2
      COMMON /DIM/NDOMS,NSYMS
      COMMON /MS/LMAX
      COMMON /ADS/ASL,FR,ASE,VPIS,VPIO,VO,VV
      COMMON /BT/IT,T,T0,DRPER,DRPAR,DR0
      COMMON /TEMP/IT1,TI,T01,DRPER1,DRPAR1,DR01
      COMMON /MPT/NA,NS,LAY,L1,NTAU,TSTS,TV1,DCUT,NPERT,NOPT,NEW
C++++
      COMMON /ZMAT/IANZ(40),IZ(40,4),BL(40),AALPHA(40),BBETA(40),NZ,
     & IPAR(15,5),NIPAR(5),NPAR,DX(5),NUM,NATOMS,BLS(40),ALPHAS(40),
     & BETAS(40),PHIR,PHIM1,PHIM2
C++++
      INTEGER DFLAG
C
C==========================================================================
C
C INDOM is the number of symmetry equivalent domains for
C symmetry code NSYM
C INDBD is the number of symmetry equivalent domains needed in the
C block diagonalization 
C
C==========================================================================
C
      DATA INDOM(1),INDOM(2),INDOM(3),INDOM(4),INDOM(5),INDOM(6),INDOM
     & (7),INDOM(8),INDOM(9),INDOM(10),INDOM(11),INDOM(12),INDOM(13),
     & INDOM(14),INDOM(15),INDOM(16),INDOM(17),INDOM(18)/1,2,2,2,2,2,4,
     & 4,4,8,3,6,6,2,4,4,6,12/
      DATA INDBD(1),INDBD(2),INDBD(3),INDBD(4),INDBD(5),INDBD(6),INDBD
     & (7),INDBD(8),INDBD(9)/1,2,3,4,6,4,6,8,12/
C
C ============================================================================
C
C Data statements carried over from Van Hove/Tong package.
C
C ============================================================================
C
C  NLMS is dimension of CLM as a function of LMAX.
C
      DATA NLMS(1),NLMS(2),NLMS(3),NLMS(4),NLMS(5),NLMS(6),NLMS(7),
     &NLMS(8),NLMS(9),NLMS(10),NLMS(11),NLMS(12)
     &/70,76,284,809,1925,4032,7680,13593,22693,36124,55276,81809/
C
C  NCA is dimension of CAA as a function of LMAX.
C
      DATA NCA(1),NCA(2),NCA(3),NCA(4),NCA(5),NCA(6),NCA(7),NCA(8),
     &NCA(9),NCA(10),NCA(11),NCA(12)
     &/19,126,498,1463,3549,7532,14484,25821,43351,69322,106470,
     & 158067/
C
C NLMB2 against L used for atomic scattering LMAX and the number used for
C the single centre expansion of the Q matrix.
C
C                                 JSMAX                                 
C                                                                       
C      |     0    1     2     3     4     5     6    
CIPLMAX+--------------------------------------------------------------- 
C  1   |     4    19    48    91   148   219   304     
C  2   |     9    48   126   248   414   624   878    
C  3   |    16    91   248   498   848  1298  1848     
C  4   |    25   148   414   848  1463  2268  3263    
C  5   |    36   219   624  1298  2268  3549  5152     
C  6   |    49   304   878  1848  3263  5152  7532     
C  7   |    64   403  1176  2498  4448  7077 10416    
C  8   |    81   516  1518  3248  5823  9324 13804     
C  9   |   100   643  1904  4098  7388 11893 17696    
C 10   |   121   784  2334  5048  9143 14784 22092   
C ============================================================================
C
C  Format statements.
C
C ============================================================================
C
100   FORMAT (3F7.2)
101   FORMAT (20I3)
102   FORMAT (/8H IDEG = ,1I3)
103   FORMAT (8H VPIS = ,F9.4,8H VPIO = ,F9.4,9H DCUTS = ,F9.4,
     & 9H DCUTO = ,F9.4)
104   FORMAT (8H TEMP = ,F9.4)
105   FORMAT (/' 1ST PASS TLEED...REFERENCE STRUCTURE CALCULATION ')
106   FORMAT (20H CORRECT TERMINATION)
107   FORMAT (20A4)
109   FORMAT (//,' STARTING LOOP OVER ENERGIES ',/)
110   FORMAT (/,'====================================================',
     & /)
111   FORMAT (' ERROR LSMAX BIGGER THAN DIMENSIONED')
112   FORMAT (2I3,2F7.4)
113   FORMAT (' CPU TIME = ',F9.2,' SECONDS ')
114   FORMAT (' ERROR: The parameter JLMNI must be at least',I4 )
1144  FORMAT (' ERROR: The parameter JLMNI2 must be at least',I4 )
115   FORMAT (' ERROR: The parameter INLTOT must be at least',I4 )
116   FORMAT (' ERROR: The parameter INT0 must be at least',I4 )
117   FORMAT (' ERROR: The parameter INLIN must be at least',I4 )
118   FORMAT (' ERROR: The parameter IPLMAX must be at least',I4 )
119   FORMAT (' ERROR: The parameter INTAU must be at least',I4 )
120   FORMAT (' ERROR: The parameter INST1 must be at least',I4 )
121   FORMAT (' ERROR: The parameter INLAY must be at least',I4 )
122   FORMAT (' ERROR: IPNL1 and IPNL2 are not large enough' )
123   FORMAT (' ERROR: The parameter IPCUT must be at least',I4, 
     &  ' or decrease LSMAX, LLCUT in tleed4.i'  )
124   FORMAT (' ERROR: The parameter JSMAX must be at least',I4, 
     &  ' or decrease LSMAX in tleed4.i'  )
C
C ============================================================================
C
C Open I/O channels.
C
C ============================================================================
C
C First input channels
C
CPC      OPEN (UNIT=*,FILE='con',STATUS='OPEN')
CGPS      tleed4i = 'work'//dir//'/tleed4i'//rank
      tleed4i = problem_dir//'/work'//dir//'/tleed4i'//rank
      OPEN (UNIT=4,FILE=tleed4i,STATUS='OLD')
Cga      OPEN (UNIT=5,FILE='tleed5.i',STATUS='OLD')
CGPS      tleed5i = 'work'//dir//'/tleed5i'//rank
      tleed5i = problem_dir//'/work'//dir//'/tleed5i'//rank
      OPEN (UNIT=5,FILE=tleed5i,STATUS='OLD')
      rewind(4)
      rewind(5)
C
C Now output channels
C
Cga      OPEN (UNIT=1,FILE='tleed.o',STATUS='NEW')
C      OPEN (UNIT=22,FILE='short.t',STATUS='NEW')
Cga      OPEN (UNIT=22,FILE='short.t',STATUS='NEW',FORM='unformatted')
Cga      OPEN (UNIT=1,FILE=tleed,STATUS='NEW')
CGPS      tleedo = 'work'//dir//'/tleedo'//rank
      tleedo = problem_dir//'/work'//dir//'/tleedo'//rank
      OPEN (UNIT=1,FILE=tleedo,STATUS='unknown')
c      shortt = dir // '/short' // rank
CGPS      shortt = 'work'//dir//'/shortt'//rank
      shortt = problem_dir//'/work'//dir//'/shortt'//rank
      OPEN (UNIT=22,FILE=shortt,STATUS='unknown',FORM='unformatted')
      rewind(1)
      rewind(22)

C
C ============================================================================
C
C Start of Executable Code
C
C ============================================================================
C
CPC               WRITE (*,998)
CPC998            FORMAT (' *** STARTING REFERENCE CALCULATION *** ')
C
C      I1=MCLOCK()
      nerror_report=0
      READ (5,107) (TITLE(I),I=1,20)
      WRITE (1,107) (TITLE(I),I=1,20)
      WRITE (1,105)
C
C  EMACH is machine accuracy.
C
      EMACH=1.0E-6
C
C Read in pass number, print control parameter and dummy parameter for
C consistency with TLEED2
C
      READ (4,101) IPR,ISTART
C
C NSYM is symmetry code of surface
C It specifies the spatial symmetry to be used in MTNVSYM       
C
      READ (4,112) NSYM,NSYMS,ASTEP,VSTEP
      NDOMS=INDOM(NSYMS)
C
C Read in number of beams NT0, number of beam sets NSET, and the cut off
C radii for the pertubation expansion LSMAX and LLCUT
C
      READ (4,101) NT0,NSET,LSMAX,LLCUT
      IF(LSMAX.GT.JSMAX) THEN
	 WRITE(1,124) LSMAX
	 GOTO 1400
      ENDIF
      IF(NT0.GT.INT0) THEN
	 WRITE(1,116) NT0
	 GOTO 1400
      ENDIF
    
C
C  IDEG: rotational symmetry of each layer.
C
C  NL1, NL2  Superlattice Characterization (calculated in READT1)
C
      READ (5,101) IDEG
      IF (IPR.GT.0) THEN
	 WRITE (1,102) IDEG
      ENDIF
C
C  NPSI   = No. of energies at which phase shifts are read in.
C
      READ (5,101) NPSI
C
C Read in geometry, physical parameters and convergence criteria.
C
      CALL READT1(TVA,RAR1,RAR2,INVECT,TVB,IDEG,NL,TST,
     & THETA,FI,LMMAX,NPSI,ES,PHSS,L1,IPR,NEL,
     & IPNL1,IPNL2)
C
      CALL READT2(ASA,INVECT,IDEG,NL,V,VL,JJS,IPR)
C
      IF(NL.GT.IPNL1*IPNL2) THEN
	 write(1,122)
	 GOTO 1400
      ENDIF
      IF(LMAX.GT.IPLMAX) THEN
	 write(1,118) LMAX
	 GOTO 1400
      ENDIF
      IF(NEL.GT.INTAU) THEN
	 write(1,119) NEL
	 GOTO 1400
      ENDIF
C
C prepare for phase shift interpolation to be performed in TSCATF
C through a cubic spline interpolation routine from Numerical Recipes
C
      CALL FORSPLINE(NEL,L1,NPSI,PHSS,ES,PHSS2)
C
C PHSS contains the tabulated phase shifts, PHSS2 contains the second derivative
C of PHSS (as a function of the energy) which will be needed in TSCATF
C
C NST1   = Number of composite layers in input.
C LAFLAG = Number of layers in each composite layer.
C NLAY   = Max. no. of subplanes in any composite layer.(ie MAX(LAFLAG)
C
      NLAY=0
      NLAYTOT=0
Cga this variable must be initialized for repeated calls
      NLTOT2=0
      READ (5,101) NST1,NSTEF,NDTENS
      IF(NST1.GT.INST1) THEN
	 WRITE(1,120) NST1
	 GOTO 1400
      ENDIF
      NBULK=NST1-NSTEF
      IF (NDTENS.NE.1.AND.NDTENS.NE.3) pause 'NDTENS must be 1 or 3'
      READ (5,101) (LAFLAG(I), I=1,NST1)
      DO 348 I=1,NST1
	 IF (LAFLAG(I).GT.NLAY) NLAY=LAFLAG(I)
	 NLTOT2=NLTOT2+LAFLAG(I)
	 IF (I.LE.NSTEF) NLAYTOT=NLAYTOT+LAFLAG(I)
348   CONTINUE
      IF(NLTOT2.GT.INLTOT) THEN
	 WRITE(1,115) NLTOT2
	 GOTO 1400
      ENDIF
      NLMAX=NLAY
      IF(NLMAX.GT.INLAY) THEN
	 WRITE(1,121) NLMAX
	 GOTO 1400
      ENDIF
      CALL READCT(NLAY,VPOS,FPOS,POSS,CPVPOS,NTAUAW,LPSAW,IPR,
     & LAFLAG,NST1,ASB,VICL,VCL,FRCL,TST,TSTS,ASA,INVECT)
C
C some symmetry reduction. About the maximal symmetry
C (to be used to restrict K beams, reduce TH matrix, and tensor storage space) 
C from LOOKIN. 
C
      NSHIFT=0
      DO 351 NCL=1,NST1
	NLAY2=LAFLAG(NCL)
	CALL LOOKUP2(CPVPOS,ILOOK,ILKBD,NLAY2,NST1,NSTEF,NSYMS,
     &         NLTOT2,NSHIFT,NCL,NLMAX,IROT,IMIR,0,FPOS,POSS,POSS2,
     & nerror_report)
        if (nerror_report.eq.1) goto 9111 

	NSHIFT=NSHIFT+NLAY2
351   CONTINUE
      CALL DIMSCH2(ILOOK,NLTOT2,NDOMS,NNDIM,LSFLAG,LLFLAG,
     % NDIML,DIREC,ADISP,ACOORD,NDTENS,1,LLF2,LLF3,NL9,NEQ,
     & INLIN)
C
C produce coordinates of symmetry inequivalent atoms (from CPVPOS and LSFLAG)
C
CCC Parity needs correction
C
      NDOMBD=NDOMS
      CALL INEQCD(LSFLAG,LAFLAG,NST1,NLMAX,NLTOT2,
     &LAFLAG2,LPOINT,NLTIN,NST1,NINEQ,LPBD)
      IF(NLTIN.GT.INLIN) THEN
	 WRITE(1,117) NLTIN
	 GOTO 1400
      ENDIF
C
C Read in information relevant to the pertubative LEED calculation
C
      CALL READPL(NT0,NSET,PQFEX,NINSET,NDIM,DISP,
     & NLAYTOT,IPR,ALPHA1,BETA1,GAMMA,ITMAX,FTOL1,
     & FTOL2,MFLAG,LLFLAG,NGRID)
C
C obtain information about bulk symmetric matrices. How many (NST1B)
C are needed?
C
	  CALL SYMBLK(ASA,INVECT,NST1B,
     &    INST1B,ARA1,ARA2,NST1,NBULK,VEC)
C
C can symmetry be used in substrate calculation?
C
	NSU=0
	CSU1=ABS(ARA1(1)-ARB1(1))+ABS(ARA1(2)-ARB1(2))
	CSU2=ABS(ARA2(1)-ARB2(1))+ABS(ARA2(2)-ARB2(2))
	IF(CSU1+CSU2.LT.0.001) NSU=1
C
C Call MSET to obtain the reduction information for Q
C
      LMNMAX=NLAY*LMMAX
      LSMMAX=(LSMAX+1)*(LSMAX+1)
      LSM=(LMAX+LSMAX+1)**2
      LMSMAX=NLAY*LSM
      LM2=LMAX+LSMAX
      CALL MSET2(LSMAX,LLCUT,ICUT,MICUT,MJCUT,IPCUT,NDTENS)
      IF(ICUT.GT.IPCUT) THEN
	 WRITE(1,123) ICUT
	 GOTO 1400
      ENDIF
C
C Calculate Clebsch-Gordan coefficients
C
      T0=T01
      KLM=(2*LMAX+1)*(2*LMAX+2)/2
      LEV=(LMAX+1)*(LMAX+2)/2
      LEVV=(LMAX+LSMAX+1)*(LMAX+LSMAX+2)/2
      LOD=LMMAX-LEV
      LODD=LSM-LEVV
      LEV2=2*LEV
      NCAA=NCA(LMAX)
      CALL CAAA2(CAA,NCAA,LMMAX,KOUNT)
      N=2*LMAX+1
      NN=N*N
      NLM=NLMS(LMAX)
      CALL CELMG(CLM,NLM,YLM,FAC2,NN,FAC1,N,LMAX)
C
C  Calculate permutations of (L-M) sequence for tensor extension.
C  Only LT2,LXM2 will be used
C
      CALL LXGENT2(LX2,LXI2,LT2,LXM2,LM2,LSM,LAN)
C
C  Calculate permutations of (L-M) sequence.
C
      CALL LXGENT2(LX,LXI,LT,LXM,LMAX,LMMAX,LAN)
C
C Do temperature dependant phase shifts need calculating?
C
      IMARK=0
      DO 48 I=1,NEL
	 IMARK=IMARK+IT1(I)
48    CONTINUE
      NN3=LMAX+1
      NN2=LMAX+1
      NN1=NN2+NN3-1
      IF (IMARK.GT.0) THEN
C
C  PPP= Clebsch Gordan coefficients for computation of temperature
C       dependant phase shifts. (Skipped if not needed).
C
	 CALL CPPP(PPP,NN1,NN2,NN3)
      ENDIF
C
C Check size of JSMAX.
C
      IF (LSMAX.GT.JSMAX) THEN
	 WRITE (1,111)
      ELSE
C
C Calculate Clebsch-Gordan Coefficients required by TLEED code.
C
C         CALL GAUNT(BELM2,NLMB2,LMAX,LSMAX)
	 CALL GAUNT2(BELM2,NLMB2,LMAX,LSMAX)
C
	 T=TI
	 IF (IPR.GT.0) WRITE (1,104) T
C
C =============================================================================
C
C Begin loop over energy range.
C
C =============================================================================
C
C  Read energy range and step.
C
	 READ (5,100) EI,EF,DE
	 IF (EI.LT.0) THEN
	    WRITE (1,*) ' EI MUST BE > 0 '
	 ELSE
C
C Check normal incidence condition
C
	    IF(ABS(THETA).LE.0.001.AND.ABS(FI).LE.0.001) THEN
	       INI=1
	    ELSE
	       INI=0
	    ENDIF
C
C Generate required beamsets
C
	    DFLAG=0
	    EF2=EF+VV*27.21
	  CALL BEMGEN3(TST,EF2,SPQF,SPQ,KNBS,KNB,RAR1,RAR2,KNT,IPR,TVB,
     &      DFLAG,NROM,G,IDXK,NSYMS,NKRED,SPQFS,SPQS,IKRED,PQFEX,PQFEX2,
     &      NT0,IDXK2,IWK,SPWK,NROMR,KSNBS,KSNB,NK3,INDK3,PH3,PQ3,INI,
     &      NROM2R)
C
C symmetry information concerning the composite layer
C
	    DO 55 NCL=1,NST1
	       NLAY=LAFLAG(NCL)
	       LMNI=NLAY*LMMAX
	       CALL SYMCL(NINEQ,LAFLAG2,NDOMBD,IROT,IMIR,NLMAX,LMNI,
     &         NCL,LPBD,ILKBD,WBDS(1,NCL),IDXS(1,NCL),IDXN(1,NCL),
     &         ZRED(1,NCL),NST1,LMMAX,LX,LXM,LMNBD(1,NCL),NSU,NSTEF,
     &         NLAY)
	       LMNM=LMNBD(1,NCL)
	       IF(LMNBD(2,NCL).GT.LMNM) LMNM=LMNBD(2,NCL)
	       IF(LMNM.GT.JLMNI) THEN
		  WRITE(1,114) LMNM
		  GOTO 1400
	       ENDIF
C
C repeat call for tensor extension
C
	       LMNI2=NLAY*LSM
	       IF(NCL.LE.NSTEF) THEN
		 CALL SYMCL(NINEQ,LAFLAG2,NDOMBD,IROT,IMIR,NLMAX,LMNI2,
     &           NCL,LPBD,ILKBD,WBDS2(1,NCL),IDXS2(1,NCL),IDXN2(1,NCL),
     &           ZRED2(1,NCL),NST1,LSM,LX2,LXM2,LMNBD2(1,NCL),NSU,
     &           NSTEF,NLAY)
		 LMNM2=LMNBD2(1,NCL)
		 IF(LMNBD2(2,NCL).GT.LMNM2) LMNM2=LMNBD2(2,NCL)
		 IF(LMNM2.GT.JLMNI2) THEN
		    WRITE(1,1144) LMNM2
		    GOTO 1400
		 ENDIF
	       ENDIF
55          CONTINUE
C
C  Start loop over given energy range.
C
	    NGAW=INT((EF-EI)/DE)+1
	    WRITE (1,109)
	    WRITE (1,110)
	    DO 1300 IEEV=1,NGAW
	       EEV=EI+(IEEV-1)*DE
	       E=EEV/27.21+VV
	       E3=E
	       WRITE (1,*) ' CALCULATING FOR E= ',EEV
	       WRITE (1,110)
C
C  Set imaginary part of muffin tin potential. (Usually -4 or -5 eV)
C
	       VPIO=VPIS
	       DCUTO=SQRT(2.0*E)
C
C  Set limiting radii on lattice sums, possibly different for substrate
C  (DCUTS) and overlayer (DCUTO).
C
	       DCUTS=-4.0*DCUTO/(AMIN1(VPIS,-0.05))
	       DCUTO=-4.0*DCUTO/(AMIN1(VPIO,-0.05))
	       IF (IPR.GT.0) WRITE (1,103) VPIS,VPIO,DCUTS,DCUTO
C
C =============================================================================
C
C Calculate atomic T matrix elements for all atom types.
C
C =============================================================================
C
	       NLTU=LMMAX*NEL
	       DO 247 INNEL=1,NEL
		  CALL TSCATF(INNEL,L1,ES,PHSS,PHSS2,NPSI,IT1,E,0.,
     &             PPP,NN1,NN2,NN3,DR01,DRPER1,DRPAR1,T0,T,TSF0,TSF,
     &             AF,CAF,NFLAGINT)
247            CONTINUE
	       IF(NFLAGINT.eq.1) THEN
		 WRITE(1,*) 'BE CAREFUL! AT HIGH ENERGY YOU ARE DOING
     &           EXTRAPOLATION NOT INTERPOLATION OF THE PHASE SHIFTS'
	       ENDIF
	       DRPER=DRPER1(NEL)
	       DRPAR=DRPAR1(NEL)
	       DR0=DR01(NEL)
	       IT=0
	       TV=TVA
	       VPI=VPIS
	       VPI1=VPIS
C
C =============================================================================
C
C  Compute components of incident wavevector parallel to surface and required
C beams at this energy.
C
C =============================================================================
C
	       NEXIT=0
C
	       CALL WAVE2(AK2,AK3,THETA,FI,E,VV,AK21,AK31,AK2M,AK3M,
     &          NT0,RAR1,RAR2,PQFEX,PSQ,NEXIT,SPQFS,1,NBIN)
C               CALL WAVE2(AK2,AK3,THETA,FI,E,VV,AK21,AK31,AK2M,AK3M,
C     &          NT0,RAR1,RAR2,PQFEX,PSQ,NEXIT,SPQF,1,NBIN)
C
C Select beams appropriate for current energy.
C The output NBAL,PQAL,PQFAL,NTAL,NPAL refers to the complete list of beams
C and will be used in the generation of the substrate matrices
C
	      CALL BEAMT3(KNBS,KNB,SPQ,SPQF,KNT,AK2,AK3,E,TST,NBAL,
     &          PQAL,PQFAL,NTAL,NPAL,IPR,1,
     &          IDXK,IIDXK,IIDXK2,IKRED,IIKRED,KNT,NSHBS,IMIN,
     &          IMAX,NKRED,NK3,INDK3,PH3,PQ3,INI)
C
C KSNBS,KSNB,SPQS,SPQFS,NKRED  take symmetry into account 
C The output NB,PQ,PQF,NT,NP refers to symmetric beams
C
	      CALL BEAMT3(KSNBS,KSNB,SPQS,SPQFS,NKRED,AK2,AK3,E,TST,
     &          NB,PQ,PQF,NT,NP,IPR,0,
     &          IDXK,IIDXK,IIDXK2,IKRED,IIKRED,KNT,NSHBS,IMIN,
     &          IMAX,NKRED,NK3,INDK3,PH3,PQ3,INI)
C
C use time reversal invariance to restrict calculation in MTNVSYM
C Also compute angles between beams to be used in substrate calculation
C
	      CALL TREV(IND1,IND2,PQAL,PQ,NTAL,NT,INI,NRCP,
     &          IIDXK,IIDXK2,IKBS,PH4,KNBS,NBAL)
C
C   Perform planar lattice sums.
C
	       CALL FMAT(FLMS,V,JJS,NL,NL,DCUTS,IDEG,LMAX,KLM)

C =============================================================================
C
C Now calculate overlayer and substrate matrices using Matrix inversion.
C
C =============================================================================
C
	       NA=0
	       NS=0
	       LAY=1
	       TV1=TVB
	       DCUT=DCUTS
	       NPERT=5
	       NOPT=1
	       NEW=1
C
C Set up overlayer atom positions and phase shift assignments LPS
C
	    DO 547 NCL=1,NST1
	       VPI1=VICL(NCL)
	       NLAY=LAFLAG(NCL)
	       NTAU=NTAUAW(NCL)
	       LPSMAX=1
	       DO 548 I=1,NLAY
		  CALL SETPOS(FPOS,VPOS,LPSAW,LPS(I),I,NCL,NLMAX,NST1)
		  IF(LPS(I).GT.LPSMAX)LPSMAX=LPS(I)
548            CONTINUE
C
C NTAUSH takes care of proper indexing in THMAT and TAUMAT
C LPS for each layer (in tleed5.i) must be consecutive integers.
C (e.g. 1,2 ; 2,1 or 3,1,2 are allowed as element indices corresponding
C to a CL with NLAY=2 or NLAY=3 resp. ; 1,3  or 1,3,3 are not allowed)
C
		NTAUSH=LPSMAX-NTAU
C
C Set parameters for NCL composite layer
C
	       NLAY2=NLAY*(NLAY-1)
	       LMNI=NLAY*LMMAX
	       LM2N=2*LMNI
	       LMT=LMMAX*NTAU
	       LMT2=LSM*NTAU
	       LMNM=LMNBD(1,NCL)
	       IF(LMNBD(2,NCL).GT.LMNM) LMNM=LMNBD(2,NCL)
C
C Calculate transmission and reflection matrices for overlayer.
C
	       IF(NLAY.EQ.1)THEN
		 NLAY2=1
	       ENDIF
C      I2=MCLOCK()
	   IF(NCL.LE.NSTEF) THEN
C
C compute overlayer matrices
C
	     CALL MTSYM6(ROP,TOP,ROM,TOM,NT,NT,NT,AMULT,CYLM,PQ,NT,
     & FLMS,NL,LXI,LT,LXM,LX2,LT2,LXM2,LMMAX,KLM,XEVM,LEV,
     & LEV2,TAU,LMT,LMT2,TAUG,TAUG2,TAUGM,TAUGM2,CLM,NLM,FPOS,POSS,MGH,
     & NLAY,DRL,NUGH,LEVV,NLAY2,TEST,RG,
     & TS,TS2,TG,LM2N,VT,CAA,NCAA,TH,LMNI,LMNM,IPL,
     & TSTORE,NSTEF,NSTEF,NST1,NCL,JLMNI2,NTAUSH,CTR,CTT,CYTR,
     & CYTT,VVST,VT2,LSM,IND1,IND2,NRCP,NINEQ,
     & NLMAX,LPBD,
     & WBDS(1,NCL),IDXS(1,NCL),IDXN(1,NCL),ZRED(1,NCL),LMNBD(1,NCL),
     & WBDS2(1,NCL),IDXS2(1,NCL),IDXN2(1,NCL),
     & LMNBD2(1,NCL),TAUINV,NLTU,LAN,KOUNT,IIKRED,IKBS,LMNMAX,LMSMAX,
     & NBULK,INDK3,PQ3,PH3,NK3,KSNBS,NB,NSU,PH4,VEC,LPS,LPSS,TSF)
	   ELSE
C
C compute substrate matrices
C
	       LAY=2
	       TV1=TVA
	     CALL MTSYM6(RA1R,TA1R,RA2R,TA2R,NT,NT,NP,AMULT,CYLM,PQ,NT,
     & FLMS,NL,LXI,LT,LXM,LX2,LT2,LXM2,LMMAX,KLM,XEVM,LEV,
     & LEV2,TAU,LMT,LMT2,TAUG,TAUG2,TAUGM,TAUGM2,CLM,NLM,FPOS,POSS,MGH,
     & NLAY,DRL,NUGH,LEVV,
     & NLAY2,TEST,RG,
     & TS,TS2,TG,LM2N,VT,CAA,NCAA,TH,LMNI,LMNM,IPL,
     & TSTORE,NST1B,NSTEF,NST1,NCL,JLMNI2,NTAUSH,CTR,CTT,CYTR,
     & CYTT,VVST,VT2,LSM,IND1,IND2,NRCP,NINEQ,
     & NLMAX,LPBD,
     & WBDS(1,NCL),IDXS(1,NCL),IDXN(1,NCL),ZRED(1,NCL),LMNBD(1,NCL),
     & WBDS2(1,NCL),IDXS2(1,NCL),IDXN2(1,NCL),
     & LMNBD2(1,NCL),TAUINV,NLTU,LAN,KOUNT,IIKRED,IKBS,LMNMAX,LMSMAX,
     & NBULK,INDK3,PQ3,PH3,NK3,KSNBS,NB,NSU,PH4,VEC,LPS,LPSS,TSF)
	   ENDIF
C      I3=MCLOCK()
C      FTIME=FLOAT(I3-I2)
C      CPU=FTIME/100.0
C      WRITE(*,*) CPU,'mtnv'
C
C Store the sorted composite layer assignement of the element type
C
	       DO 552 I=1,NLAY
		  LPSAWS(NCL,I)=LPSS(I)
552            CONTINUE
547         CONTINUE          
C
C  Set up interlayer vectors.
C
	       DO 148 I=1,3
		  ASC(I)=ASA(1,I)
		  ASD(I)=ASA(1,I)
		  IF(INVECT.EQ.2)ASD(I)=ASA(2,I)
148            CONTINUE
C
C Loop from 0 to NT0. First loop (NEXIT=0) produces the standard time
C forward LEED calculation. Subsequent loops reset the incident direction
C to the various exit directions and perform the time reversed LEED 
C calculation.
C
	       DO 1000 NEXIT=0,NT0
C
C Compute components of incident beam, and also locate current exit beam
C in input beam list.
C
		  CALL WAVE2(AK2,AK3,THETA,FI,E,VV,AK21,AK31,AK2M,AK3M,
     &             NT0,RAR1,RAR2,PQFEX,PSQ,NEXIT,PQF,NT,NBIN)
C
C Does this beam emerge?
C
		  IF (NBIN.GT.0) THEN
C
C Yes, so complete calculation in RFS, collecting the plane wave amplitudes
C into AMPPLW
C
		   CALL RFSSYM(ROP,TOP,ROM,TOM,RA1R,TA1R,RA2R,TA2R,
     &              NT,NB,KSNBS,NP,XI,PQ,PK,AW,ANEW,20,ASB,ASC,ASD,
     &              IPR,AMPPLW,NBIN,NSTEF,NST1,NBULK,VICL,VCL,
     &              PKCL,FRCL,NT,NST1B,INVECT,IIKRED,NEXIT)
C
C On first loop dump intensities to output file
C
		     IF (NEXIT.EQ.0) THEN
C
C Compute intensities from amplitudes
C
		       CALL TRINT(NT,XI,PQ,PQF,VV,THETA,FI,IPR)
C
C Dump intensities of exit beams to transfer file
C
		      CALL DUMP(PQF,PQFEX2,NT0,NT,XI,XIST,E,22)
C
C Propagate the plane wave amplitudes through the composite layer
C using the intelayer (1-X) matrix. Store results for the time forward
C LEED states in ALM.
C 
			NINDEX2=0
		     DO 1150 NCL=1,NSTEF
			NLAY=LAFLAG(NCL)
C                        NTAU=NTAUAW(NCL)
			LMN=NLAY*LMMAX
			DO 555 I=1,NLAY
			  LPSS(I)=LPSAWS(NCL,I)
555                     CONTINUE
			CALL APROP3(IDXS2(1,NCL),WBDS2(1,NCL),TSTORE,
     &                   AMPPLW,NCL,NT,ALM,E,VICL(NCL),NLAY,LSM,LM2,
     &                   LXM2,NSTEF,LMSMAX,JLMNI2,NINEQ,LPBD,NLMAX)
C
C Generate the required vectors from the plane wave amplitudes for each 
C layer. For the time forward LEED states, store the results in GA
C
			DO 1100 NINDEX=1,NINEQ(NCL)
			   NINDEX2=NINDEX2+1
			  CALL CVEC3(NINDEX,LM2,ALM,NLAY,A0LM,LMMAX,
     &                      LSM,NEXIT,LPSS,TSF,LSMMAX,BELM2,GA,NLTIN,
     &                      NLMB2,NINDEX2,LPBD,NLMAX,NSTEF,NCL)
1100                    CONTINUE
1150                  CONTINUE
		     ELSE
C 
C Similarly, for the time reversed LEED states
C Propagate the plane wave amplitudes through the composite layer
C using the intelayer (1-X) matrix. Store results for the time reversed
C LEED states in EXLM.
C
		      NINDEX2=0
		      DO 1250 NCL=1,NSTEF
			NLAY=LAFLAG(NCL)
C                        NTAU=NTAUAW(NCL)
			LMN=NLAY*LMMAX
			DO 556 I=1,NLAY
			  LPSS(I)=LPSAWS(NCL,I)
556                     CONTINUE
			CALL APROP3(IDXS2(1,NCL),WBDS2(1,NCL),TSTORE,
     &                   AMPPLW,NCL,NT,EXLM,E,VICL(NCL),NLAY,LSM,LM2,
     &                   LXM2,NSTEF,LMSMAX,JLMNI2,NINEQ,LPBD,NLMAX)
C
C Generate the required vectors from the plane wave amplitudes for each 
C layer. For the time reveresed LEED states, store the results in GB
C
			DO 1200 NINDEX=1,NINEQ(NCL)
			   NINDEX2=NINDEX2+1
			   CALL CVEC3(NINDEX,LM2,EXLM,NLAY,A0LM,LMMAX,
     &                      LSM,NEXIT,LPSS,TSF,LSMMAX,BELM2,GB,1,NLMB2,
     &                      1,LPBD,NLMAX,NSTEF,NCL)
C
C Use the vectors GA and GB to construct the tensor Q
C
			  CALL QGEN2(GA,GB,Q,LMMAX,LSMMAX,NINDEX2,
     &                    NLTIN,E,VICL(NCL),NEXIT,NT0,AK2M,AK3M,TV,
     &                    NLMAX,LAFLAG2,NSTEF,NINDEX,NCL)
C
C Dump the truncated Q matrix to the transfer file
C
C			  CALL SHORT(Q,LSMMAX,22,E,VV,AK2M,AK3M, changed by ZZ on 09/07/04
			  CALL SHORT_own(Q,LSMMAX,22,E,VV,AK2M,AK3M,
     &                      NT0,NEXIT,ICUT,QCUT,MICUT,MJCUT)
1200                    CONTINUE
1250                  CONTINUE
		     ENDIF
		  ENDIF
1000           CONTINUE
C
C =============================================================================
C
C Increment energy range.
C
C =============================================================================
C
CPC               WRITE (*,999) EEV
CPC999            FORMAT (' LAST ENERGY: ',F10.2)
1300        CONTINUE
	    WRITE (1,106)
	 ENDIF
      ENDIF
C      I2=MCLOCK()
C      FTIME=FLOAT(I2-I1)
C      CPU=FTIME/100.0
C      WRITE(1,113) CPU
Cga 1400  STOP
 1400  continue
9111   continue 
Cga Clear IEEE exceptions for underflow and inexact: these
Cga are usually NOTHING to worry about.
c      call ieee_flags("clear", "exception", "all", out)
      close(1)
      close(4)
      close(5)
      close(22)


      return
      END
