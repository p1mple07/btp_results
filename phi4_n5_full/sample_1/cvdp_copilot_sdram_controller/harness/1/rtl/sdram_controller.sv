module sdram_controller (
    input  logic               clk,
    input  logic               reset,
    input  logic [23:0]        addr,
    input  logic [15:0]        data_in,
    input  logic               read,
    input  logic               write,
    input  logic [15:0]        sdram_dq,  // SDRAM data output (for write operations)
    output logic [15:0]        data_out,  // Data output from read operations
    output logic               sdram_clk,
    output logic               sdram_cke,
    output logic               sdram_cs,
    output logic               sdram_ras,
    output logic               sdram_cas,
    output logic               sdram_we,
    output logic [23:0]        sdram_addr,
    output logic [1:0]         sdram_ba,
    output logic [15:0]        dq_out     // SDRAM data input (for read operations)
);

  //-------------------------------------------------------------------------
  // State Encoding
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    INIT     = 3'd0,
    IDLE     = 3'd1,
    ACTIVATE = 3'd2,
    READ     = 3'd3,
    WRITE    = 3'd4,
    REFRESH  = 3'd5
  } state_t;

  state_t current_state, next_state;

  // Parameters for timing
  parameter INIT_CYCLES  = 10;
  parameter IDLE_TIMEOUT = 1024;

  // Counters
  logic [3:0]   init_counter;   // 4 bits sufficient for 10 cycles
  logic [10:0]  idle_counter;   // 11 bits sufficient for 1024 cycles

  //-------------------------------------------------------------------------
  // Next State Logic
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = current_state;  // default: hold state

    case (current_state)
      INIT: begin
        if (init_counter == INIT_CYCLES - 1)
          next_state = IDLE;
        else
          next_state = INIT;
      end

      IDLE: begin
        if (read || write) begin
          next_state = ACTIVATE;
        end
        else if (idle_counter == IDLE_TIMEOUT - 1) begin
          next_state = REFRESH;
        end
        else begin
          next_state = IDLE;
        end
      end

      ACTIVATE: begin
        // One-cycle delay; then decide based on input signals.
        if (read)
          next_state = READ;
        else if (write)
          next_state = WRITE;
        else
          next_state = IDLE;
      end

      READ:  next_state = IDLE;
      WRITE: next_state = IDLE;
      REFRESH: next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // State Register and Counter Updates
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= INIT;
      init_counter  <= 0;
      idle_counter  <= 0;
    end
    else begin
      current_state <= next_state;

      case (current_state)
        INIT: begin
          if (init_counter == INIT_CYCLES - 1)
            init_counter <= 0;
          else
            init_counter <= init_counter + 1;
          idle_counter <= 0;
        end

        IDLE: begin
          if (read || write)
            idle_counter <= 0;
          else if (idle_counter < IDLE_TIMEOUT - 1)
            idle_counter <= idle_counter + 1;
          else
            idle_counter <= 0;
        end

        ACTIVATE: begin
          idle_counter <= 0;
        end

        READ: begin
          idle_counter <= 0;
        end

        WRITE: begin
          idle_counter <= 0;
        end

        REFRESH: begin
          idle_counter <= 0;
        end

        default: begin
          init_counter  <= 0;
          idle_counter  <= 0;
        end
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Output Logic Based on Current State
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments
    data_out    = 16'b0;
    sdram_clk   = clk;
    sdram_cke   = 1'b1;
    sdram_cs    = 1'b0;
    sdram_ras   = 1'b0;
    sdram_cas   = 1'b0;
    sdram_we    = 1'b1;  // Active low
    sdram_addr  = 24'b0;
    sdram_ba    = 2'b0;
    sdram_dq    = 16'b0;
    dq_out      = 16'b0;

    case (current_state)
      INIT: begin
        // Initialization sequence: drive safe state for 10 cycles.
        sdram_cs    = 1'b1;
        sdram_ras   = 1'b1;
        sdram_cas   = 1'b1;
        sdram_we    = 1'b1;
        sdram_addr  = 24'b0;
        sdram_ba    = 2'b0;
        sdram_dq    = 16'b0;
      end

      IDLE: begin
        // Idle state: hold SDRAM in low-power state.
        sdram_cs    = 1'b0;
        sdram_ras   = 1'b0;
        sdram_cas   = 1'b0;
        sdram_we    = 1'b1;
        sdram_addr  = 24'b0;
        sdram_ba    = 2'b0;
        sdram_dq    = 16'b0;
      end

      ACTIVATE: begin
        // Activation command: assert CS, RAS, and CAS.
        sdram_cs    = 1'b1;
        sdram_ras   = 1'b1;
        sdram_cas   = 1'b1;
        sdram_we    = 1'b1;
        sdram_addr  = addr;
        sdram_ba    = 2'b0;
        sdram_dq    = 16'b0;
      end

      READ: begin
        // Read command: assert CS, CKE, with RAS low, CAS high, WE low.
        sdram_cs    = 1'b1;
        sdram_cke   = 1'b1;
        sdram_ras   = 1'b0;
        sdram_cas   = 1'b1;
        sdram_we    = 1'b0;
        sdram_addr  = addr;
        sdram_ba    = 2'b0;
        // Capture data from dq_out into data_out.
        data_out    = dq_out;
      end

      WRITE: begin
        // Write command: assert CS, CKE, with RAS low, CAS high, WE high.
        sdram_cs    = 1'b1;
        sdram_cke   = 1'b1;
        sdram_ras   = 1'b0;
        sdram_cas   = 1'b1;
        sdram_we    = 1'b1;
        sdram_addr  = addr;
        sdram_ba    = 2'b0;
        sdram_dq    = data_in;
      end

      REFRESH: begin
        // Auto-refresh command: assert CS, RAS, CAS; WE low; CKE high.
        sdram_cs    = 1'b1;
        sdram_cke   = 1'b1;
        sdram_ras   = 1'b1;
        sdram_cas   = 1'b1;
        sdram_we    = 1'b0;
        sdram_addr  = 24'b0;
        sdram_ba    = 2'b0;
        sdram_dq    = 16'b0;
      end

      default: begin
        // Default safe state.
        sdram_cs    = 1'b0;
        sdram_ras   = 1'b0;
        sdram_cas   = 1'b0;
        sdram_we    = 1'b1;
        sdram_addr  = 24'b0;
        sdram_ba    = 2'b0;
        sdram_dq    = 16'b0;
      end
    endcase
  end

endmodule