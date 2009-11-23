C Output from Public domain Ratfor, version 1.01
      subroutine dnewton (cd, nxis, q, nxi, rs, nobs, cntsum, cnt, qdrs,
     * nqd, qdwt, prec, maxiter, mchpr, wk, info)
      integer nxis, nxi, nobs, cntsum, cnt(*), nqd, maxiter, info
      double precision cd(*), q(nxi,*), rs(nxis,*), qdrs(nqd,*), qdwt(*)
     *, prec, mchpr, wk(*)
      integer imrs, iwt, ifit, imu, iv, ijpvt, icdnew, iwtnew, ifitnew, 
     *iwk
      imrs = 1
      iwt = imrs + max0 (nxis, 3)
      ifit = iwt + nqd
      imu = ifit + nobs
      iv = imu + nxis
      ijpvt = iv + nxis*nxis
      icdnew = ijpvt + nxis
      iwtnew = icdnew + nxis
      ifitnew = iwtnew + nqd
      iwk = ifitnew + nobs
      call dnewton1 (cd, nxis, q, nxi, rs, nobs, cntsum, cnt, qdrs, nqd,
     * qdwt, prec, maxiter, mchpr, wk(imrs), wk(iwt), wk(ifit), wk(imu),
     * wk(iv), wk(ijpvt), wk(icdnew), wk(iwtnew), wk(ifitnew), wk(iwk), 
     *info)
      return
      end
      subroutine dnewton1 (cd, nxis, q, nxi, rs, nobs, cntsum, cnt, qdrs
     *, nqd, qdwt, prec, maxiter, mchpr, mrs, wt, fit, mu, v, jpvt, cdne
     *w, wtnew, fitnew, wk, info)
      integer nxis, nxi, nobs, cntsum, cnt(*), nqd, maxiter, jpvt(*), in
     *fo
      double precision cd(*), q(nxi,*), rs(nxis,*), qdrs(nqd,*), qdwt(*)
     *, prec, mchpr, mrs(*), wt(*), fit(*), mu(*), v(nxis,*), cdnew(*), 
     *wtnew(*), fitnew(*), wk(*)
      integer i, j, k, iter, flag, rkv, idamax, infowk
      double precision wtsum, tmp, ddot, fitmean, lkhd, mumax, wtsumnew,
     * lkhdnew, disc, disc0, trc
      info = 0
      i=1
23000 if(.not.(i.le.nxis))goto 23002
      mrs(i) = 0.d0
      if(cntsum.eq.0)then
      j=1
23005 if(.not.(j.le.nobs))goto 23007
      mrs(i) = mrs(i) + rs(i,j)
23006 j=j+1
      goto 23005
23007 continue
      mrs(i) = mrs(i) / dfloat (nobs)
      else
      j=1
23008 if(.not.(j.le.nobs))goto 23010
      mrs(i) = mrs(i) + rs(i,j) * dfloat (cnt(j))
23009 j=j+1
      goto 23008
23010 continue
      mrs(i) = mrs(i) / dfloat (cntsum)
      endif
23001 i=i+1
      goto 23000
23002 continue
      wtsum = 0.d0
      i=1
23011 if(.not.(i.le.nqd))goto 23013
      wt(i) = qdwt(i) * dexp (ddot (nxis, qdrs(i,1), nqd, cd, 1))
      wtsum = wtsum + wt(i)
23012 i=i+1
      goto 23011
23013 continue
      fitmean = 0.d0
      i=1
23014 if(.not.(i.le.nobs))goto 23016
      tmp = ddot (nxis, rs(1,i), 1, cd, 1) - dlog (wtsum)
      fit(i) = dexp (tmp)
      if(cntsum.ne.0)then
      tmp = tmp * dfloat (cnt(i))
      endif
      fitmean = fitmean + tmp
23015 i=i+1
      goto 23014
23016 continue
      if(cntsum.eq.0)then
      fitmean = fitmean / dfloat (nobs)
      else
      fitmean = fitmean / dfloat (cntsum)
      endif
      call dsymv ('u', nxi, 1.d0, q, nxi, cd, 1, 0.d0, wk, 1)
      lkhd = ddot (nxi, cd, 1, wk, 1) / 2.d0 - fitmean
      iter = 0
      flag = 0
