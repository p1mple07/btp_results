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

   // State encoding
   typedef enum logic [2:0] {
       INIT     = 3'd0,
       IDLE     = 3'd1,
       ACTIVATE = 3'd2,
       READ     = 3'd3,
       WRITE    = 3'd4,
       REFRESH  = 3'd5
   } state_t;
   
   state_t state, next_state;
   
   // Counters
   logic [9:0]  init_counter;  // 10-cycle initialization sequence
   logic [10:0] idle_counter;  // 1024-cycle idle timeout for auto-refresh

   // Data output register for READ state
   logic [15:0] data_out_reg;

   // FSM state register and counter updates
   always_ff @(posedge clk or posedge reset) begin
       if (reset) begin
           state         <= INIT;
           init_counter  <= 10'd0;
           idle_counter  <= 11'd0;
           data_out_reg  <= 16'd0;
       end else begin
           state <= next_state;
           if (state == INIT) begin
               init_counter <= init_counter + 1;
           end else if (state == IDLE) begin
               if (read || write)
                   idle_counter <= 11'd0;
               else if (idle_counter == 11'd1023)
                   idle_counter <= 11'd0;  // trigger auto-refresh
               else
                   idle_counter <= idle_counter + 1;
           end
       end
   end

   // Next state logic
   always_comb begin
       unique case (state)
           INIT: begin
               if (init_counter == 10'd9)
                   next_state = IDLE;
               else
                   next_state = INIT;
           end
           IDLE: begin
               if (read || write)
                   next_state = ACTIVATE;
               else if (idle_counter == 11'd1023)
                   next_state = REFRESH;
               else
                   next_state = IDLE;
           end
           ACTIVATE: begin
               if (read)
                   next_state = READ;
               else if (write)
                   next_state = WRITE;
               else
                   next_state = ACTIVATE;
           end
           READ:    next_state = IDLE;
           WRITE:   next_state = IDLE;
           REFRESH: next_state = IDLE;
           default: next_state = IDLE;
       endcase
   end

   // Capture data on READ state
   always_ff @(posedge clk or posedge reset) begin
       if (reset)
           data_out_reg <= 16'd0;
       else if (state == READ)
           data_out_reg <= sdram_dq;
   end

   // Output logic for SDRAM control signals and data bus
   always_comb begin
       // Default assignments common to most states
       sdram_clk = clk;
       sdram_cke = 1'b1;
       sdram_cs  = 1'b1;
       
       case (state)
           INIT: begin
               sdram_ras = 1'b1;
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = 24'd0;
               sdram_ba  = 2'd0;
               dq_out    = 16'd0;
           end
           IDLE: begin
               sdram_ras = 1'b1;
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = addr[21:0];
               sdram_ba  = addr[23:22];
               dq_out    = 16'bz;  // High impedance during idle
           end
           ACTIVATE: begin
               sdram_ras = 1'b1;
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = addr[21:0];
               sdram_ba  = addr[23:22];
               dq_out    = 16'd0;
           end
           READ: begin
               sdram_ras = 1'b0;    // Row not active for read
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = addr[21:0];
               sdram_ba  = addr[23:22];
               dq_out    = 16'bz;  // High impedance to read data
           end
           WRITE: begin
               sdram_ras = 1'b0;
               sdram_cas = 1'b1;
               sdram_we  = 1'b1;
               sdram_addr = addr[21:0];
               sdram_ba  = addr[23:22];
               dq_out    = data_in;
           end
           REFRESH: begin
               sdram_ras = 1'b1;
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = 24'd0;
               sdram_ba  = 2'd0;
               dq_out    = 16'd0;
           end
           default: begin
               sdram_ras = 1'b1;
               sdram_cas = 1'b1;
               sdram_we  = 1'b0;
               sdram_addr = addr[21:0];
               sdram_ba  = addr[23:22];
               dq_out    = 16'bz;
           end
       endcase
   end

   // Drive data_out based on current state
   always_comb begin
       if (state == READ)
           data_out = data_out_reg;
       else
           data_out = 16'd0;
   end

endmodule