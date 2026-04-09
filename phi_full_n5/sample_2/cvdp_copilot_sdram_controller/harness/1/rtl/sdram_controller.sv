module sdram_controller (
    input clk,
    input reset,
    input [23:0] addr,
    input [15:0] data_in,
    output reg [15:0] data_out,
    output reg sdram_clk,
    output reg sdram_cke,
    output reg sdram_cs,
    output reg sdram_ras,
    output reg sdram_cas,
    output reg sdram_we,
    output reg sdram_addr,
    output reg sdram_ba,
    output reg [15:0] dq_out
);

    // State declaration
    typedef enum {INIT, IDLE, ACTIVATE, READ, WRITE, REFRESH} state_t;
    state_t state = INIT;

    // Timing constants
    localparam INIT_DURATION = 10;
    localparam IDLE_TIMEOUT = 1024;

    // FSM variables
    reg [1:0] fsm_reg;
    reg [IDLE_TIMEOUT - 1:0] fsm_counter;

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fsm_reg <= INIT;
            fsm_counter <= 0;
        end else begin
            if (fsm_counter >= IDLE_TIMEOUT) begin
                fsm_counter <= 0;
                sdram_cs <= 1; // Activate SDRAM
                sdram_ras <= 1;
                sdram_cas <= 1;
                sdram_we <= 0;
                state <= REFRESH;
            end else if (state == IDLE) begin
                if (data_in != 0) begin
                    state <= ACTIVATE;
                    fsm_counter <= INIT_DURATION;
                end
            end else if (state == ACTIVATE) begin
                if (state_t_eq(state, READ) || state_t_eq(state, WRITE)) begin
                    state <= state_t_next(state);
                    fsm_counter <= 0;
                end else begin
                    fsm_counter <= fsm_counter + 1;
                end
            end
        end
    end

    // State transition logic
    function state_t state_t_next(state_t current_state);
        case (current_state)
            INIT: state_t_next = READ;
            READ: state_t_next = WRITE;
            WRITE: state_t_next = READ;
            REFRESH: state_t_next = IDLE;
            IDLE: state_t_next = READ; // Default to READ on IDLE
        endcase
    endfunction

    // Output logic
    always @(state, addr) begin
        case (state)
            INIT:
                sdram_clk <= 1;
                sdram_cke <= 1;
                sdram_cs <= 1;
                sdram_ras <= 0;
                sdram_cas <= 0;
                sdram_we <= 0;
                sdram_addr <= 0;
                sdram_ba <= 0;
                dq_out <= 0;
            READ:
                sdram_clk <= 1;
                sdram_cke <= 1;
                sdram_cs <= 1;
                sdram_ras <= 0;
                sdram_cas <= addr[15:0];
                sdram_we <= 0;
                sdram_addr <= addr[23:16];
                sdram_ba <= 0;
                dq_out <= data_in;
            WRITE:
                sdram_clk <= 1;
                sdram_cke <= 1;
                sdram_cs <= 1;
                sdram_ras <= 0;
                sdram_cas <= addr[15:0];
                sdram_we <= 1;
                sdram_addr <= addr[23:16];
                sdram_ba <= 0;
                dq_out <= data_in;
            REFRESH:
                sdram_clk <= 1;
                sdram_cke <= 1;
                sdram_cs <= 1;
                sdram_ras <= 0;
                sdram_cas <= 0;
                sdram_we <= 0;
                sdram_addr <= 0;
                sdram_ba <= 0;
                dq_out <= 0;
            IDLE:
                sdram_clk <= 1;
                sdram_cke <= 1;
                sdram_cs <= 1;
                sdram_ras <= 0;
                sdram_cas <= 0;
                sdram_we <= 0;
                sdram_addr <= 0;
                sdram_ba <= 0;
                dq_out <= 0;
        endcase
    end

endmodule
