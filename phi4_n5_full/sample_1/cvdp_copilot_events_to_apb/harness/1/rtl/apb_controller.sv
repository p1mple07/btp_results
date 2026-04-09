module apb_controller (
    input  logic         clk,
    input  logic         reset_n,
    input  logic         select_a_i,
    input  logic         select_b_i,
    input  logic         select_c_i,
    input  logic [31:0]  addr_a_i,
    input  logic [31:0]  data_a_i,
    input  logic [31:0]  addr_b_i,
    input  logic [31:0]  data_b_i,
    input  logic [31:0]  addr_c_i,
    input  logic [31:0]  data_c_i,
    input  logic         apb_pready_i,
    output reg           apb_psel_o,
    output reg           apb_penable_o,
    output reg           apb_pwrite_o,
    output reg [31:0]    apb_paddr_o,
    output reg [31:0]    apb_pwdata_o
);

  // State encoding
  localparam IDLE   = 2'b00;
  localparam SETUP  = 2'b01;
  localparam ACCESS = 2'b10;

  reg [1:0] state, next_state;
  reg [31:0] captured_addr;
  reg [31:0] captured_data;
  reg [3:0]  timeout_counter;

  // Sequential logic: state register, capture registers, and timeout counter
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state            <= IDLE;
      captured_addr    <= 32'b0;
      captured_data    <= 32'b0;
      timeout_counter  <= 4'b0;
    end else begin
      state <= next_state;
      
      // In IDLE state, capture the address and data if an event is triggered.
      if (state == IDLE) begin
        if (select_a_i) begin
          captured_addr <= addr_a_i;
          captured_data <= data_a_i;
        end else if (select_b_i) begin
          captured_addr <= addr_b_i;
          captured_data <= data_b_i;
        end else if (select_c_i) begin
          captured_addr <= addr_c_i;
          captured_data <= data_c_i;
        end
      end

      // In ACCESS state, update the timeout counter if the peripheral is not ready.
      if (state == ACCESS) begin
        if (!apb_pready_i)
          timeout_counter <= timeout_counter + 1;
        else
          timeout_counter <= 4'b0;
      end
    end
  end

  // Combinational logic: next state and output logic
  always_comb begin
    // Default assignments
    next_state        = state; // Default: remain in the same state
    apb_psel_o        = 1'b0;
    apb_penable_o     = 1'b0;
    apb_pwrite_o      = 1'b0;
    apb_paddr_o       = 32'b0;
    apb_pwdata_o      = 32'b0;

    case (state)
      IDLE: begin
        // If any event is triggered, prioritize select_a_i, then select_b_i, then select_c_i.
        if (select_a_i || select_b_i || select_c_i) begin
          // Transition to SETUP state; capture occurs in the sequential block.
          next_state = SETUP;
        end else begin
          next_state = IDLE;
        end
      end

      SETUP: begin
        // Assert APB signals for write transaction.
        apb_psel_o    = 1'b1;
        apb_pwrite_o  = 1'b1;
        apb_paddr_o   = captured_addr;
        apb_pwdata_o  = captured_data;
        // apb_penable_o remains deasserted in SETUP.
        next_state = ACCESS;
      end

      ACCESS: begin
        // Assert APB enable signal during ACCESS phase.
        apb_psel_o    = 1'b1;
        apb_pwrite_o  = 1'b1;
        apb_paddr_o   = captured_addr;
        apb_pwdata_o  = captured_data;
        apb_penable_o = 1'b1;

        // Check for transaction completion or timeout.
        if (apb_pready_i) begin
          // Peripheral is ready: complete the transaction.
          next_state = IDLE;
        end else if (timeout_counter >= 15) begin
          // Timeout reached: abort the transaction and return to IDLE.
          next_state = IDLE;
        end else begin
          // Remain in ACCESS state waiting for the peripheral.
          next_state = ACCESS;
        end
      end

      default: next_state = IDLE;
    endcase
  end

endmodule