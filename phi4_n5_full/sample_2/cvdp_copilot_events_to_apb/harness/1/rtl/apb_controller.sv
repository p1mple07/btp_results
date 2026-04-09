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
  output logic         apb_psel_o,
  output logic         apb_penable_o,
  output logic         apb_pwrite_o,
  output logic [31:0]  apb_paddr_o,
  output logic [31:0]  apb_pwdata_o
);

  // State encoding: IDLE, SETUP, ACCESS
  localparam logic [1:0] IDLE   = 2'b00;
  localparam logic [1:0] SETUP  = 2'b01;
  localparam logic [1:0] ACCESS = 2'b10;

  // Internal registers to capture the selected event's address and data.
  reg  [31:0] addr_reg;
  reg  [31:0] data_reg;
  // 4-bit timeout counter (counts clock cycles in ACCESS phase)
  reg  [3:0]  timeout_counter;
  // State register
  reg  [1:0]  state;

  // Synchronous state machine with outputs driven in one always_ff block.
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state            <= IDLE;
      timeout_counter  <= 4'd0;
      addr_reg         <= 32'd0;
      data_reg         <= 32'd0;
      apb_psel_o       <= 1'b0;
      apb_penable_o    <= 1'b0;
      apb_pwrite_o     <= 1'b0;
      apb_paddr_o      <= 32'd0;
      apb_pwdata_o     <= 32'd0;
    end
    else begin
      case (state)
        // IDLE State: Capture transaction info if an event is triggered.
        IDLE: begin
          // Priority: select_a_i > select_b_i > select_c_i.
          if (select_a_i) begin
            addr_reg <= addr_a_i;
            data_reg <= data_a_i;
            state    <= SETUP;
          end
          else if (select_b_i) begin
            addr_reg <= addr_b_i;
            data_reg <= data_b_i;
            state    <= SETUP;
          end
          else if (select_c_i) begin
            addr_reg <= addr_c_i;
            data_reg <= data_c_i;
            state    <= SETUP;
          end
          else begin
            state <= IDLE;
          end

          // Ensure outputs are deasserted in IDLE.
          apb_psel_o   <= 1'b0;
          apb_penable_o<= 1'b0;
          apb_pwrite_o <= 1'b0;
          apb_paddr_o  <= 32'd0;
          apb_pwdata_o <= 32'd0;
          timeout_counter <= 4'd0;
        end

        // SETUP Phase: Assert APB control signals and load address/data.
        SETUP: begin
          apb_psel_o   <= 1'b1;
          apb_pwrite_o <= 1'b1;
          apb_paddr_o  <= addr_reg;
          apb_pwdata_o <= data_reg;
          // penable remains low.
          apb_penable_o<= 1'b0;
          state        <= ACCESS;
        end

        // ACCESS Phase: Maintain signals and wait for peripheral ready.
        ACCESS: begin
          apb_psel_o   <= 1'b1;
          apb_pwrite_o <= 1'b1;
          apb_paddr_o  <= addr_reg;
          apb_pwdata_o <= data_reg;
          apb_penable_o<= 1'b1;
          // If peripheral asserts ready, complete transaction.
          if (apb_pready_i) begin
            state        <= IDLE;
            // Deassert control signals immediately upon completion.
            apb_psel_o   <= 1'b0;
            apb_penable_o<= 1'b0;
          end
          // Timeout mechanism: if ready is not asserted within 15 cycles, abort.
          else if (timeout_counter == 4'd15) begin
            state        <= IDLE;
            apb_psel_o   <= 1'b0;
            apb_penable_o<= 1'b0;
          end
          else begin
            state        <= ACCESS;
            timeout_counter <= timeout_counter + 1;
          end
        end

        default: begin
          state <= IDLE;
          apb_psel_o   <= 1'b0;
          apb_penable_o<= 1'b0;
          apb_pwrite_o <= 1'b0;
          apb_paddr_o  <= 32'd0;
          apb_pwdata_o <= 32'd0;
        end
      endcase
    end
  end

endmodule