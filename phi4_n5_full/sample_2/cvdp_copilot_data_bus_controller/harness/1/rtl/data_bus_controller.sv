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

  // Internal registers to implement one-cycle latency.
  // valid_reg indicates that a transaction is registered.
  // data_reg holds the transaction data.
  // clear_next is used to delay clearing the registered transaction until the next cycle.
  reg valid_reg;
  reg [31:0] data_reg;
  reg clear_next;

  // The handshake always registers a transaction from the masters (if any)
  // and then outputs it one cycle later.
  // If both masters drive a transaction in the same cycle, AFINITY selects which one.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_reg   <= 1'b0;
      data_reg    <= 32'd0;
      clear_next  <= 1'b0;
    end else begin
      // If the previous cycle had a registered transaction and the slave was ready,
      // schedule clearing the register in this cycle.
      if (clear_next) begin
        valid_reg   <= 1'b0;
        data_reg    <= 32'd0;
        clear_next  <= 1'b0;
      end
      // If there is no registered transaction, sample the masters.
      else if (!valid_reg) begin
        if (m0_valid || m1_valid) begin
          // If both masters are valid simultaneously, use AFINITY to choose.
          if (m0_valid && m1_valid) begin
            if (AFINITY == 0)
              data_reg <= m0_data;
            else
              data_reg <= m1_data;
          end
          else if (m0_valid)
            data_reg <= m0_data;
          else if (m1_valid)
            data_reg <= m1_data;
          valid_reg <= 1'b1;
        end
      end
      // Set the flag to clear the registered transaction in the next cycle
      // if the slave is ready.
      clear_next <= (s_read && valid_reg);
    end
  end

  // Drive the slave interface outputs.
  // s_valid and s_data present the registered transaction.
  assign s_valid = valid_reg;
  assign s_data  = data_reg;

  // The master ready signals are simply driven by the slave's ready.
  assign m0_read = s_read;
  assign m1_read = s_read;

endmodule