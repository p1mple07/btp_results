module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)(
    input  logic                 clk,
    input  logic                 resetn,
    input  logic                 enable,
    input  logic [DATA_WIDTH-1:0] start_val,
    input  logic [DATA_WIDTH-1:0] step_size,
    output logic [OUT_VAL_WIDTH-1:0] out_val,
    output logic                 done
);

   // Define the output width. When SEQUENCE_LENGTH is 0, we want out_val to be DATA_WIDTH bits;
   // otherwise, we add extra bits (computed via $clog2) to help prevent overflow.
   localparam int OUT_VAL_WIDTH = (SEQUENCE_LENGTH == 0) ? DATA_WIDTH : (DATA_WIDTH + $clog2(SEQUENCE_LENGTH));

   // Use a generate-if to handle the SEQUENCE_LENGTH==0 edge case.
   generate
       if (SEQUENCE_LENGTH == 0) begin : trivial_case
           // In the trivial case, no sequence is generated.
           always_ff @(posedge clk or negedge resetn) begin
               if (!resetn) begin
                   out_val <= '0;
                   done   <= 1'b0;
               end else begin
                   out_val <= '0;
                   done   <= 1'b0;
               end
           end
       end else begin : normal_case
           // For a valid (nonzero) sequence length, compute the counter width.
           localparam int COUNTER_WIDTH = $clog2(SEQUENCE_LENGTH);
           // current_val is wide enough to hold the progression value.
           logic [OUT_VAL_WIDTH-1:0] current_val;
           // counter tracks the number of generated terms.
           logic [COUNTER_WIDTH-1:0] counter;

           always_ff @(posedge clk or negedge resetn) begin
               if (!resetn) begin
                   current_val <= 0;
                   counter     <= 0;
                   done        <= 1'b0;
               end else if (enable) begin
                   if (!done) begin
                       if (counter == 0) begin
                           current_val <= start_val;
                       end else begin
                           current_val <= current_val + step_size;
                       end
                       if (counter < SEQUENCE_LENGTH - 1) begin
                           counter <= counter + 1;
                       end else begin
                           done <= 1'b1;
                       end
                   end
               end
           end

           assign out_val = current_val;
       end
   endgenerate

endmodule