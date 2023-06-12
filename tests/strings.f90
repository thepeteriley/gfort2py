! SPDX-License-Identifier: GPL-2.0+

module strings

	use iso_fortran_env, only: output_unit, real128
	
	implicit none
	
	! Parameters
	integer, parameter :: dp = selected_real_kind(p=15)
	integer, parameter :: qp = selected_real_kind(p=30)
	integer, parameter :: lp = selected_int_kind(8)
	
	
	character(len=10),parameter :: const_str='1234567890'
	
	character(len=10) :: a_str
	character(len=10) :: a_str_set='abcdefghjk'
	character(:), allocatable :: str_alloc


	character(len=10),dimension(5) :: a_str_exp_1d
	character(len=10),dimension(5,5) :: a_str_exp_2d
	character(len=10),dimension(5,5,5) :: a_str_exp_3d
	
	
	character(len=10),dimension(:),allocatable :: b_str_alloc_1d
	character(len=10),dimension(:,:),allocatable :: b_str_alloc_2d
	character(len=10),dimension(:,:,:),allocatable :: b_str_alloc_3d


	type str_array_dt
		integer :: start_guard = 123456789
		character(len=10),dimension(5) :: a_str_exp_1d
		integer :: end_guard = 123456789
	end type str_array_dt

	contains
	
	subroutine sub_str_in_explicit(x)
		character(len=10), intent(in) ::x
		write(output_unit,*) trim(x)
	end subroutine sub_str_in_explicit
	
	subroutine sub_str_in_implicit(x)
		character(len=*), intent(in) ::x
		write(output_unit,*) trim(x)
	end subroutine sub_str_in_implicit
	
	subroutine sub_str_multi(x,y,z)
		integer, intent(in) ::x,z
		character(len=*), intent(in) ::y
		write(output_unit,'(I1,1X,A)') x+z,trim(y)
	end subroutine sub_str_multi
	
	subroutine sub_str_alloc(x_alloc)
		character(:), allocatable, intent(out) :: x_alloc
		x_alloc = 'abcdef'
	end subroutine sub_str_alloc
	
	subroutine sub_str_p(zzz)
		character(len=*),pointer, intent(inout) :: zzz
		
		write(output_unit,'(A)') zzz
		
		zzz = 'xyzxyz'
	end subroutine sub_str_p
      
      
	character(len=5) function func_ret_str(x)
		character(len=5) :: x
		
		func_ret_str = x
		func_ret_str(1:1) = 'A'
		
	end function func_ret_str
	
	
	logical function check_str_alloc(ver)
		integer :: ver
		
		check_str_alloc = .false.
		
		if(allocated(str_alloc)) then
		    !write(*,*) allocated(str_alloc)
			!write(*,*) str_alloc
			if(ver==1) then
				if(str_alloc(1:16)=='abcdefghijklmnop')  check_str_alloc = .true.
			else if (ver==2) then 
				if(str_alloc(1:8)=='12346578')  check_str_alloc = .true.
			end if
		end if
	
	end function check_str_alloc
	

	subroutine alter_str_alloc()
		
		str_alloc = 'qwerty'
	
	end subroutine alter_str_alloc
	

	subroutine sub_str_alloc2(x)
		character(len=:),allocatable,intent(inout) :: x
		
		if(.not.allocated(x)) then
			x='zxcvbnm'
			return
		end if

		if(allocated(x)) then
			write(*,*) "*",x,"*",len_trim(x)
			if(x == 'qwerty') then
				write(*,*) "Set 1"
				x = 'asdfghjkl'
				! write(*,*) "Set 2"
			end if
		end if
	
	end subroutine sub_str_alloc2
	

	
	function func_str_int_len(i) result(s)
		! Github issue #12
		integer, intent(in) :: i
		character(len=str_int_len(i)) :: s
		write(s, '(i0)') i
	end function func_str_int_len
		  
	pure integer function str_int_len(i) result(sz)
		! Returns the length of the string representation of 'i'
		integer, intent(in) :: i
		integer, parameter :: MAX_STR = 100
		character(MAX_STR) :: s
		! If 's' is too short (MAX_STR too small), Fortran will abort with:
		! "Fortran runtime error: End of record"
		write(s, '(i0)') i
		sz = len_trim(s)
	end function str_int_len


	subroutine str_array_inout(x)
		character(len=10),dimension(5) :: x

		integer :: i

		do i=1,5
			write(*,*) trim(x(i))
		end do


		x(1) = 'zzzzzzzzzz'
		x(2) = 'yyyyyyyyyy'
		x(3) = 'qqqqqqqqqq'
		x(4) = 'wwwwwwwwww'
		x(5) = 'xxxxxxxxxx'


	end subroutine str_array_inout


	subroutine str_array_inout2(x,n)
		character(len=10),dimension(n) :: x
		integer,intent(in) :: n

		integer :: i

		do i=1,5
			write(*,*) trim(x(i))
		end do


		x(1) = 'zzzzzzzzzz'
		x(2) = 'yyyyyyyyyy'
		x(3) = 'qqqqqqqqqq'
		x(4) = 'wwwwwwwwww'
		x(5) = 'xxxxxxxxxx'


	end subroutine str_array_inout2


	subroutine str_array_inout3(x)
		character(len=10),dimension(:) :: x

		integer :: i

		do i=1,5
			write(*,*) trim(x(i))
		end do


		x(1) = 'zzzzzzzzzz'
		x(2) = 'yyyyyyyyyy'
		x(3) = 'qqqqqqqqqq'
		x(4) = 'wwwwwwwwww'
		x(5) = 'xxxxxxxxxx'


	end subroutine str_array_inout3


	subroutine str_array_inout4(x)
		character(len=*),dimension(5) :: x

		integer :: i

		do i=1,5
			write(*,*) trim(x(i))
		end do


		x(1) = 'zzzzzzzzzz'
		x(2) = 'yyyyyyyyyy'
		x(3) = 'qqqqqqqqqq'
		x(4) = 'wwwwwwwwww'
		x(5) = 'xxxxxxxxxx'


	end subroutine str_array_inout4


	logical function func_str_array_dt(x)
		type(str_array_dt) :: x

		func_str_array_dt = .false.

		if(x%start_guard/=123456789 .or. x% end_guard/=123456789) then
			return
		end if


		if(x%a_str_exp_1d(1) /= 'zzzzzzzzzz') return
		if(x%a_str_exp_1d(2) /= 'yyyyyyyyyy') return
		if(x%a_str_exp_1d(3) /= 'qqqqqqqqqq') return
		if(x%a_str_exp_1d(4) /= 'wwwwwwwwww') return
		if(x%a_str_exp_1d(5) /= 'xxxxxxxxxx') return

		func_str_array_dt = .true.


	end function func_str_array_dt
		  

end module strings
