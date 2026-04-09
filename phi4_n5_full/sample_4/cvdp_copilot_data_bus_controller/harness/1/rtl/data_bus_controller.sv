module data_bus_controller #(
  parameter AFINITY = 0  // Only allowed values: 0 or 1
)(
  input         clk,
  input         rst_n,
  
  // Master 0 interface
  output        m0_read,
  input         m0_valid,
  input  [31:0] m0_data,
  
  // Master 1 interface
  output        m1_read,
  input         m1_valid,
  input  [31:0] m1_data,
  
  // Slave interface
  input         s_read,
  output        s_valid,
  output [31:0] s_data
);

  // Pipeline register to hold the transaction data and valid flag.
  // This introduces one cycle latency.
  reg         trans_valid;
  reg  [31:0] trans_data;
  
  // Register to capture handshake acceptance from the previous cycle.
  // When s_read and s_valid were both high, the transaction is accepted by the slave.
  reg         handshake_detected;
  
  // Drive master ready signals from the slave ready signal.
  // Masters are ready only when the slave is ready.
  assign m0_read = s_read;
  assign m1_read = s_read;
  
  // Drive the slave interface using the pipeline register.
  assign s_valid = trans_valid;
  assign s_data  = trans_data;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      trans_valid      <= 1'b0;
      trans_data       <= 32'b0;
      handshake_detected <= 1'b0;
    end else begin
      // If the transaction was accepted in the previous cycle, clear the pipeline.
      if (handshake_detected) begin
        trans_valid <= 1'b0;
        trans_data  <= 32'b0;
      end
      // Only capture a new transaction if the pipeline is empty.
      else if (!trans_valid) begin
        // If only one master drives a valid transaction, capture that one.
        if (m0_valid && !m1_valid) begin
          trans_valid <= 1'b1;
          trans_data  <= m0_data;
        end else if (m1_valid && !m0_valid) begin
          trans_valid <= 1'b1;
          trans_data  <= m1_data;
        end
        // If both masters drive a valid transaction in the same cycle,
        // choose based on the AFINITY parameter.
        else if (m0_valid && m1_valid) begin
          if (AFINITY == 0) begin
            trans_valid <= 1'b1;
            trans_data  <= m0_data;
          end else begin
            trans_valid <= 1'b1;
            trans_data  <= m1_data;
          end
        end
      end
      // Sample the handshake acceptance for use in the next cycle.
      // The transaction is considered accepted if both s_read and s_valid were high.
      handshake_detected <= (s_read && s_valid);
    end
  end

endmodule