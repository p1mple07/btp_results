module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 32
) (
    input  logic                                 rst,

    // Ping Pong FIFO Read Interface
    input  logic                                 i_block_fifo_rdy,
    output logic                                 o_block_fifo_act,
    input  logic [23:0]                          i_block_fifo_size,
    input  logic [(DATA_WIDTH + 1) - 1:0]        i_block_fifo_data,
    output logic                                 o_block_fifo_stb,
    input  logic [3:0]                           i_axi_user,

    // AXI Stream Output
    input  logic                                 i_axi_clk,
    output logic [3:0]                           o_axi_user,
    input  logic                                 i_axi_ready,
    output logic [DATA_WIDTH - 1:0]              o_axi_data,
    output logic                                 o_axi_last,
    output logic                                 o_axi_valid
);

    // Internal Registers
    logic [23:0] block_size_reg;
    logic [23:0] data_count;
    logic        fifo_active;
    logic        data_valid;
    logic        i_flush, i_pause;
    logic [1:0] next_state;

    typedef enum logic [1:0] {
        IDLE,
        READ_FIFO,
        SEND_AXI,
        PAUSE
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge i_axi_clk or posedge rst) begin
        if (rst) begin
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_user         <= 4'd0;
        end else begin
            current_state      <= next_state;

            // Flush: reset everything and stop everything
            if (i_flush) begin
                current_state   <= IDLE;
                block_size_reg   <= 24'd0;
                data_count       <= 24'd0;
                fifo_active      <= 1'b0;
                o_block_fifo_act <= 1'b0;
                o_block_fifo_stb <= 1'b0;
                o_axi_valid      <= 1'b0;
                o_axi_last       <= 1'b0;
                o_axi_user       <= 4'd0;
            end

            // Pause: suspend AXI data but keep state
            if (i_pause) begin
                current_state   <= PAUSE;
                next_state      <= IDLE;  // Resume from idle after pause
            end

            // Normal states
            case (current_state)
                IDLE: begin
                    if (i_block_fifo_rdy) begin
                        o_block_fifo_act <= 1'b1;
                        block_size_reg    <= i_block_fifo_size;
                        fifo_active       <= 1'b1;
                        data_count        <= 24'd0;
                        next_state        <= READ_FIFO;
                    end else begin
                        next_state        <= IDLE;
                    end
                end

                READ_FIFO: begin
                    if (fifo_active && i_block_fifo_rdy) begin
                        o_block_fifo_stb <= 1'b1;
                        data_count       <= data_count + 24'd1;
                        next_state       <= SEND_AXI;
                    end else begin
                        next_state        <= READ_FIFO;
                    end
                end

                SEND_AXI: begin
                    if (fifo_active && i_axi_ready) begin
                        o_axi_valid  <= 1'b1;
                        o_axi_data   <= i_block_fifo_data[DATA_WIDTH-1:0];
                        o_axi_user   <= i_axi_user;

                        if (data_count + 24'd1 >= block_size_reg) begin
                            o_axi_last <= 1'b1;
                            fifo_active <= 1'b0;
                            next_state  <= IDLE;
                        end else begin
                            next_state  <= READ_FIFO;
                        end
                    end else begin
                        next_state  <= SEND_AXI;
                    end
                end

                PAUSE: begin
                    // No action – just stay in PAUSE
                    next_state  <= IDLE;
                end

                default: next_state <= IDLE;
            endcase
        end
    end

endmodule
