module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 32
)(
    input  logic                                 rst,
    input  logic                                 i_flush,    // Flush control input
    input  logic                                 i_pause,    // Pause control input
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
    
    // Enhanced Data Handling Signals
    logic [DATA_WIDTH - 1:0] fifo_data_reg;
    logic        fifo_data_valid;
    logic        data_pending;
    
    typedef enum logic [1:0] {
        IDLE,
        READ_FIFO,
        SEND_AXI
    } state_t;
    
    state_t current_state, next_state;
    
    always_ff @(posedge i_axi_clk or posedge rst) begin
        if (rst) begin
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            fifo_data_valid    <= 1'b0;
            data_pending       <= 1'b0;
            fifo_data_reg      <= {DATA_WIDTH{1'b0}};
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_user         <= 4'd0;
        end 
        else if (i_flush) begin
            // Flush: immediately reset state and clear all registers/outputs.
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            fifo_data_valid    <= 1'b0;
            data_pending       <= 1'b0;
            fifo_data_reg      <= {DATA_WIDTH{1'b0}};
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_user         <= 4'd0;
        end 
        else begin
            // Default assignments for stable outputs
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_user         <= 4'd0;
            
            case (current_state)
                IDLE: begin
                    if (i_block_fifo_rdy) begin
                        o_block_fifo_act <= 1'b1;
                        block_size_reg    <= i_block_fifo_size;
                        fifo_active       <= 1'b1;
                        data_count        <= 24'd0;
                        next_state        <= READ_FIFO;
                    end 
                    else begin
                        next_state <= IDLE;
                    end
                end
                
                READ_FIFO: begin
                    if (fifo_active && i_block_fifo_rdy) begin
                        o_block_fifo_stb <= 1'b1;
                        // Capture the FIFO data into the intermediate register
                        fifo_data_reg    <= i_block_fifo_data[DATA_WIDTH-1:0];
                        fifo_data_valid  <= 1'b1;
                        data_pending     <= 1'b1;
                        data_count       <= data_count + 24'd1;
                        next_state       <= SEND_AXI;
                    end 
                    else begin
                        next_state <= READ_FIFO;
                    end
                end
                
                SEND_AXI: begin
                    // If pause is asserted, hold the state and do not send data
                    if (i_pause) begin
                        next_state <= SEND_AXI;
                    end 
                    else if (fifo_data_valid && i_axi_ready) begin
                        o_axi_valid  <= 1'b1;
                        o_axi_data   <= fifo_data_reg;
                        o_axi_user   <= i_axi_user;
                        // Clear the data validity flag after sending
                        fifo_data_valid <= 1'b0;
                        data_pending    <= 1'b0;
                        
                        if (data_count + 24'd1 >= block_size_reg) begin
                            o_axi_last  <= 1'b1;
                            fifo_active <= 1'b0;
                            next_state  <= IDLE;
                        end 
                        else begin
                            next_state <= READ_FIFO;
                        end
                    end 
                    else begin
                        next_state <= SEND_AXI;
                    end
                end
                
                default: next_state <= IDLE;
            endcase
            current_state <= next_state;
        end
    end

endmodule