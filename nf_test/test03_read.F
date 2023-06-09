C     Copyright 1996-2019, UCAR/Unidata
C     See netcdf/COPYRIGHT file for copying and redistribution conditions.

C     Steve Emmerson, Ed Hartnett

C     Test nf_strerror.
C     Try on a bad error status.
C     Test for each defined error status.
C
      subroutine test_nf_strerror()
      USE tests
      implicit none
      integer         number_of_messages
      parameter       (number_of_messages = 27)

      integer         i
      integer         status(number_of_messages)
      character*80    message
      character*80    msg(number_of_messages)

      data    status(1)  / NF_NOERR/
      data    status(2)  / NF_EBADID /
      data    status(3)  / NF_EEXIST /
      data    status(4)  / NF_EINVAL /
      data    status(5)  / NF_EPERM /
      data    status(6)  / NF_ENOTINDEFINE /
      data    status(7)  / NF_EINDEFINE /
      data    status(8)  / NF_EINVALCOORDS /
      data    status(9)  / NF_EMAXDIMS /
      data    status(10) / NF_ENAMEINUSE /
      data    status(11) / NF_ENOTATT /
      data    status(12) / NF_EMAXATTS /
      data    status(13) / NF_EBADTYPE /
      data    status(14) / NF_EBADDIM /
      data    status(15) / NF_EUNLIMPOS /
      data    status(16) / NF_EMAXVARS /
      data    status(17) / NF_ENOTVAR /
      data    status(18) / NF_EGLOBAL /
      data    status(19) / NF_ENOTNC /
      data    status(20) / NF_ESTS /
      data    status(21) / NF_EMAXNAME /
      data    status(22) / NF_EUNLIMIT /
      data    status(23) / NF_ENORECVARS /
      data    status(24) / NF_ECHAR /
      data    status(25) / NF_EEDGE /
      data    status(26) / NF_ESTRIDE /
      data    status(27) / NF_EBADNAME /

      data msg(1)  / 'No error' /
      data msg(2)  / 'NetCDF: Not a valid ID' /
      data msg(3)  / 'NetCDF: File exists && NC_NOCLOBBER' /
      data msg(4)  / 'NetCDF: Invalid argument' /
      data msg(5)  / 'NetCDF: Write to read only' /
      data msg(6)  / 'NetCDF: Operation not allowed in data mode' /
      data msg(7)  / 'NetCDF: Operation not allowed in define mode' /
      data msg(8)  / 'NetCDF: Index exceeds dimension bound' /
      data msg(9)  / 'NetCDF: NC_MAX_DIMS exceeded' /
      data msg(10) / 'NetCDF: String match to name in use' /
      data msg(11) / 'NetCDF: Attribute not found' /
      data msg(12) / 'NetCDF: NC_MAX_ATTRS exceeded' /
      data msg(13)
     +  / 'NetCDF: Not a valid data type or _FillValue type mismatch' /
      data msg(14) / 'NetCDF: Invalid dimension ID or name' /
      data msg(15) / 'NetCDF: NC_UNLIMITED in the wrong index' /
      data msg(16) / 'NetCDF: NC_MAX_VARS exceeded' /
      data msg(17) / 'NetCDF: Variable not found' /
      data msg(18) / 'NetCDF: Action prohibited on NC_GLOBAL varid' /
      data msg(19) / 'NetCDF: Unknown file format' /
      data msg(20) / 'NetCDF: In Fortran, string too short' /
      data msg(21) / 'NetCDF: NC_MAX_NAME exceeded' /
      data msg(22) / 'NetCDF: NC_UNLIMITED size already in use' /
      data msg(23)
     +     / 'NetCDF: nc_rec op when there are no record vars' /
      data msg(24)
     +     /'NetCDF: Attempt to convert between text & numbers'/
      data msg(25) / 'NetCDF: Start+count exceeds dimension bound' /
      data msg(26) / 'NetCDF: Illegal stride' /
      data msg(27) / 'NetCDF: Name contains illegal characters' /

