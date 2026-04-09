module arbitrates between two master interfaces (m0 and m1)
 * and forwards the selected transaction to a single slave interface.
 *
 * Interface details:
 * - Masters (m0 and m1) use a ready-valid handshake.
 *   Their ready outputs (m0_read and m1_read) are driven by the slave's ready (s_read).
 * - The slave uses a ready-valid handshake (s_valid, s_data).
 *
 * Arbitration rules:
 * - If only one master asserts valid, its transaction is forwarded.
 * - If both masters assert valid concurrently:
 *       • When s_read is asserted, the arbitration uses the parameter AFINITY:
 *             AFINITY = 0  -> choose m0_data
 *             AFINITY = 1  -> choose m1_data
 * - First come, first served:
 *       • If masters drive transactions in different cycles, the first captured transaction is forwarded.
 * - One cycle latency:
 *       • The transaction captured is forwarded in the next cycle when s_read is high.
 */

module data_bus_controller #(
  parameter AFINITY = 0
)(
  input         clk,
  input         rst_n,
  
  output        m0_read,
  input         m0_valid,
  input  [31:0] m0_data,
  
  output        m1_read,
  input         m1_valid,
  input  [31:0] m1_data,
  
  input         s_read,
  output        s_valid,
  output [31:0] s_data
);

  // Drive master ready signals directly from slave ready
  assign m0_read = s_read;
  assign m1_read = s_read;

  // Internal register to hold the pending transaction.
  // This simple FIFO (depth = 1) ensures that if a transaction is captured,
  // it is held until the slave is ready, thereby implementing one-cycle latency.
  reg         pending_valid;
  reg  [31:0] pending_data;

  // Combinational logic to generate a new transaction from the masters.
  // Arbitration: if both masters are valid, select based on AFINITY.
  wire new_valid;
  wire [31:0] new_data;
  assign new_valid = m0_valid || m1_valid;
  assign new_data  = (m0_valid & ~m1_valid) ? m0_data :
                     (~m0_valid & m1_valid) ? m1_data :
                     (m0_valid & m1_valid)   ? (AFINITY==0 ? m0_data : m1_data) : 32'd0;

  // Sequential logic: capture a new transaction when possible,
  // and forward the pending transaction when the slave is ready.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pending_valid <= 1'b0;
      pending_data  <= 32'd0;
    end else begin
      if (s_read) begin
         // When slave is ready, output the pending transaction and clear it.
         // If no transaction is pending, capture a new one concurrently.
         if (pending_valid) begin
            pending_valid <= 1'b0;
         end else begin
            if (new_valid)
              pending_valid <= 1'b1;
            else
              pending_valid <= 1'b0;
         end
      end else begin
         // When slave is not ready, do not override an existing pending transaction.
         // Capture a new transaction only if none is pending.
         if (!pending_valid && new_valid)
           pending_valid <= 1'b1;
         // Else: hold the pending transaction.
      end
    end
  end

  // Drive the slave interface.
  // If a pending transaction exists, assert s_valid and drive s_data.
  assign s_valid = pending_valid;
  assign s_data  = pending_valid ? pending_data : 32'd0;

endmodule