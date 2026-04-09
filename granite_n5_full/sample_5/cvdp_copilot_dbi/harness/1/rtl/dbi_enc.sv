module dbi_enc (
  // Input ports
  input wire [39:0] data_in,
  input wire clk,
  input wire rst_n,

  // Output ports
  output reg [39:0] data_out,
  output reg [1:0] dbi_cntrl
);

// Local parameters and variables
localparam GROUP_SIZE = 20;
reg [GROUP_SIZE-1:0] group_prev[2];
reg [GROUP_SIZE-1:0] group_curr[2];
reg [GROUP_SIZE-1:0] group_diff[2];
reg [1:0] dbi_ctrl_internal;

// Split data into two groups
assign {group_curr[1], group_curr[0]} = data_in;

// Compare current group with previous group
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    // Reset the flip-flops
    group_prev <= {GROUP_SIZE{1'b0}};
    group_curr <= {GROUP_SIZE{1'b0}};
    dbi_ctrl_internal <= 2'b00;
  end else begin
    // Update previous group
    group_prev <= group_curr;
    
    // Calculate difference between current and previous group
    group_diff[0] <= group_curr[0] ^ group_prev[0];
    group_diff[1] <= group_curr[1] ^ group_prev[1];
    
    // Determine control signals
    if (|group_diff[0]) begin
      dbi_ctrl_internal[0] <= 1'b1;
    end else begin
      dbi_ctrl_internal[0] <= 1'b0;
    end
    if (|group_diff[1]) begin
      dbi_ctrl_internal[1] <= 1'b1;
    end else begin
      dbi_ctrl_internal[1] <= 1'b0;
    end
  end
end

// Generate data output based on control signals
assign dbi_cntrl = dbi_ctrl_internal;
assign data_out[39:20] = (dbi_ctrl_internal == 2'b11)? group_curr[1] : {GROUP_SIZE{1'b0}};
assign data_out[19:0] = (dbi_ctrl_internal == 2'b01)? group_curr[0] : {GROUP_SIZE{1'b0}};

endmodule