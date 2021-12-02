program hello
    implicit none
    integer :: distance = 0
    integer :: depth = 0
    integer :: answer1

    integer :: aim = 0
    integer :: depth2 = 0
    integer :: answer2

    character(10) :: command
    integer :: X
    do
      read (*,*,End = 100) command, X
      if (command == "forward") then
        distance = distance + X
        depth2 = depth2 + aim * X
      else if (command == "down") then
        depth = depth + X
        aim = aim + X
      else
        depth = depth - X
        aim = aim - X
      end if
    end do
100 answer1 = distance * depth
    answer2 = distance * depth2
    print *, answer1, answer2
end program hello