C     /* Try on a bad error status */
      message = nf_strerror(-666) !/* should fail */
      if (message(1:13) .ne. 'Unknown Error')
     +     call errorc('nf_strerror on bad error status returned: ',
     +     message)

C     /* Try on each legitimate error status */
      do 1, i=1, number_of_messages
         message = nf_strerror(status(i))
         if (message .ne. msg(i))
     +        call error('nf_strerror() should return "' // msg(i) //
     +        '"')
 1    continue
      end


C     Test nf_open.
C     If in read-only section of tests,
C     Try to open a non-existent netCDF file, check error return.
C     Open a file that is not a netCDF file, check error return.
C     Open a netCDF file with a bad mode argument, check error return.
C     Open a netCDF file with NF_NOWRITE mode, try to write, check error.
C     Try to open a netcdf twice, check whether returned netcdf ids different.
C     If in writable section of tests,
C     Open a netCDF file with NF_WRITE mode, write something, close it.
C     On exit, any open netCDF files are closed.
      subroutine test_nf_open()
      USE tests
      implicit none
      integer err
      integer ncid
      integer ncid2
      character TEMPFILE*8
      integer unit51
C     /* Create a non-netCDF file named 'temp.tmp' */
      unit51 = 51
      TEMPFILE = 'temp.tmp'
      OPEN(unit51, FILE=TEMPFILE)
      WRITE(51,*) 'text'
      CLOSE(51)

C     /* Try to open a nonexistent file */
      err = nf_open('tooth-fairy.nc', NF_NOWRITE, ncid) !/* should fail */
      if (err .eq. NF_NOERR)
     +     call error('nf_open of nonexistent file should have failed')
      if (.not. NF_ISSYSERR(err))
     +   call error(
     +  'nf_open of nonexistent file should have returned system error')

C     /* Open a file that is not a netCDF file. */
      err = nf_open(TEMPFILE, NF_NOWRITE, ncid) !/* should fail */
      if (err .ne. NF_ENOTNC)
     +     call errore('nf_open of non-netCDF file: ', err)

C     /* Open a netCDF file in read-only mode, check that write fails */
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_redef(ncid)      !/* should fail */
      if (err .ne. NF_EPERM)
     +     call error('nf_redef of read-only file should fail')
C     /* Opened OK, see if can open again and get a different netCDF ID */
      err = nf_open(testfile, NF_NOWRITE, ncid2)
      if (err .ne. 0) then
         call errore('nf_open: ', err)
      else
         err = nf_close(ncid2)
      end if
      if (ncid2 .eq. ncid)
     +     call error(
     +   'netCDF IDs for first and second nf_open calls should differ')

      if (.not. readonly) then  !/* tests using netCDF scratch file */
         err = nf_create(scratch, NF_NOCLOBBER, ncid2)
         if (err .ne. 0) then
            call errore('nf_create: ', err)
         else
            err = nf_close(ncid2)
         end if
         err = nf_open(scratch, NF_WRITE, ncid2)
         if (err .ne. 0) then
            call errore('nf_open: ', err)
         else
            err = nf_close(ncid2)
         end if
         err = nf_delete(scratch)
         if (err .ne. 0)
     +        call errorc('delete of scratch file failed', scratch)
      end if

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


C
C     Test nf_close.
C     Try to close a netCDF file twice, check whether second close fails.
C     Try on bad handle, check error return.
C     Try in define mode and data mode.
C     /
      subroutine test_nf_close()
      USE tests
      implicit none
      integer ncid
      integer err

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

C     /* Close a netCDF file twice, second time should fail */
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close failed: ', err)
      err = nf_close(ncid)
      if (err .ne. NF_EBADID)
     +     call error('nf_close of closed file should have failed')

C     /* Try with a bad netCDF ID */
      err = nf_close(BAD_ID)    !/* should fail */
      if (err .ne. NF_EBADID)
     +     call errore(
     +     'nf_close with bad netCDF ID returned wrong error: ',
     +     err)

