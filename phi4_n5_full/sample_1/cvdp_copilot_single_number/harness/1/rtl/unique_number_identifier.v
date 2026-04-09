module unique_number_identifier #(
    parameter p_bit_width  = 8, 
    parameter p_max_numbers = 16 
)(
    input  wire                     i_clk,
    input  wire                     i_rst_n,
    input  wire                     i_ready,
    input  wire [p_bit_width-1:0]   i_number,
    output reg  [p_bit_width-1:0]   o_unique_number
);

  // Register to hold the accumulated XOR result
  reg [p_bit_width-1:0] unique_reg;
  
  // Counter to track how many numbers have been processed.
  // The counter width is sized to cover values from 0 to p_max_numbers.
  reg [$clog2(p_max_numbers+1)-1:0] count_reg;

  // Sequential process: update state on clock edge or asynchronous reset.
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      unique_reg <= 0;
      count_reg  <= 0;
    end
    else if (i_ready) begin
      if (count_reg < p_max_numbers) begin
        // XOR the new number into the running result.
        unique_reg <= unique_reg ^ i_number;
        // Increment the counter.
        count_reg  <= count_reg + 1;
      end
    end
  end

  // Continuous assignment: output reflects the current accumulated value.
  always @(*) begin
    o_unique_number = unique_reg;
  end

endmodule