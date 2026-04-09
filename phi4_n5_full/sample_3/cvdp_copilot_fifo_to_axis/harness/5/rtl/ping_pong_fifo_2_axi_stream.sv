module ping_pong_fifo_2_axi_stream #(
    parameter DATA_WIDTH = 32
)(
    input  logic                                 rst,
    input  logic                                 i_flush,    // Flush control: immediate reset and clear pending transactions
    input  logic                                 i_pause,    // Pause control: suspend AXI data transmission without state reset

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

    // New internal signals for improved data handling
    logic [DATA_WIDTH-1:0] fifo_data_reg;    // Intermediate data register for FIFO data
    logic        fifo_data_valid;            // Indicates valid data available for AXI transmission
    logic        data_pending;               // Indicates that the module is waiting for the next FIFO data word

    // State Machine Declaration
    typedef enum logic [1:0] {
        IDLE,
        READ_FIFO,
        SEND_AXI
    } state_t;
    
    state_t current_state, next_state;

    // Synchronous state machine with asynchronous flush and reset
    always_ff @(posedge i_axi_clk or posedge rst or posedge i_flush) begin
        if (i_flush) begin
            // Flush: immediately reset state machine and clear all registers/outputs
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            fifo_data_valid    <= 1'b0;
            data_pending       <= 1'b0;
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_user         <= 4'd0;
        end
        else if (rst) begin
            // Normal reset: clear all registers and outputs
            current_state      <= IDLE;
            block_size_reg     <= 24'd0;
            data_count         <= 24'd0;
            fifo_active        <= 1'b0;
            fifo_data_valid    <= 1'b0;
            data_pending       <= 1'b0;
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_data         <= {DATA_WIDTH{1'b0}};
            o_axi_user         <= 4'd0;
        end
        else begin
            // Default assignments for outputs to ensure stability at the start of each cycle
            o_block_fifo_act   <= 1'b0;
            o_block_fifo_stb   <= 1'b0;
            o_axi_valid        <= 1'b0;
            o_axi_last         <= 1'b0;
            o_axi_user         <= 4'd0;

            // Update state
            current_state <= next_state;

            case (current_state)
                IDLE: begin
                    // Wait for FIFO to be ready; then capture block size and activate FIFO
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
                    // Request data from FIFO when active and FIFO is ready.
                    if (fifo_active && i_block_fifo_rdy) begin
                        o_block_fifo_stb <= 1'b1;
                        // Capture FIFO data into intermediate register
                        fifo_data_reg    <= i_block_fifo_data[DATA_WIDTH-1:0];
                        fifo_data_valid  <= 1'b1;
                        data_pending     <= 1'b1;
                        next_state       <= SEND_AXI;
                    end
                    else begin
                        next_state <= READ_FIFO;
                    end
                end

                SEND_AXI: begin
                    // If pause is asserted, suspend data transmission and hold in SEND_AXI
                    if (i_pause) begin
                        next_state <= SEND_AXI;
                    end
                    // Transmit data if valid and AXI is ready
                    else if (fifo_data_valid && i_axi_ready) begin
                        o_axi_valid <= 1'b1;
                        o_axi_data  <= fifo_data_reg;
                        o_axi_user  <= i_axi_user;
                        // Clear data validity and pending flags after transmission
                        fifo_data_valid <= 1'b0;
                        data_pending   <= 1'b0;
                        
                        // Check if this is the last data word
                        if (data_count + 24'd1 >= block_size_reg) begin
                            o_axi_last <= 1'b1;
                            fifo_active <= 1'b0;
                            next_state  <= IDLE;
                        end
                        else begin
                            data_count <= data_count + 24'd1;
                            next_state <= READ_FIFO;
                        end
                    end
                    else begin
                        // Maintain current state if no valid data or AXI not ready
                        next_state <= SEND_AXI;
                    end
                end

                default: next_state <= IDLE;
            endcase
        end
    end

endmodule