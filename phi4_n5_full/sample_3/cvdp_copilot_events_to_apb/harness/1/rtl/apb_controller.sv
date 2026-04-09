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
  output reg  logic     apb_psel_o,
  output reg  logic     apb_penable_o,
  output reg  logic     apb_pwrite_o,
  output reg  logic [31:0] apb_paddr_o,
  output reg  logic [31:0] apb_pwdata_o
);

  // State encoding: IDLE, SETUP, ACCESS
  typedef enum logic [1:0] {
    IDLE  = 2'd0,
    SETUP = 2'd1,
    ACCESS = 2'd2
  } state_t;

  state_t state, next_state;

  // Internal registers to hold the captured address and data for the transaction
  reg [31:0] addr_reg;
  reg [31:0] data_reg;

  // 4-bit timeout counter for the ACCESS phase
  reg [3:0] timeout_counter;

  // Flag to indicate an event was captured in IDLE
  reg event_pending;

  // Synchronous state register update and signal assignment
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state            <= IDLE;
      timeout_counter  <= 4'd0;
      apb_psel_o       <= 1'b0;
      apb_penable_o    <= 1'b0;
      apb_pwrite_o     <= 1'b0;
      apb_paddr_o      <= 32'd0;
      apb_pwdata_o     <= 32'd0;
      event_pending    <= 1'b0;
      addr_reg         <= 32'd0;
      data_reg         <= 32'd0;
    end
    else begin
      case (state)
        IDLE: begin
          // Capture the event: only the highest priority event is processed.
          if (select_a_i) begin
            addr_reg    <= addr_a_i;
            data_reg    <= data_a_i;
            event_pending <= 1'b1;
          end
          else if (select_b_i) begin
            addr_reg    <= addr_b_i;
            data_reg    <= data_b_i;
            event_pending <= 1'b1;
          end
          else if (select_c_i) begin
            addr_reg    <= addr_c_i;
            data_reg    <= data_c_i;
            event_pending <= 1'b1;
          end
          else begin
            event_pending <= 1'b0;
          end

          // Deassert all APB signals in IDLE
          apb_psel_o    <= 1'b0;
          apb_penable_o <= 1'b0;
          apb_pwrite_o  <= 1'b0;
          apb_paddr_o   <= 32'd0;
          apb_pwdata_o  <= 32'd0;

          // Transition to SETUP if an event was captured; otherwise remain in IDLE.
          if (event_pending)
            state <= SETUP;
          else
            state <= IDLE;
        end

        SETUP: begin
          // Assert APB select and write signals, load address and data.
          apb_psel_o    <= 1'b1;
          apb_pwrite_o  <= 1'b1;
          apb_paddr_o   <= addr_reg;
          apb_pwdata_o  <= data_reg;
          // Keep apb_penable_o deasserted during SETUP.
          apb_penable_o <= 1'b0;
          // Reset timeout counter for the new transaction.
          timeout_counter <= 4'd0;
          // Move to ACCESS state in the next cycle.
          state <= ACCESS;
        end

        ACCESS: begin
          // Assert apb_penable_o to indicate the transaction is in progress.
          apb_psel_o    <= 1'b1;
          apb_pwrite_o  <= 1'b1;
          apb_paddr_o   <= addr_reg;
          apb_pwdata_o  <= data_reg;
          apb_penable_o <= 1'b1;

          // Check if the peripheral is ready.
          if (apb_pready_i) begin
            // Transaction complete; return to IDLE next cycle.
            state <= IDLE;
          end
          else begin
            // Increment the timeout counter each cycle.
            if (timeout_counter == 4'd15) begin
              // Timeout reached: abort the transaction and return to IDLE.
              state <= IDLE;
            end
            else begin
              timeout_counter <= timeout_counter + 1;
              state <= ACCESS;
            end
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule