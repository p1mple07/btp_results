module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 32
)(
    input  logic                                 rst,
    
    // Control signals
    input  logic                                 i_flush,
    input  logic                                 i_pause,
    
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

    typedef enum logic [1:0] {
        IDLE      = 2'b00,
        READ_FIFO = 2'b01,
        SEND_AXI  = 2'b10
    } state_t;

    state_t current_state, next_state;

    logic [23:0] block_size_reg;
    logic [23:0] data_count;
    logic        fifo_active;

    logic [DATA_WIDTH-1:0] fifo_data_reg;
    logic                  fifo_data_valid;
    logic                  data_pending;

    function automatic string state_to_str(state_t s);
        case (s)
            IDLE:      state_to_str = "IDLE";
            READ_FIFO: state_to_str = "READ_FIFO";
            SEND_AXI:  state_to_str = "SEND_AXI";
            default:   state_to_str = "UNKNOWN";
        endcase
    endfunction

    always_ff @(posedge i_axi_clk or posedge rst) begin
        if (rst) begin
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            fifo_data_valid    <= 1'b0;
            fifo_data_reg      <= {DATA_WIDTH{1'b0}};
            data_pending       <= 1'b0;

            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_last         <= 1'b0;
            o_axi_user         <= 4'd0;

        end else begin
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;

            if (i_flush) begin
                current_state   <= IDLE;
                fifo_active     <= 1'b0;
                data_count      <= 24'd0;
                block_size_reg  <= 24'd0;
                fifo_data_valid <= 1'b0;
                data_pending    <= 1'b0;
            end else begin
                current_state <= next_state;

                case (current_state)
                    IDLE: begin
                        if (i_block_fifo_rdy) begin
                            o_block_fifo_act <= 1'b1; 
                            block_size_reg   <= i_block_fifo_size;
                            fifo_active      <= 1'b1;
                            data_count       <= 24'd0;
                            fifo_data_valid  <= 1'b0;
                            data_pending     <= 1'b0;
                        end
                    end

                    READ_FIFO: begin
                        if (fifo_active && i_block_fifo_rdy && !fifo_data_valid && !data_pending) begin
                            o_block_fifo_stb <= 1'b1;
                            data_pending <= 1'b1;
                        end else if (data_pending) begin
                            // Next cycle after stb, latch the data
                            fifo_data_reg   <= i_block_fifo_data[DATA_WIDTH-1:0];
                            fifo_data_valid <= 1'b1;
                            data_pending    <= 1'b0;
                        end
                    end

                    SEND_AXI: begin
                        if (fifo_data_valid && !i_pause && i_axi_ready) begin
                            o_axi_valid <= 1'b1;
                            o_axi_data  <= fifo_data_reg;
                            o_axi_user  <= i_axi_user;

                            data_count <= data_count + 24'd1;

                            if ((data_count + 24'd1) >= block_size_reg) begin
                                // Last word
                                o_axi_last <= 1'b1;
                                fifo_active     <= 1'b0;
                                block_size_reg  <= 24'd0;
                            end else begin
                          end
                            fifo_data_valid <= 1'b0;
                        end else begin
                            if (i_pause) begin
                            end
                            if (!i_axi_ready) begin
                            end
                        end
                    end
                endcase
            end
        end
    end

    always_comb begin
        next_state = current_state;
        if (i_flush) begin
            next_state = IDLE; 
        end else begin
            case (current_state)
                IDLE: begin
                    if (fifo_active)
                        next_state = READ_FIFO;
                    else
                        next_state = IDLE;
                end

                READ_FIFO: begin
                    if (fifo_data_valid)
                        next_state = SEND_AXI;
                    else
                        next_state = READ_FIFO;
                end

                SEND_AXI: begin
                    if (!fifo_active)
                        next_state = IDLE;
                    else if (!fifo_data_valid && fifo_active)
                        next_state = READ_FIFO;
                    else
                        next_state = SEND_AXI;
                end

                default: next_state = IDLE;
            endcase
        end
    end

endmodule