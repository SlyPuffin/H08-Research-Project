      program hydro
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cto         estimate hydro power potential
cby         2020/03/15, Daniel Voss, Kobe University
cformatby   2010/09/30, hanasaki, NIES: H08ver1.0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
c parameter (array)
      integer           n0l             !! number of grids in horizontal
      integer           n0t
      integer           n0d
      parameter        (n0l=5760000)
      parameter        (n0t=3)
      parameter        (n0d=144)
c parameter (physical)
      integer           n0secday        !! seconds of a day
      parameter        (n0secday=86400)
c parameter (default) 
      real              p0mis
      parameter        (p0mis=1.0E20) 
c index (array)
      integer           i0l             !! land
c index (time)
      integer           i0year          !! year
      integer           i0mon           !! month
      integer           i0day           !! day 
      integer           i0sec           !! sec
c temporary
      character*128     c0opt           !! option
      real              r1tmp(n0l)
c function
      integer           iargc           !! number of argument
      integer           igetday         !! number of day in the month
c in (set)
      integer           i0yearmin       !! start year
      integer           i0yearmax       !! end year
      integer           i0secint        !! interval
      integer           i0ldbg          !! land debugging point
c in (file)
      real              r1rivnxd(n0l)   !! distance to next grid [m]
      real              r1lndara(n0l)   !! land area [m2]
      real              r1head(n0l)     !! hydro head [m]
      real              r1usabdisc(n0l) !! usable discharge [kg/s]
      real              r1rivout(n0l)   !! daily discharge
      real              r1perc(n0l)     !! efficiency [%]
      character*128     c0rivnxd        !! distance to next grid
      character*128     c0lndara        !! land area
      character*128     c0head          !! hydro head
      character*128     c0usabdisc        !! usable discharge 
      character*128     c0rivout        !! daily dischage [kg/s]
      character*128     c0perc          !! percentage efficiency
c state variable
c      real              r1rivsto(n0l)   !! river storage [kg]
c      real              r2rivsto(n0l,0:n0t)   !! river storage [kg]
c      real              r1rivsto_pr(n0l)!! river storage of previous ts [kg]
c      character*128     c0rivsto        !! river storage
c      character*128     c0rivstoini     !! initial river storage
c out
c      real              r1rivout(n0l)   !! discharge [kg/s]
c      real              r2rivout(n0l,0:n0t)   !! discharge [kg/s]
c      character*128     c0rivout        !! river discharge
      real              r1hydropot(n0l) !! hydropower potential [kW]
      real              r2hydropot(n0l,0:n0t) !! hydropower potential [kW]
      character*128     c0hydropot      !! hydropower potential
c local
      integer           i0yearmin_dummy !! dummy yearmin for spinup [-]
      integer           i0yearmax_dummy !! dummy yearmax for spinup [-]
      integer           total_days      !! total day count
      integer           counter         !! counter for days
      real              perc            !! percentage efficiency
      real              available_head  !! available head [m]
      real              days_array(n0d) !! for sorting through the days
      real              days_out(n0d)   !! output array
      real              ex1(n0d)        !! extra output 1
      real              ex2(n0d)        !! extra output 2
c namelist
      character*128     c0sethydro        !! setting file for river model
      namelist         /sethydro/ c0rivout,   c0rivnxd,
     $                          c0lndara, c0head, c0perc,
     $                          c0usabdisc, c0hydropot,
     $                          i0ldbg,   i0secint, 
     $                          i0yearmin,i0yearmax
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Get arguments
c - check the number of arguments
c - get arguments
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if(iargc().ne.1) then
        write(*,*) 'Usage: main c0sethydro'
        stop
      end if
c
      call getarg(1, c0sethydro)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Initialize
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c out
      r1hydropot=0.0
      r2hydropot=0.0
c local
      i0yearmin_dummy=0
      i0yearmax_dummy=0
      available_head=0.0
      days_array=0.0
      days_out=0.0
      ex1=0.0
      ex2=0.0
      counter=0
      perc=0.0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Read namelists
c - read c0setriv
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      open(10,file=c0sethydro)
      read(10,nml=sethydro)
      close(10)
      write(*,*) 'main: --- Read namelist ---------------------------'
      write(*,nml=sethydro)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Compute hydro power potential
c - read in binary files
c - calculate power for each cell
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      call read_binary(n0l,c0rivnxd,r1rivnxd)
      call read_binary(n0l,c0lndara,r1lndara)
      call read_binary(n0l,c0head,r1head)
      call read_binary(n0l,c0usabdisc,r1usabdisc)
c
      do i0l=1,n0l
      available_head=0.0
        if (r1rivnxd(i0l).gt.0.0) then
          available_head=r1head(i0l)-(r1rivnxd(i0l)/real(500))
          if (available_head.gt.0.0) then
            r1hydropot(i0l)=available_head*r1usabdisc(i0l)*9.8*0.72
          else 
            r1hydropot(i0l)=0.0
          end if
        else
c          r1hydropot(i0l)=p0mis
          r1hydropot(i0l)=0.0
        end if
      end do
d     write(*,*) 'hydro power potential fin'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Calculate percent effectiveness
c - read in river discharge monthly
c - sort months from largest to smallest
c - compare 75 percentile value against usable discharge
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      do i0l=1,n0l
        days_array=0.0
        days_out=0.0
        counter=1
        i0day=0
        i0sec=0
        if (r1hydropot(i0l).gt.0.0) then
        do i0year=i0yearmin,i0yearmax
          do i0mon=1,12
                write(*,*) i0year,i0mon,i0day,i0sec
c 
              call read_result(
     $             n0l,
     $             c0rivout,      i0year,     i0mon,
     $             i0day,       i0sec,      i0secint,
     $             r1rivout)
            days_array(counter)=r1rivout(i0l)
c
            counter=counter+1
          end do
        end do
c        SORT
        call sort_incord(n0d,days_array,days_out,ex1,ex2)
c        ADD TO FILE
        write(*,*) days_out(1),' first then last ',days_out(n0d)
c        perc=r1usabdisc(i0l)/days_out(108)
        write(*,*) 'percentage ',perc,' i0l ',i0l
        else
          perc=0.0
        end if
        r1perc(i0l)=perc
      end do
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Write to file
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      write(*,*) 'hydro:  write to file.'
      call wrte_binary(n0l,r1hydropot,c0hydropot)
c
      end