C     /* Close in data mode */
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close in data mode failed: ', err)

      if (.not. readonly) then  !/* tests using netCDF scratch file */
         err = nf_create(scratch, NF_NOCLOBBER, ncid)
         if (err .ne. 0)
     +        call errore('nf_create: ', err)
         err = nf_close(ncid)
         if (err .ne. 0)
     +        call errore('nf_close in define mode: ', err)
         err = nf_delete(scratch)
         if (err .ne. 0)
     +        call errorc('delete of scratch file failed: ',
     +        scratch)
      end if
      end


C     Test nf_inq.
C     Try on bad handle, check error return.
C     Try in data mode, check returned values.
C     Try asking for subsets of info.
C     If in writable section of tests,
C     Try in define mode, after adding an unlimited dimension, variable.
C     On exit, any open netCDF files are closed.
      subroutine test_nf_inq()
      USE tests
      implicit none
      integer ncid
      integer ncid2             !/* for scratch netCDF dataset */
      integer ndims1             !/* number of dimensions */
      integer nvars1             !/* number of variables */
      integer ngatts1            !/* number of global attributes */
      integer recdim1            !/* id of unlimited dimension */
      integer err
      integer ndims0
      integer nvars0
      integer ngatts0
      integer recdim0
      integer did
      integer vid

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

C     /* Try on bad handle */
      err = nf_inq(BAD_ID, ndims1, nvars1, ngatts1, recdim1)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)

      err = nf_inq(ncid, ndims1, nvars1, ngatts1, recdim1)
      if (err .ne. 0) then
         call errore('nf_inq: ', err)
      else if (ndims1 .ne. NDIMS) then
         call errori('nf_inq: wrong number of dimensions returned: ',
     +        ndims1)
      else if (nvars1 .ne. NVARS) then
         call errori('nf_inq: wrong number of variables returned: ',
     +        nvars1)
      else if (ngatts1 .ne. NGATTS) then
         call errori(
     +        'nf_inq: wrong number of global atts returned: ',
     +        ngatts1)
      else if (recdim1 .ne. RECDIM) then
         call errori('nf_inq: wrong record dimension ID returned: ',
     +        recdim1)
      end if

      if (.not. readonly) then  !/* tests using netCDF scratch file */
         err = nf_create(scratch, NF_NOCLOBBER, ncid2)
         if (err .ne. 0) then
            call errore('nf_create: ', err)
         else                   !/* add dim, var, gatt, check inq */
            err = nf_enddef(ncid2) !/* enter data mode */
            err = nf_inq(ncid2, ndims0, nvars0, ngatts0, recdim0)
            if (err .ne. 0)
     +           call errore('nf_inq: ', err)
            err = nf_redef(ncid2) !/* enter define mode */
C     /* Check that inquire still works in define mode */
            err = nf_inq(ncid2, ndims1, nvars1, ngatts1, recdim1)
            if (err .ne. 0) then
               call errore('nf_inq in define mode: ', err)
            else if (ndims1 .ne. ndims0) then
               call errori('nf_inq in define mode: ndims1 wrong, ',
     +              ndims1)
            else if (nvars1 .ne. nvars0) then
               call errori('nf_inq in define mode: nvars1 wrong, ',
     +              nvars1)
            else if (ngatts1 .ne. ngatts0) then
               call errori(
     +              'nf_inq in define mode: ngatts wrong, ', ngatts1)
            else if (recdim1 .ne. recdim0) then
               call errori('nf_inq in define mode: recdim1 wrong, ',
     +              recdim1)
            end if

C     /* Add dim, var, global att */
            err = nf_def_dim(ncid2, 'inqd', 1, did)
            if (err .ne. 0)
     +           call errore('nf_def_dim: ', err)
            err = nf_def_var(ncid2, 'inqv', NF_FLOAT, 0, (/0/), vid)
            if (err .ne. 0)
     +           call errore('nf_def_var: ', err)

            err = nf_put_att_text(ncid2, NF_GLOBAL, 'inqa',
     +           len('stuff'), 'stuff')
            if (err .ne. 0)
     +           call errore('nf_put_att_text: ', err)

