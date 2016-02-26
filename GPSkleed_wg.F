C
#include "fintrf.h"
C *********************************************************************
C mexFunction:  This is a mex gateway function for calling GPSkleed. It
C               is used in conjunction with MATLAB to allow MATLAB 
C               calls to GPSkleed.
C
C --- NOTE:  This subroutine makes use of the non-standard function %VAL.
C            However, most FORTRAN compilers allow its use.
C
C --- COPYRIGHT:  Copyright @ 2016 Mark A. Abramson.  All rights reserved.
C *********************************************************************
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
	  
C --- Declarations
      implicit none
      mwSize    narg, strlen
      parameter (narg = 8)
      character*100 problem_dir
      integer*4 nlhs, nrhs, mxGetString, status
      mwIndex k
      mwPointer mxGetPr, mxGetM, mxGetN, mxCreateDoubleMatrix
      mwPointer plhs(*), prhs(*), arg(narg)
C
C --- OTHER NON-EXECUTABLE STATEMENTS:
C
C *********************** BEGIN EXECUTABLE CODE ************************
C
C --- Error check numbers of input and output arguments
      if (nrhs .ne. 7) call mexErrMsgTxt('7 input args required.')
      if (nlhs .ne. 1) call mexErrMsgTxt('1 output arg required.')
C
C --- Store working directory in string
      strlen = mxGetM(prhs(1))*mxGetN(prhs(1))
      status = mxGetString(prhs(1),problem_dir,strlen)
      if (status .ne. 0) call mexErrMsgTxt('mxGetString failed')
C
C --- Assign pointers to input and output variables
      do 100 k = 2, nrhs
         arg(k) = mxGetPr(prhs(k))
100   continue
      plhs(1)   = mxCreateDoubleMatrix(1,1,0)
      arg(narg) = mxGetPr(plhs(1))
C
C --- Make the call to KLEED
      call GPSkleed_wg(problem_dir(1:strlen),%val(arg(2)),%val(arg(3)),
     &                          %val(arg(4)),%val(arg(5)),%val(arg(6)),
     &                          %val(arg(7)),%val(arg(8)))
      return
      end

C**********************************************************************
C  GPSkleed_wg:  This wrapper file converts the double precision used
C                by MATLAB to single precision used by KLEED.
C**********************************************************************
      subroutine GPSkleed_wg(p_dir,DIR,RANK,PARM,MINB,MAXB,NTYPE,FITVAL)

      implicit none
      integer NMAX, NDIM
      parameter (NMAX = 14, NDIM = 3)
      character*(*) p_dir
      integer DIR, RANK, NTYPE(NMAX), I, J
      real*8 PARM(NMAX,NDIM), MINB(NMAX,NDIM), MAXB(NMAX,NDIM), FITVAL
      real   PARM4(NMAX,NDIM),MINB4(NMAX,NDIM),MAXB4(NMAX,NDIM),FITVAL4

      FITVAL  = 0.0
      FITVAL4 = FITVAL
      do 100 I = 1,NMAX
         do 200 J = 1,3
            PARM4(I,J) = PARM(I,J)
            MINB4(I,J) = MINB(I,J)
            MAXB4(I,J) = MAXB(I,J)
 200     enddo                
 100  enddo          

      call GPSkleed(p_dir,DIR,RANK,PARM4,MINB4,MAXB4,NTYPE,FITVAL4)
      FITVAL = FITVAL4

      return
      end
