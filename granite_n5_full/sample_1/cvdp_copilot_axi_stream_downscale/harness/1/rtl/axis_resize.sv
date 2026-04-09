module axis_resize (
  input clk,
  input resetn,
  input s_valid,
  output s_ready,
  input [15:0] s_data,
  output m_valid,
  input m_ready,
  output [7:0] m_data
);

  // Define local parameters and variables if necessary

  // Implement the functionality based on the specifications
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // Reset logic here
    end else begin
      // Main functionality here
      if (s_valid && m_ready) begin
        // Split the single-channel input data into two transactions on the master
        // Use bitwise operations to resize the data to 8 bits
        m_valid <= 1;
        m_data <= s_data[7:0];
        s_ready <= 1;
      end else begin
        // Handle other cases where neither s_valid nor m_ready is high
        m_valid <= 0;
        m_data <= 8'b0;
        s_ready <= 0;
      end
    end
  end

endmodule