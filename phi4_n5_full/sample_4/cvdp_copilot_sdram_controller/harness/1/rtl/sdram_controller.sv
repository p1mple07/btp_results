module sdram_controller (
    input  logic         clk,
    input  logic         reset,
    input  logic [23:0]  addr,
    input  logic [15:0]  data_in,
    output logic [15:0]  data_out,
    input  logic         read,
    input  logic         write,
    output logic         sdram_clk,
    output logic         sdram_cke,
    output logic         sdram_cs,
    output logic         sdram_ras,
    output logic         sdram_cas,
    output logic         sdram_we,
    output logic [23:0]  sdram_addr,
    output logic [1:0]   sdram_ba,
    input  logic [15:0]  sdram_dq,
    output logic [15:0]  dq_out
);

   // FSM state encoding
   typedef enum logic [2:0] {
      INIT     = 3'd0,
      IDLE     = 3'd1,
      ACTIVATE = 3'd2,
      READ     = 3'd3,
      WRITE    = 3'd4,
      REFRESH  = 3'd5
   } state_t;

   state_t state, next_state;

   // Counters for initialization and idle auto-refresh
   logic [3:0] init_counter;
   logic [9:0] idle_counter;

   // State transition logic
   always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
         state      <= INIT;
         init_counter <= 4'd0;
         idle_counter <= 10'd0;
      end
      else begin
         case (state)
           INIT: begin
              init_counter <= init_counter + 1;
              if (init_counter >= 10) begin
                 state      <= IDLE;
                 idle_counter <= 10'd0;
              end
           end
           IDLE: begin
              if (read || write) begin
                 state      <= ACTIVATE;
                 idle_counter <= 10'd0;
              end
              else if (idle_counter >= 1024) begin
                 state      <= REFRESH;
                 idle_counter <= 10'd0;
              end
              else begin
                 idle_counter <= idle_counter + 1;
              end
           end
           ACTIVATE: begin
              // After activation, choose READ or WRITE based on control signals
              state <= (read) ? READ : WRITE;
           end
           READ: begin
              state <= IDLE;
           end
           WRITE: begin
              state <= IDLE;
           end
           REFRESH: begin
              state <= IDLE;
           end
           default: state <= IDLE;
         endcase
      end
   end

   // Output logic based on current state
   always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
         sdram_clk    <= 1'b0;
         sdram_cke    <= 1'b0;
         sdram_cs     <= 1'b0;
         sdram_ras    <= 1'b0;
         sdram_cas    <= 1'b0;
         sdram_we     <= 1'b0;
         sdram_addr   <= 24'd0;
         sdram_ba     <= 2'd0;
         dq_out       <= 16'd0;
         data_out     <= 16'd0;
      end
      else begin
         case (state)
           // Initialization: simple delay sequence
           INIT: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b0;
              sdram_cs     <= 1'b0;
              sdram_ras    <= 1'b0;
              sdram_cas    <= 1'b0;
              sdram_we     <= 1'b0;
              sdram_addr   <= 24'd0;
              sdram_ba     <= 2'd0;
              dq_out       <= 16'd0;
              data_out     <= 16'd0;
           end
           // Idle state: no active command
           IDLE: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b0;
              sdram_cs     <= 1'b0;
              sdram_ras    <= 1'b0;
              sdram_cas    <= 1'b0;
              sdram_we     <= 1'b0;
              sdram_addr   <= 24'd0;
              sdram_ba     <= 2'd0;
              dq_out       <= 16'd0;
              data_out     <= 16'd0;
           end
           // ACTIVATE: Issue Activate command (CS, RAS, CAS asserted)
           ACTIVATE: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b1;
              sdram_cs     <= 1'b1;
              sdram_ras    <= 1'b1;
              sdram_cas    <= 1'b1;
              sdram_we     <= 1'b0;
              sdram_addr   <= 24'd0;
              sdram_ba     <= 2'd0;
              dq_out       <= 16'd0;
              data_out     <= 16'd0;
           end
           // READ: Issue Read command and capture data from SDRAM
           READ: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b1;
              sdram_cs     <= 1'b1;
              sdram_ras    <= 1'b0;
              sdram_cas    <= 1'b1;
              sdram_we     <= 1'b0;
              sdram_addr   <= addr;
              sdram_ba     <= 2'd0;  // Assuming bank 0
              data_out     <= sdram_dq;
              dq_out       <= 16'd0; // Not driving during read
           end
           // WRITE: Issue Write command and drive data bus with data_in
           WRITE: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b1;
              sdram_cs     <= 1'b1;
              sdram_ras    <= 1'b0;
              sdram_cas    <= 1'b1;
              sdram_we     <= 1'b1;
              sdram_addr   <= addr;
              sdram_ba     <= 2'd0;
              dq_out       <= data_in;
              data_out     <= 16'd0; // Not used in write mode
           end
           // REFRESH: Issue Auto-Refresh command
           REFRESH: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b1;
              sdram_cs     <= 1'b1;
              sdram_ras    <= 1'b1;
              sdram_cas    <= 1'b1;
              sdram_we     <= 1'b0;
              sdram_addr   <= 24'd0;
              sdram_ba     <= 2'd0;
              dq_out       <= 16'd0;
              data_out     <= 16'd0;
           end
           default: begin
              sdram_clk    <= clk;
              sdram_cke    <= 1'b0;
              sdram_cs     <= 1'b0;
              sdram_ras    <= 1'b0;
              sdram_cas    <= 1'b0;
              sdram_we     <= 1'b0;
              sdram_addr   <= 24'd0;
              sdram_ba     <= 2'd0;
              dq_out       <= 16'd0;
              data_out     <= 16'd0;
           end
         endcase
      end
   end

endmodule