C     /* Make sure nf_inq sees the additions while in define mode */
            err = nf_inq(ncid2, ndims1, nvars1, ngatts1, recdim1)
            if (err .ne. 0) then
               call errore('nf_inq in define mode: ', err)
            else if (ndims1 .ne. ndims0 + 1) then
               call errori('nf_inq in define mode: ndims1 wrong, ',
     +              ndims1)
            else if (nvars1 .ne. nvars0 + 1) then
               call errori('nf_inq in define mode: nvars wrong, ',
     +              nvars1)
            else if (ngatts1 .ne. ngatts0 + 1) then
               call errori('nf_inq in define mode: ngatts1 wrong, ',
     +              ngatts1)
            end if
            err = nf_enddef(ncid2)
            if (err .ne. 0)
     +           call errore('nf_enddef: ', err)

C     /* Make sure nf_inq stills sees additions in data mode */
            err = nf_inq(ncid2, ndims1, nvars1, ngatts1, recdim1)
            if (err .ne. 0) then
               call errore('nf_inq failed in data mode: ',err)
            else if (ndims1 .ne. ndims0 + 1) then
               call errori('nf_inq in define mode: ndims1 wrong, ',
     +              ndims1)
            else if (nvars1 .ne. nvars0 + 1) then
               call errori('nf_inq in define mode: nvars wrong, ',
     +              nvars1)
            else if (ngatts1 .ne. ngatts0 + 1) then
               call errori('nf_inq in define mode: ngatts1 wrong, ',
     +              ngatts1)
            end if
            err = nf_close(ncid2)
            err = nf_delete(scratch)
            if (err .ne. 0)
     +           call errorc('delete of scratch file failed:',
     +           scratch)
         end if
      end if

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_natts()
      USE tests
      implicit none
      integer ncid
      integer ngatts1            !/* number of global attributes */
      integer err

      err = nf_inq_natts(BAD_ID, ngatts1)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_natts(ncid, ngatts1)
      if (err .ne. 0) then
         call errore('nf_inq_natts: ', err)
      else if (ngatts1 .ne. NGATTS) then
         call errori(
     +        'nf_inq_natts: wrong number of global atts returned, ',
     +        ngatts1)
      end if
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_ndims()
      USE tests
      implicit none
      integer ncid
      integer ndims1
      integer err

      err = nf_inq_ndims(BAD_ID, ndims1)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_ndims(ncid, ndims1)
      if (err .ne. 0) then
         call errore('nf_inq_ndims: ', err)
      else if (ndims1 .ne. NDIMS) then
         call errori('nf_inq_ndims: wrong number returned, ', ndims1)
      end if
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_nvars()
      USE tests
      implicit none
      integer ncid
      integer nvars1
      integer err

      err = nf_inq_nvars(BAD_ID, nvars1)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_nvars(ncid, nvars1)
      if (err .ne. 0) then
         call errore('nf_inq_nvars: ', err)
      else if (nvars1 .ne. NVARS) then
         call errori('nf_inq_nvars: wrong number returned, ', nvars1)
      end if
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_unlimdim()
      USE tests
      implicit none
      integer ncid
      integer unlimdim
      integer err

      err = nf_inq_unlimdim(BAD_ID, unlimdim)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_unlimdim(ncid, unlimdim)
      if (err .ne. 0) then
         call errore('nf_inq_unlimdim: ', err)
      else if (unlimdim .ne. RECDIM) then
         call errori('nf_inq_unlimdim: wrong number returned, ',
     +        unlimdim)
      end if
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_format()
      USE tests
      implicit none
      integer ncid
      integer nformat
      integer err

      err = nf_inq_format(BAD_ID, nformat)
      if (err .ne. NF_EBADID)
     +     call errore('bad ncid: ', err)
      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_format(ncid, nformat)
      if (err .ne. 0) then
         call errore('nf_inq_format: ', err)
      else if (nformat .ne. nf_format_classic .and.
#ifdef ENABLE_CDF5
     +        nformat .ne. nf_format_cdf5 .and.
#endif
#ifdef USE_NETCDF4
     +        nformat .ne. nf_format_netcdf4 .and.
#endif
     +        nformat .ne. nf_format_64bit) then
         call errori('nf_inq_format: wrong format number returned, ',
     +        nformat)
      end if
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_dimid()
      USE tests
      implicit none
      integer ncid
      integer dimid
      integer i
      integer err

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      err = nf_inq_dimid(ncid, 'noSuch', dimid)
      if (err .ne. NF_EBADDIM)
     +     call errore('bad dim name: ', err)
      do 1, i = 1, NDIMS
         err = nf_inq_dimid(BAD_ID, dim_name(i), dimid)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_dimid(ncid, dim_name(i), dimid)
         if (err .ne. 0) then
            call errore('nf_inq_dimid: ', err)
         else if (dimid .ne. i) then
            call errori('expected ', i)
            call errori('got ', dimid)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_dim()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      character*(NF_MAX_NAME) name
      integer length

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NDIMS
         err = nf_inq_dim(BAD_ID, i, name, length)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_dim(ncid, BAD_DIMID, name, length)
         if (err .ne. NF_EBADDIM)
     +        call errore('bad dimid: ', err)
         err = nf_inq_dim(ncid, i, name, length)
         if (err .ne. 0) then
            call errore('nf_inq_dim: ', err)
         else if (dim_name(i) .ne. name)  then
            call errorc('name unexpected: ', name)
         else if (dim_len(i) .ne. length) then
            call errori('size unexpected: ', length)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_dimlen()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      integer length

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NDIMS
         err = nf_inq_dimlen(BAD_ID, i, length)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_dimlen(ncid, BAD_DIMID, length)
         if (err .ne. NF_EBADDIM)
     +        call errore('bad dimid: ', err)
         err = nf_inq_dimlen(ncid, i, length)
         if (err .ne. 0) then
            call errore('nf_inq_dimlen: ', err)
         else if (dim_len(i) .ne. length) then
            call errori('size unexpected: ', length)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_dimname()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      character*(NF_MAX_NAME)  name

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NDIMS
         err = nf_inq_dimname(BAD_ID, i, name)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_dimname(ncid, BAD_DIMID, name)
         if (err .ne. NF_EBADDIM)
     +        call errore('bad dimid: ', err)
         err = nf_inq_dimname(ncid, i, name)
         if (err .ne. 0) then
            call errore('nf_inq_dimname: ', err)
         else if (dim_name(i) .ne. name)  then
            call errorc('name unexpected: ', name)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_varid()
      USE tests
      implicit none
      integer ncid
      integer vid
      integer i
      integer err

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      err = nf_inq_varid(ncid, 'noSuch', vid)
      if (err .ne. NF_ENOTVAR)
     +     call errore('bad ncid: ', err)

      do 1, i = 1, NVARS
         err = nf_inq_varid(BAD_ID, var_name(i), vid)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_varid(ncid, var_name(i), vid)
         if (err .ne. 0) then
            call errore('nf_inq_varid: ', err)
         else if (vid .ne. i) then
            call errori('varid unexpected: ', vid)
         endif
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_var()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      character*(NF_MAX_NAME) name
      integer datatype
      integer ndims1
      integer dimids(MAX_RANK)
      integer na

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NVARS
         err = nf_inq_var(BAD_ID, i, name, datatype, ndims1, dimids,
     +        na)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_var(ncid,BAD_VARID,name,datatype,ndims1,dimids,
     +        na)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_var(ncid, i, name, datatype, ndims1, dimids,
     +        na)
         if (err .ne. 0) then
            call errore('nf_inq_var: ', err)
         else if (var_name(i) .ne. name)  then
            call errorc('name unexpected: ', name)
         else if (var_type(i) .ne. datatype) then
            call errori('type unexpected: ', datatype)
         else if (var_rank(i) .ne. ndims1) then
            call errori('ndims1 expected: ', ndims1)
         else if (.not.int_vec_eq(var_dimid(1,i),dimids,ndims1)) then
            call error('unexpected dimid')
         else if (var_natts(i) .ne. na) then
            call errori('natts unexpected: ', na)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_vardimid()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      integer dimids(MAX_RANK)

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NVARS
         err = nf_inq_vardimid(BAD_ID, i, dimids)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_vardimid(ncid, BAD_VARID, dimids)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_vardimid(ncid, i, dimids)
         if (err .ne. 0) then
            call errore('nf_inq_vardimid: ', err)
         else if (.not.int_vec_eq(var_dimid(1,i), dimids,
     +           var_rank(i))) then
            call error('unexpected dimid')
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_varname()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      character*(NF_MAX_NAME) name

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NVARS
         err = nf_inq_varname(BAD_ID, i, name)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_varname(ncid, BAD_VARID, name)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_varname(ncid, i, name)
         if (err .ne. 0) then
            call errore('nf_inq_varname: ', err)
         else if (var_name(i) .ne. name)  then
            call errorc('name unexpected: ', name)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_varnatts()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      integer na

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 0, NVARS	! start with global attributes
         err = nf_inq_varnatts(BAD_ID, i, na)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_varnatts(ncid, BAD_VARID, na)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_varnatts(ncid, VARID(i), na)
         if (err .ne. 0) then
            call errore('nf_inq_varnatts: ', err)
         else if (NATTS(i) .ne. na) then ! works for global attributes
            call errori('natts unexpected: ', na)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_varndims()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      integer ndims1

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NVARS
         err = nf_inq_varndims(BAD_ID, i, ndims1)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_varndims(ncid, BAD_VARID, ndims1)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_varndims(ncid, i, ndims1)
         if (err .ne. 0) then
            call errore('nf_inq_varndims: ', err)
         else if (var_rank(i) .ne. ndims1) then
            call errori('ndims1 unexpected: ', ndims1)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_vartype()
      USE tests
      implicit none
      integer ncid
      integer i
      integer err
      integer datatype

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)
      do 1, i = 1, NVARS
         err = nf_inq_vartype(BAD_ID, i, datatype)
         if (err .ne. NF_EBADID)
     +        call errore('bad ncid: ', err)
         err = nf_inq_vartype(ncid, BAD_VARID, datatype)
         if (err .ne. NF_ENOTVAR)
     +        call errore('bad var id: ', err)
         err = nf_inq_vartype(ncid, i, datatype)
         if (err .ne. 0) then
            call errore('nf_inq_vartype: ', err)
         else if (var_type(i) .ne. datatype) then
            call errori('type unexpected: ', datatype)
         end if
 1    continue
      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_att()
      USE tests
      implicit none
      integer ncid
      integer i
      integer j
      integer err
      integer t
      integer n

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      do 1, i = 0, NVARS
         do 2, j = 1, NATTS(i)
            err = nf_inq_att(BAD_ID, i, ATT_NAME(j,i), t, n)
            if (err .ne. NF_EBADID)
     +           call errore('bad ncid: ', err)
            err = nf_inq_att(ncid, BAD_VARID, ATT_NAME(j,i), t, n)
            if (err .ne. NF_ENOTVAR)
     +           call errore('bad var id: ', err)
            err = nf_inq_att(ncid, i, 'noSuch', t, n)
            if (err .ne. NF_ENOTATT)
     +           call errore('Bad attribute name: ', err)
            err = nf_inq_att(ncid, i, ATT_NAME(j,i), t, n)
            if (err .ne. 0) then
               call error(nf_strerror(err))
            else
               if (t .ne. ATT_TYPE(j,i))
     +              call error('type not that expected')
               if (n .ne. ATT_LEN(j,i))
     +              call error('length not that expected')
            end if
 2       continue
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_attlen()
      USE tests
      implicit none
      integer ncid
      integer i
      integer j
      integer err
      integer len

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      do 1, i = 0, NVARS
         err = nf_inq_attlen(ncid, i, 'noSuch', len)
         if (err .ne. NF_ENOTATT)
     +        call errore('Bad attribute name: ', err)
         do 2, j = 1, NATTS(i)
            err = nf_inq_attlen(BAD_ID, i, ATT_NAME(j,i), len)
            if (err .ne. NF_EBADID)
     +           call errore('bad ncid: ', err)
            err = nf_inq_attlen(ncid, BAD_VARID, ATT_NAME(j,i), len)
            if (err .ne. NF_ENOTVAR)
     +           call errore('bad varid: ', err)
            err = nf_inq_attlen(ncid, i, ATT_NAME(j,i), len)
            if (err .ne. 0) then
               call error(nf_strerror(err))
            else
               if (len .ne. ATT_LEN(j,i))
     +              call error('len not that expected')
            end if
 2       continue
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_atttype()
      USE tests
      implicit none
      integer ncid
      integer i
      integer j
      integer err
      integer datatype

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      do 1, i = 0, NVARS
         err = nf_inq_atttype(ncid, i, 'noSuch', datatype)
         if (err .ne. NF_ENOTATT)
     +        call errore('Bad attribute name: ', err)
         do 2, j = 1, NATTS(i)
            err = nf_inq_atttype(BAD_ID, i, ATT_NAME(j,i), datatype)
            if (err .ne. NF_EBADID)
     +           call errore('bad ncid: ', err)
            err = nf_inq_atttype(ncid, BAD_VARID, ATT_NAME(j,i),
     +           datatype)
            if (err .ne. NF_ENOTVAR)
     +           call errore('bad varid: ', err)
            err = nf_inq_atttype(ncid, i, ATT_NAME(j,i), datatype)
            if (err .ne. 0) then
               call error(nf_strerror(err))
            else
               if (datatype .ne. ATT_TYPE(j,i))
     +              call error('type not that expected')
            end if
 2       continue
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_attname()
      USE tests
      implicit none
      integer ncid
      integer i
      integer j
      integer err
      character*(NF_MAX_NAME) name

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      do 1, i = 0, NVARS
         err = nf_inq_attname(ncid, i, BAD_ATTNUM, name)
         if (err .ne. NF_ENOTATT)
     +        call errore('Bad attribute number: ', err)
         err = nf_inq_attname(ncid, i, NATTS(i)+1, name)
         if (err .ne. NF_ENOTATT)
     +        call errore('Bad attribute number: ', err)
         do 2, j = 1, NATTS(i)
            err = nf_inq_attname(BAD_ID, i, j, name)
            if (err .ne. NF_EBADID)
     +           call errore('bad ncid: ', err)
            err = nf_inq_attname(ncid, BAD_VARID, j, name)
            if (err .ne. NF_ENOTVAR)
     +           call errore('bad var id: ', err)
            err = nf_inq_attname(ncid, i, j, name)
            if (err .ne. 0) then
               call error(nf_strerror(err))
            else
               if (ATT_NAME(j,i) .ne. name)
     +              call error('name not that expected')
            end if
 2       continue
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end


      subroutine test_nf_inq_attid()
      USE tests
      implicit none
      integer ncid
      integer i
      integer j
      integer err
      integer attnum

      err = nf_open(testfile, NF_NOWRITE, ncid)
      if (err .ne. 0)
     +     call errore('nf_open: ', err)

      do 1, i = 0, NVARS
         err = nf_inq_attid(ncid, i, 'noSuch', attnum)
         if (err .ne. NF_ENOTATT)
     +        call errore('Bad attribute name: ', err)
         do 2, j = 1, NATTS(i)
            err = nf_inq_attid(BAD_ID, i, ATT_NAME(j,i), attnum)
            if (err .ne. NF_EBADID)
     +           call errore('bad ncid: ', err)
            err = nf_inq_attid(ncid, BAD_VARID, ATT_NAME(j,i),
     +           attnum)
            if (err .ne. NF_ENOTVAR)
     +           call errore('bad varid: ', err)
            err = nf_inq_attid(ncid, i, ATT_NAME(j,i), attnum)
            if (err .ne. 0) then
               call error(nf_strerror(err))
            else
               if (attnum .ne. j)
     +              call error('attnum not that expected')
            end if
 2       continue
 1    continue

      err = nf_close(ncid)
      if (err .ne. 0)
     +     call errore('nf_close: ', err)
      end
