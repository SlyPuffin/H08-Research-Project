      program calc_rivnxl
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cto     calculate downstream
cby     2010/09/30, hanasaki, NIES: H08ver1.0
cupdate 2020/03/18, Daniel Voss, Kobe University
c       Copyright (C) 2010,2011 Naota Hanasaki
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
c parameter (array)
      integer              n0l
      integer              n0x
      integer              n0y
      real                 p0lonmin
      real                 p0latmin
      real                 p0lonmax
      real                 p0latmax
c index
      integer              i0l            !! index of array (land)
      integer              i0x            !! index of array (x)
      integer              i0y            !! index of array (y)
      integer              icount         !! counter
      integer              ifive          !! percent
      integer              inext          !! next value Dan
      character            border         !! border boolean
      integer              mvmnt          !! movement for direction
      integer              flwdir         !! flow direction holder
      integer              origflw        !! testing against original
c temporary
      character*128        c0tmp          !! temporary
      real,allocatable::   r1tmp(:)       !! temporary
c function
      integer              igetnxx        !! lib/igetnxx.f
      integer              igetnxy        !! lib/igetnxy.f
      integer              igeti0l
      real                 rgetlat        !! lib/rgetlat.f
      real                 rgetlon        !! lib/rgetlon.f
      real                 rgetlen        !! lib/rgetlen.f
c in (map)
      integer,allocatable::i1l2x(:)       !! l to x 
      integer,allocatable::i1l2y(:)       !! l to y 
c      real,allocatable::   r2flwdir(:,:)  !! flow direction
      character*128        c0l2x          !! l to x
      character*128        c0l2y          !! l to y
      character*128        c0flwdir       !! flow direction
c out
      real,allocatable::   r1nxl(:)       !! next l (lower stream)
      real,allocatable::   r1len(:)       !! distance to next l (lower stream)
      character*128        c0nxl          !! next l (lower stream)
      character*128        c0len          !! distance to the lower stream
c local
      integer              i0nxx          !! next x (lower stream)
      integer              i0nxy          !! next y (lower stream)
      integer              i0nxl          !! next l (lower stream)
      real                 r0len          !! distance
      real                 r0lonorg       !! longitude of origin
      real                 r0latorg       !! latitude of origin
      real                 r0londes       !! longitude of destination
      real                 r0latdes       !! latitude of destination
      character*128        c0opt          !! option
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Get argument
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      if(iargc().ne.12)then
        write(*,*) 'calc_nxtmat n0l n0x n0y c0l2x c0l2y '
        write(*,*) '            p0lonmin p0lonmax p0latmin p0latmax '
        write(*,*) '            c0flwdir c0nxl c0len'
        stop
      end if
c
      call getarg(1,c0tmp)
      read(c0tmp,*) n0l
      call getarg(2,c0tmp)
      read(c0tmp,*) n0x
      call getarg(3,c0tmp)
      read(c0tmp,*) n0y
      call getarg(4,c0l2x)
      call getarg(5,c0l2y)
      call getarg(6,c0tmp)
      read(c0tmp,*) p0lonmin
      call getarg(7,c0tmp)
      read(c0tmp,*) p0lonmax
      call getarg(8,c0tmp)
      read(c0tmp,*) p0latmin
      call getarg(9,c0tmp)
      read(c0tmp,*) p0latmax
      call getarg(10,c0flwdir)
      call getarg(11,c0nxl)
      call getarg(12,c0len)
      write(*,*) 'calc_rivnxl: n0l     ', n0l
      write(*,*) 'calc_rivnxl: n0x     ', n0x 
      write(*,*) 'calc_rivnxl: n0y     ', n0y 
      write(*,*) 'calc_rivnxl: c0l2x   ', c0l2x
      write(*,*) 'calc_rivnxl: c0l2y   ', c0l2y 
      write(*,*) 'calc_rivnxl: c0flwdir', c0flwdir
      write(*,*) 'calc_rivnxl: c0nxl   ', c0nxl
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Allocate
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      allocate(i1l2x(n0l))
      allocate(i1l2y(n0l))
      allocate(r1tmp(n0l))
      allocate(r1nxl(n0l))
      allocate(r1len(n0l))
      write(*,*) 'calc_rivnxl: allocation completed'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Initialize
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      r1nxl=0.0
      r1len=0.0
      i0nxx=0
      i0nxy=0
      i0nxl=0
      r0len=0.0
      r0lonorg=0.0
      r0latorg=0.0
      r0londes=0.0
      r0latdes=0.0
      c0opt=''
      icount=0
      ifive=n0l/20
      border='F'
      mvmnt=0
      inext=0
      flwdir=0
      origflw=0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Read
