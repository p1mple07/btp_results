module enhanced_fsm_signal_processor(
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire         i_enable,
    input  wire         i_clear,
    input  wire         i_ack,
    input  wire         i_fault,
    input  wire [4:0]   i_vector_1,
    input  wire [4:0]   i_vector_2,
    input  wire [4:0]   i_vector_3,
    input  wire [4:0]   i_vector_4,
    input  wire [4:0]   i_vector_5,
    input  wire [4:0]   i_vector_6,
    output reg  [7:0]   o_vector_1,
    output reg  [7:0]   o_vector_2,
    output reg  [7:0]   o_vector_3,
    output reg  [7:0]   o_vector_4,
    output reg          o_ready,
    output reg          o_error,
    output reg  [1:0]   o_fsm_status
);

    // FSM state encoding
    localparam IDLE    = 2'b00;
    localparam PROCESS = 2'b01;
    localparam READY   = 2'b10;
    localparam FAULT   = 2'b11;

    reg [1:0] state;
    reg [31:0] data_bus; // holds the 32-bit processed bus

    // State and data_bus update
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state      <= IDLE;
            data_bus   <= 32'd0;
        end else begin
            // Fault condition takes precedence
            if (i_fault)
                state <= FAULT;
            else begin
                case (state)
                    IDLE: begin
                        if (i_enable)
                            state <= PROCESS;
                        else
                            state <= IDLE;
                    end
                    PROCESS: begin
                        state <= READY;
                    end
                    READY: begin
                        if (i_ack)
                            state <= IDLE;
                        else
                            state <= READY;
                    end
                    FAULT: begin
                        if (i_clear && !i_fault)
                            state <= IDLE;
                        else
                            state <= FAULT;
                    end
                    default: state <= IDLE;
                endcase
            end

            // In PROCESS state, compute the 32-bit bus:
            // Concatenate six 5-bit vectors and append 2'b11 at the LSB.
            if (state == PROCESS)
                data_bus <= { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 };
            else
                data_bus <= data_bus; // hold previous value
        end
    end

    // Output logic (all outputs are synchronous to i_clk)
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_vector_1  <= 8'd0;
            o_vector_2  <= 8'd0;
            o_vector_3  <= 8'd0;
            o_vector_4  <= 8'd0;
            o_ready     <= 1'b0;
            o_error     <= 1'b0;
            o_fsm_status<= 2'b00;
        end else begin
            // Fault condition takes precedence for outputs as well
            if (i_fault) begin
                o_vector_1  <= 8'd0;
                o_vector_2  <= 8'd0;
                o_vector_3  <= 8'd0;
                o_vector_4  <= 8'd0;
                o_ready     <= 1'b0;
                o_error     <= 1'b1;
                o_fsm_status<= 2'b11;
            end else begin
                case (state)
                    IDLE: begin
                        o_vector_1  <= 8'd0;
                        o_vector_2  <= 8'd0;
                        o_vector_3  <= 8'd0;
                        o_vector_4  <= 8'd0;
                        o_ready     <= 1'b0;
                        o_error     <= 1'b0;
                        o_fsm_status<= 2'b00;
                    end
                    PROCESS: begin
                        // Split the 32-bit bus into four 8-bit outputs.
                        o_vector_1  <= data_bus[31:24];
                        o_vector_2  <= data_bus[23:16];
                        o_vector_3  <= data_bus[15:8];
                        o_vector_4  <= data_bus[7:0];
                        o_ready     <= 1'b0;
                        o_error     <= 1'b0;
                        o_fsm_status<= 2'b01;
                    end
                    READY: begin
                        // Hold the computed outputs and assert o_ready.
                        o_vector_1  <= data_bus[31:24];
                        o_vector_2  <= data_bus[23:16];
                        o_vector_3  <= data_bus[15:8];
                        o_vector_4  <= data_bus[7:0];
                        o_ready     <= 1'b1;
                        o_error     <= 1'b0;
                        o_fsm_status<= 2'b10;
                    end
                    FAULT: begin
                        o_vector_1  <= 8'd0;
                        o_vector_2  <= 8'd0;
                        o_vector_3  <= 8'd0;
                        o_vector_4  <= 8'd0;
                        o_ready     <= 1'b0;
                        o_error     <= 1'b1;
                        o_fsm_status<= 2'b11;
                    end
                    default: begin
                        o_vector_1  <= 8'd0;
                        o_vector_2  <= 8'd0;
                        o_vector_3  <= 8'd0;
                        o_vector_4  <= 8'd0;
                        o_ready     <= 1'b0;
                        o_error     <= 1'b0;
                        o_fsm_status<= 2'b00;
                    end
                endcase
            end
        end
    end

endmodule