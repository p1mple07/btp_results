module sdram_controller (
    input  logic         clk,
    input  logic         reset,
    input  logic [23:0]  addr,
    input  logic [15:0]  data_in,
    output logic [15:0]  data_out,
    input  logic         read,
    input  logic         write,
    input  logic [15:0]  sdram_dq,
    output logic [15:0]  dq_out,
    output logic         sdram_clk,
    output logic         sdram_cke,
    output logic         sdram_cs,
    output logic         sdram_ras,
    output logic         sdram_cas,
    output logic         sdram_we,
    output logic [22:0]  sdram_addr,
    output logic [1:0]   sdram_ba
);

    // Define state encoding
    typedef enum logic [2:0] {
        INIT     = 3'd0,
        IDLE     = 3'd1,
        ACTIVATE = 3'd2,
        READ     = 3'd3,
        WRITE    = 3'd4,
        REFRESH  = 3'd5
    } state_t;

    state_t state, next_state;
    logic [3:0] init_counter; // 4-bit counter for 10-cycle init sequence
    logic [9:0] idle_counter; // 10-bit counter for 1024-cycle auto-refresh

    //-------------------------------------------------------------------------
    // Sequential logic: state machine and counter updates
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= INIT;
            init_counter <= 0;
            idle_counter <= 0;
        end else begin
            case (state)
                INIT: begin
                    if (init_counter < 10)
                        init_counter <= init_counter + 1;
                    else begin
                        state      <= IDLE;
                        idle_counter <= 0;
                    end
                end
                IDLE: begin
                    if (read || write) begin
                        // A read or write request is received; move to ACTIVATE
                        state      <= ACTIVATE;
                        idle_counter <= 0;
                    end else if (idle_counter >= 1023) begin
                        // Auto-refresh trigger after 1024 cycles of inactivity
                        state      <= REFRESH;
                        idle_counter <= 0;
                    end else begin
                        idle_counter <= idle_counter + 1;
                    end
                end
                ACTIVATE: begin
                    // Next state is determined by the input command
                    if (read)
                        state <= READ;
                    else if (write)
                        state <= WRITE;
                    else
                        state <= IDLE;
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

    //-------------------------------------------------------------------------
    // Combinational logic: drive SDRAM control signals based on state
    //-------------------------------------------------------------------------
    always_comb begin
        // Default assignments for inactive state
        sdram_cs  = 1'b1;
        sdram_ras = 1'b1;
        sdram_cas = 1'b1;
        sdram_we  = 1'b1;
        sdram_cke = 1'b1;
        // Drive address signals: assume lower 22 bits for row/column and upper 2 bits for bank
        sdram_addr = addr[22:0];
        sdram_ba   = addr[24:23];
        data_out   = 16'b0;
        dq_out     = 16'b0;
        sdram_clk  = clk;  // SDRAM clock driven by system clock

        case (state)
            INIT: begin
                // During initialization, SDRAM clock enable is held low.
                sdram_cke = 1'b0;
                // Address signals can be driven by the provided address.
                sdram_addr = addr[22:0];
                sdram_ba   = addr[24:23];
            end
            IDLE: begin
                // Idle state: no active command; address signals are continuously driven.
                sdram_addr = addr[22:0];
                sdram_ba   = addr[24:23];
            end
            ACTIVATE: begin
                // Activation command: drive address signals for row activation.
                sdram_addr = addr[22:0];
                sdram_ba   = addr[24:23];
            end
            READ: begin
                // Read command: assert CKE high, RAS low, CAS high, and WE low.
                sdram_ras = 1'b0;
                sdram_we  = 1'b0;
                // Capture data from SDRAM data bus into data_out.
                data_out  = sdram_dq;
            end
            WRITE: begin
                // Write command: assert CKE high, RAS low, CAS high, and WE high.
                sdram_ras = 1'b0;
                sdram_we  = 1'b1;
                // Drive data bus with the write data.
                dq_out    = data_in;
            end
            REFRESH: begin
                // Refresh command: assert CS high, RAS high, CAS high, WE low.
                sdram_ras = 1'b1;
                sdram_cas = 1'b1;
                sdram_we  = 1'b0;
                // For refresh, typically bank 0 and address 0 are used.
                sdram_addr = 23'd0;
                sdram_ba   = 2'd0;
            end
        endcase
    end

endmodule