23021 continue
      iter = iter + 1
      i=1
23024 if(.not.(i.le.nxis))goto 23026
      mu(i) = - ddot (nqd, wt, 1, qdrs(1,i), 1) / wtsum
23025 i=i+1
      goto 23024
23026 continue
      i=1
23027 if(.not.(i.le.nxis))goto 23029
      j=i
23030 if(.not.(j.le.nxis))goto 23032
      v(i,j) = 0.d0
      k=1
23033 if(.not.(k.le.nqd))goto 23035
      v(i,j) = v(i,j) + wt(k) * qdrs(k,i) * qdrs(k,j)
23034 k=k+1
      goto 23033
23035 continue
      v(i,j) = v(i,j) / wtsum - mu(i) * mu(j)
      if(j.le.nxi)then
      v(i,j) = v(i,j) + q(i,j)
      endif
23031 j=j+1
      goto 23030
23032 continue
23028 i=i+1
      goto 23027
23029 continue
      call daxpy (nxis, 1.d0, mrs, 1, mu, 1)
      call dsymv ('u', nxi, -1.d0, q, nxi, cd, 1, 1.d0, mu, 1)
      mumax = dabs(mu(idamax(nxis, mu, 1)))
      i=1
23038 if(.not.(i.le.nxis))goto 23040
      jpvt(i) = 0
23039 i=i+1
      goto 23038
23040 continue
      call dchdc (v, nxis, nxis, wk, jpvt, 1, rkv)
23041 if(v(rkv,rkv).lt.v(1,1)*dsqrt(mchpr))then
      rkv = rkv - 1
      goto 23041
      endif
23042 continue
      i=rkv+1
23043 if(.not.(i.le.nxis))goto 23045
      v(i,i) = v(1,1)
      call dset (i-rkv-1, 0.d0, v(rkv+1,i), 1)
23044 i=i+1
      goto 23043
23045 continue
23046 continue
      call dcopy (nxis, mu, 1, cdnew, 1)
      call dprmut (cdnew, nxis, jpvt, 0)
      call dtrsl (v, nxis, nxis, cdnew, 11, infowk)
      call dset (nxis-rkv, 0.d0, cdnew(rkv+1), 1)
      call dtrsl (v, nxis, nxis, cdnew, 01, infowk)
      call dprmut (cdnew, nxis, jpvt, 1)
      call daxpy (nxis, 1.d0, cd, 1, cdnew, 1)
      wtsumnew = 0.d0
      i=1
23049 if(.not.(i.le.nqd))goto 23051
      tmp = ddot (nxis, qdrs(i,1), nqd, cdnew, 1)
      if(tmp.gt.3.d2)then
      flag = flag + 1
      goto 23051
      endif
      wtnew(i) = qdwt(i) * dexp (tmp)
      wtsumnew = wtsumnew + wtnew(i)
23050 i=i+1
      goto 23049
23051 continue
      if((flag.eq.0).or.(flag.eq.2))then
      fitmean = 0.d0
      i=1
23056 if(.not.(i.le.nobs))goto 23058
      tmp = ddot (nxis, rs(1,i), 1, cdnew, 1) - dlog (wtsumnew)
      if(tmp.gt.3.d2)then
      flag = flag + 1
      goto 23058
      endif
      fitnew(i) = dexp (tmp)
      if(cntsum.ne.0)then
      tmp = tmp * dfloat (cnt(i))
      endif
      fitmean = fitmean + tmp
23057 i=i+1
      goto 23056
23058 continue
      if(cntsum.eq.0)then
      fitmean = fitmean / dfloat (nobs)
      else
      fitmean = fitmean / dfloat (cntsum)
      endif
      call dsymv ('u', nxi, 1.d0, q, nxi, cdnew, 1, 0.d0, wk, 1)
      lkhdnew = ddot (nxi, cdnew, 1, wk, 1) / 2.d0 - fitmean
      endif
      if(flag.eq.1)then
      call dset (nxis, 0.d0, cd, 1)
      wtsum = 0.d0
      i=1
23067 if(.not.(i.le.nqd))goto 23069
      wt(i) = qdwt(i)
      wtsum = wtsum + wt(i)
