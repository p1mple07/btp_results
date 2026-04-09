rtl/16qam_demapper.sv
--------------------------------------------------
module qam16_demapper_interpolated #
  (
   parameter int N               = 4,
   parameter int OUT_WIDTH       = 4,
   parameter int IN_WIDTH        = 3,
   parameter int ERROR_THRESHOLD = 1
   )
  (
   input  signed logic [((N + (N/2)) * IN_WIDTH - 1) : 0] I,
   input  signed logic [((N + (N/2)) * IN_WIDTH - 1) : 0] Q,
   output logic [N*OUT_WIDTH - 1:0] bits,
   output logic error_flag
   );

   // Extended width for intermediate arithmetic (to accommodate carry)
   localparam int EXT_WIDTH = IN_WIDTH + 1;

   //-------------------------------------------------------------------------
   // Function: map_val
   // Maps a QAM16 amplitude (one of -3, -1, 1, 3) to its 2-bit representation.
   //-------------------------------------------------------------------------
   function automatic logic [1:0] map_val;
     input signed [IN_WIDTH-1:0] val;
     case (val)
       -3: map_val = 2'b00;
       -1: map_val = 2'b01;
        1: map_val = 2'b10;
        3: map_val = 2'b11;
       default: map_val = 2'b00;
     endcase
   endfunction

   //-------------------------------------------------------------------------
   // Main combinational logic
   //-------------------------------------------------------------------------
   always_comb begin
      // Initialize outputs
      bits       = '0;
      error_flag = 1'b0;

      //-------------------------------------------------------------------------
      // Process each group of 2 mapped symbols and one interpolated sample.
      // For each group g (0 <= g < N/