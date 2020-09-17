      program accuracy
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cto         calculate hydro power estimation accuracy
cby         2020/07/10, Daniel Voss, Kobe University
cformatby   2010/09/30, hanasaki, NIES: H08ver1.0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
c parameter (array)
      integer           n0l             !! number of grids in horizontal
      integer           n0t
      integer           n0d
      parameter        (n0l=57600)
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
      integer           icount          !! list counter
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
      real              r1hydropot(n0l)   !! hydropower potential [kW]
      real              r1comppot(n0l)    !! comparison potential [kW]
      real              r1compid(n0l)     !! comparison id [int]
      character*128     c0hydropot        !! hydropower potential
      character*128     c0comppot         !! comparison potential
      character*128     c0compid          !! comparison id
c state variable
c      real              r1rivsto(n0l)   !! river storage [kg]
c      real              r2rivsto(n0l,0:n0t)   !! river storage [kg]
c      real              r1rivsto_pr(n0l)!! river storage of previous ts [kg]
c      character*128     c0rivsto        !! river storage
c      character*128     c0rivstoini     !! initial river storage
c out
      real              r1error(n0l)     !! error in potential [kW]
      real              r2error(n0l,0:n0t) !! hydropower potential [kW]
      real              hydrlist(n0l)    !! list of estimated pot [kW]
      real              complist(n0l)    !! list of comparison pot [kW]
      character*128     c0error          !! error in potential
      character*128     c0hydrlist       !! list of estimated pot
      character*128     c0complist       !! list of comparison pot
c local
      integer           i0yearmin_dummy !! dummy yearmin for spinup [-]
      integer           i0yearmax_dummy !! dummy yearmax for spinup [-]
      integer           total_days      !! total day count
      integer           counter         !! counter for days
      real              idarray(200000) !! id array
      real              divisor         !! result real
      real              perc            !! percentage efficiency
      real              potdif          !! difference in potential [kW]
      real              diflist(n0l)    !! list for difpot [kW]
      real              days_array(n0d) !! for sorting through the days
      real              days_out(n0d)   !! output array
      real              ex1(n0d)        !! extra output 1
      real              ex2(n0d)        !! extra output 2
c namelist
      character*128     c0setaccuracy   !! setting file for river model
      namelist         /setaccuracy/ c0hydropot, c0comppot,
     $                          c0error, c0hydrlist, c0complist,
     $                          c0compid, i0ldbg,   i0secint, 
     $                          i0yearmin,i0yearmax
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Get arguments
c - check the number of arguments
c - get arguments
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if(iargc().ne.1) then
        write(*,*) 'Usage: accuracy c0setaccuracy'
        stop
      end if
c
      call getarg(1, c0setaccuracy)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Initialize
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c out
      r1error=0.0
      r2error=0.0
c local
      i0yearmin_dummy=0
      i0yearmax_dummy=0
      idarray=0.0
      potdif=0.0
      hydrlist=0.0
      complist=0.0
      ex1=0.0
      ex2=0.0
      counter=0
      divisor=0.0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Read namelists
c - read c0setaccuracy
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      open(8,file=c0setaccuracy)
      read(8,nml=setaccuracy)
      close(8)
      write(*,*) 'accuracy: --- Read namelist -----------------------'
      write(*,nml=setaccuracy)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Calculate simulated potential vs. kankyosho study
c - read in binaries of kankyosho ID&Potenial, and H08 Potential
c - add H08 potential for each instance of an ID
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      call read_binary(n0l,c0hydropot,r1hydropot)
      call read_binary(n0l,c0comppot,r1comppot)
      call read_binary(n0l,c0compid,r1compid)
c
      write(*,*) 'start first block'
      do i0l=1,n0l
        counter=0
        if (r1compid(i0l).gt.0.0) then
          counter=int(r1compid(i0l))
          idarray(counter)=idarray(counter)+r1hydropot(i0l)
        end if
      end do
      counter=0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
c Write results to files
c - read total values at each ID
c - write out final values to .txt files
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc 
      write(*,*) 'start second block'
      call wrte_binary(n0l,r1error,c0error)
      open(11,file=c0hydrlist)
      open(12,file=c0complist)
      do i0l=1,n0l
        potdif=0.0
        if (r1comppot(i0l).gt.0.0) then
          potdif=idarray(int(r1compid(i0l)))
          write(*,*) 'potdif ',potdif
          if (potdif.gt.-1) then
            write(11,*) potdif
            write(12,*) r1comppot(i0l)
            idarray(int(r1compid(i0l)))=-1
          end if
        end if
      end do
      close(11)
      close(12)
      write(*,*) 'finish writing to files',counter
c
      end