23068 i=i+1
      goto 23067
23069 continue
      call dset (nobs, 1.d0/wtsum, fit, 1)
      fitmean = - dlog (wtsum)
      lkhd = - fitmean
      iter = 0
      goto 23048
      endif
      if(flag.eq.3)then
      goto 23048
      endif
      if(lkhdnew-lkhd.lt.1.d1*(1.d0+dabs(lkhd))*mchpr)then
      goto 23048
      endif
      call dscal (nxis, .5d0, mu, 1)
      if(dabs(mu(idamax(nxis, mu, 1))/mumax).lt.1.d1*mchpr)then
      goto 23048
      endif
23047 goto 23046
23048 continue
      if(flag.eq.1)then
      flag = 2
      goto 23022
      endif
      if(flag.eq.3)then
      info = 1
      return
      endif
      disc = 0.d0
      i=1
23080 if(.not.(i.le.nqd))goto 23082
      disc = dmax1 (disc, dabs(wt(i)-wtnew(i))/(1.d0+dabs(wt(i))))
23081 i=i+1
      goto 23080
23082 continue
      i=1
23083 if(.not.(i.le.nobs))goto 23085
      disc = dmax1 (disc, dabs(fit(i)-fitnew(i))/(1.d0+dabs(fit(i))))
23084 i=i+1
      goto 23083
23085 continue
      disc = dmax1 (disc, (mumax/(1.d0+dabs(lkhd)))**2)
      disc0 = dmax1 ((mumax/(1.d0+lkhd))**2, dabs(lkhd-lkhdnew)/(1.d0+da
     *bs(lkhd)))
      call dcopy (nxis, cdnew, 1, cd, 1)
      call dcopy (nqd, wtnew, 1, wt, 1)
      wtsum = wtsumnew
      call dcopy (nobs, fitnew, 1, fit, 1)
      lkhd = lkhdnew
      if(disc0.lt.prec)then
      goto 23023
      endif
      if(disc.lt.prec)then
      goto 23023
      endif
      if(iter.lt.maxiter)then
      goto 23022
      endif
      if(flag.eq.0)then
      call dset (nxis, 0.d0, cd, 1)
      wtsum = 0.d0
      i=1
23094 if(.not.(i.le.nqd))goto 23096
      wt(i) = qdwt(i)
      wtsum = wtsum + wt(i)
23095 i=i+1
      goto 23094
23096 continue
      call dset (nobs, 1.d0/wtsum, fit, 1)
      fitmean = - dlog (wtsum)
      lkhd = - fitmean
      iter = 0
      flag = 2
      else
      info = 2
      goto 23023
      endif
23022 goto 23021
23023 continue
      i=1
23097 if(.not.(i.le.nobs))goto 23099
      call daxpy (nxis, -1.d0, mrs, 1, rs(1,i), 1)
      call dprmut (rs(1,i), nxis, jpvt, 0)
      if(cntsum.ne.0)then
      call dscal (nxis, dsqrt(dfloat(cnt(i))), rs(1,i), 1)
      endif
      call dtrsl (v, nxis, nxis, rs(1,i), 11, infowk)
      call dset (nxis-rkv, 0.d0, rs(rkv+1,i), 1)
23098 i=i+1
      goto 23097
23099 continue
      trc = ddot (nobs*nxis, rs, 1, rs, 1)
      if(cntsum.eq.0)then
      trc = trc / dfloat(nobs) / (dfloat(nobs)-1.d0)
      lkhd = 0.d0
      i=1
23104 if(.not.(i.le.nobs))goto 23106
      lkhd = lkhd + dlog (fit(i))
23105 i=i+1
      goto 23104
23106 continue
      lkhd = lkhd / dfloat (nobs)
      else
      trc = trc / dfloat(cntsum) / (dfloat(cntsum)-1.d0)
      lkhd = 0.d0
      i=1
23107 if(.not.(i.le.nobs))goto 23109
      lkhd = lkhd + dfloat (cnt(i)) * dlog (fit(i))
23108 i=i+1
      goto 23107
23109 continue
      lkhd = lkhd / dfloat (cntsum)
      endif
      mrs(1) = lkhd
      mrs(2) = trc
      mrs(3) = wtsum
      return
      end
