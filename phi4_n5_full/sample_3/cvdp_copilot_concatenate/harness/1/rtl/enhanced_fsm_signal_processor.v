module enhanced_fsm_signal_processor (
    input         i_clk,
    input         i_rst_n,
    input         i_enable,
    input         i_clear,
    input         i_ack,
    input         i_fault,
    input  [4:0]  i_vector_1,
    input  [4:0]  i_vector_2,
    input  [4:0]  i_vector_3,
    input  [4:0]  i_vector_4,
    input  [4:0]  i_vector_5,
    input  [4:0]  i_vector_6,
    output reg    o_ready,
    output reg    o_error,
    output reg [1:0] o_fsm_status,
    output reg [7:0] o_vector_1,
    output reg [7:0] o_vector_2,
    output reg [7:0] o_vector_3,
    output reg [7:0] o_vector_4
);

    // Define FSM states: IDLE=00, PROCESS=01, READY=10, FAULT=11
    localparam [1:0] IDLE   = 2'b00,
                     PROCESS = 2'b01,
                     READY   = 2'b10,
                     FAULT   = 2'b11;

    reg [1:0] state;

    // Synchronous state and output update
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state         <= IDLE;
            o_ready       <= 1'b0;
            o_error       <= 1'b0;
            o_vector_1    <= 8'd0;
            o_vector_2    <= 8'd0;
            o_vector_3    <= 8'd0;
            o_vector_4    <= 8'd0;
            o_fsm_status  <= IDLE;
        end
        else begin
            // Fault takes precedence over all other operations
            if (i_fault) begin
                state         <= FAULT;
                o_error       <= 1'b1;
                o_ready       <= 1'b0;
                o_vector_1    <= 8'd0;
                o_vector_2    <= 8'd0;
                o_vector_3    <= 8'd0;
                o_vector_4    <= 8'd0;
                o_fsm_status  <= FAULT;
            end
            else begin
                case (state)
                    IDLE: begin
                        if (i_enable)
                            state <= PROCESS;
                        else
                            state <= IDLE;
                    end

                    PROCESS: begin
                        // Concatenate six 5-bit vectors and append 2'b11 to form a 32-bit bus.
                        // The bus is defined as: { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 }
                        // Then split the bus into four 8-bit outputs:
                        //   o_vector_1 = bus[31:24]
                        //   o_vector_2 = bus[23:16]
                        //   o_vector_3 = bus[15:8]
                        //   o_vector_4 = bus[7:0]
                        o_vector_1 <= { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 }[31:24];
                        o_vector_2 <= { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 }[23:16];
                        o_vector_3 <= { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 }[15:8];
                        o_vector_4 <= { i_vector_1, i_vector_2, i_vector_3, i_vector_4, i_vector_5, i_vector_6, 2'b11 }[7:0];
                        state      <= READY;
                        o_ready    <= 1'b0;
                        o_error    <= 1'b0;
                    end

                    READY: begin
                        if (i_ack)
                            state <= IDLE;
                        else
                            state <= READY;
                        // Assert o_ready in READY state to indicate valid outputs
                        o_ready <= (state == READY) ? 1'b1 : 1'b0;
                        o_error <= 1'b0;
                    end

                    FAULT: begin
                        // In FAULT state, if i_clear is asserted and the fault is cleared (i_fault deasserted),
                        // transition back to IDLE.
                        if (i_clear && !i_fault)
                            state <= IDLE;
                        else
                            state <= FAULT;
                        o_error <= (state == FAULT) ? 1'b1 : 1'b0;
                        o_ready <= 1'b0;
                    end
                endcase
                o_fsm_status <= state;
            end
        end
    end

endmodule