c - read i1l2x and i1l2y
c - read c0flwdir and convert to 2d
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      call read_i1l2xy(n0l,c0l2x,c0l2y,i1l2x,i1l2y)
      write(*,*) 'calc_rivnxl: i1l2x',i1l2x(1)
c
      call read_binary(n0l,c0flwdir,r1tmp)
      write(*,*) 'calc_rivnxl: read completed'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Calculation
c - loop start
c - get x,y,lon,lat coordinate of lower grid, and get distance 
c - convert xy coordinate to l coordinate
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      c0opt='center'
      do i0y=1,n0y
        do i0x=1,n0x
c
          icount=icount+1
          mvmnt=0
          border='F'
          flwdir=int(r1tmp(icount))
          r0latorg=rgetlat(n0y,p0latmin,p0latmax,i0y,c0opt)
          r0lonorg=rgetlon(n0x,p0lonmin,p0lonmax,i0x,c0opt)
c
          if (flwdir.ge.1.and.flwdir.le.8) then
c           Left Moving Case
            if (flwdir.eq.6.or.flwdir.eq.7.or.flwdir.eq.8) then
              if (mod(icount,n0x).eq.1) then
                border='T'
              else
                mvmnt=mvmnt-1
              endif
            endif
c           Right Moving Case
            if (flwdir.eq.2.or.flwdir.eq.3.or.flwdir.eq.4) then
              if (mod(icount,n0x).eq.0) then
                border='T'
              else
                mvmnt=mvmnt+1
              endif
            endif
c           Upward Moving Case
            if (flwdir.eq.1.or.flwdir.eq.2.or.flwdir.eq.8) then
              if (icount.le.n0x) then
                border='T'
              else
                mvmnt=mvmnt-n0x
              endif
            endif
c           Downward Moving Case
            if (flwdir.eq.4.or.flwdir.eq.5.or.flwdir.eq.6) then
              if (icount.gt.(n0l-n0x)) then
                border='T'
              else
                mvmnt=mvmnt+n0x
              endif
            endif
c         No direction / Ocean Case
          else if (flwdir.eq.9.or.flwdir.eq.12) then
            i0nxx=i0x
            i0nxy=i0y
            r0londes=r0lonorg
            r0latdes=rgetlat(n0y,p0latmin,p0latmax,i0y-1,c0opt)
            r0len=rgetlen(r0lonorg,r0londes,r0latorg,r0latdes)
            write(*,*) 'entered a 9/12 loop'
          else
            border='T'
          end if
c
          if (border.eq.'F') then
            inext=icount+mvmnt
            i0nxx=i1l2x(inext)
            i0nxy=i1l2y(inext)
            r0londes=rgetlon(n0x,p0lonmin,p0lonmax,i0nxx,c0opt)
            r0latdes=rgetlat(n0y,p0latmin,p0latmax,i0nxy,c0opt)
            r0len=rgetlen(r0lonorg,r0londes,r0latorg,r0latdes)
          else
            inext=0
            i0nxx=0
            i0nxy=0
            r0len=0.0
          endif
          r1nxl(icount)=real(inext)
          r1len(icount)=r0len
        end do
      end do
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Write
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      call wrte_binary(n0l,r1nxl,c0nxl)
      call wrte_binary(n0l,r1len,c0len)
c
      end
