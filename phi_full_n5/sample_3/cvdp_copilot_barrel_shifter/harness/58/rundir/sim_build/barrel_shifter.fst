$date
	Sat Mar 21 06:15:17 2026
$end
$version
	Icarus Verilog
$end
$timescale
	1ns
$end
$scope module barrel_shifter $end
$var wire 8 ! data_in [7:0] $end
$var wire 1 " enable $end
$var wire 1 # enable_parity $end
$var wire 1 $ left_right $end
$var wire 8 % mask [7:0] $end
$var wire 3 & mode [2:0] $end
$var wire 3 ' shift_bits [2:0] $end
$var parameter 32 ( data_width $end
$var parameter 32 ) shift_bits_width $end
$var reg 8 * data_out [7:0] $end
$var reg 1 + error $end
$var reg 1 , parity_out $end
$upscope $end
$enddefinitions $end
$comment Show the parameter values. $end
$dumpall
b11 )
b1000 (
$end
#0
$dumpvars
1,
0+
b10101000 *
b10 '
b0 &
b0 %
1$
1#
1"
b101010 !
$end
#5
0,
b1111 *
0$
b111100 !
#10
b1010 *
b1 &
b101011 !
#15
b10101100 *
1$
b10 &
#20
1,
b1000 *
b111100 %
0$
b11 &
#25
0,
b10101100 *
b0 %
1$
b100 &
#30
