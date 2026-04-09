module csr_apb_interface #(parameter N_DATA = 32) (
	 input wire pclk,
	 input wire rst,
	 input wire pselx,
	 input wire penable,
	 input wire pwrite,
	 input wire [N_DATA-1:0] pwdata,
	 output reg [N_DATA-1:0] prdata,
	 output reg pslverr,
	 output reg [2:0] fsm_state
 );