rtl/sync_serial_communication_tx_rx(
    input clk, 
    input reset_n, 
    input [2:0] sel, 
    input [63:0] data_in, 
    output [63:0] data_out, 
    output done, 
    output parity,
    output parity_error
);

// Internal signals
wire tx_block_uut (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .data_out(tx_out),
    .done(done_tx),
    .parity(parity)
);

// Instantiate tx_block
tx_block uut_tx_block (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .data_out(tx_out),
    .done(done_tx),
    .parity(parity)
);

// Internal signals
wire rx_block_uut (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .data_out(rx_out),
    .done(done_rx),
    .parity_in(parity_in)
);

// Instantiate rx_block
rx_block uut_rx_block (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .data_out(rx_out),
    .done(done_rx),
    .parity_in(parity_in)
);

// Sequential logic to drive the parity bit
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset all values on active-low reset
        data_reg <= 64'h0; // Clear the data register
        bit_count <= 7'd0; // Reset bit count to zero
    end else begin
        if (done_tx) begin
            // Case block to determine the width of data to transmit based on the 'sel' input
            case (sel)
                3'b000: begin
                    data_reg  <= {56'h0, data_in[7:0]};
                    bit_count <= 7'd7;
                end
                3'b001: begin
                    data_reg  <= {48'h0, data_in[15:0]};
                    bit_count <= 7'd15;
                end
                3'b010: begin
                    data_reg  <= {40'h0, data_in[31:0]};
                    bit_count <= 7'd31;
                end
                3'b011: begin
                    data_reg  <= data_in[63:0];
                    bit_count <= 7'd63;
                end
                3'b100: begin
                    data_reg  <= data_in[63:0];
                    bit_count <= 7'd63;
                end
                default: begin
                    data_reg  <= 64'h0;
                    bit_count <= 7'd0;
                end
            endcase
        end else if (bit_count > 7'h0) begin
            data_reg   <= data_reg >> 1;
            bit_count  <= bit_count - 1;
        end
        reg [7:0] parity_out; // Sequential logic to drive the parity bit
        parity_out <= parity; // Transmit the parity bit
    end
end

// Sequential logic to drive the parity bit
always @(posedge clk or negedge reset_n) begin 
    if (!reset_n) begin
        // Case block to determine the width of data to transmit based on the 'sel' input
        case (sel)
            3'b000: begin
                data_reg_rx <= {56'h0, data_in[7:0]};
                bit_count_rx <= 7'd7;
            end
            3'b001: begin
                data_reg_rx <= {48'h0, data_in[15:0]};
                bit_count_rx <= 7'd15;
            end
            3'b010: begin
                data_reg_rx <= {40'h0, data_in[31:0]};
                bit_count_rx <= 7'd31;
            end
            3'b011: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            3'b100: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            default: begin
                data_reg_rx <= 64'h0;
                bit_count_rx <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg_rx <= data_reg_rx >> 1;
        bit_count_rx <= bit_count_rx - 1;
        parity_out <= parity; // Transmit the parity bit
    end
end

// Set the done signal when transmission is complete
always @(posedge clock or negedge reset_n) begin 
    if (!reset_n) begin
        done = 1'b1;
        case (sel)
            3'b000: begin
                data_reg_rx <= {56'h0, data_in[7:0]};
                bit_count_rx <= 7'd7;
            end
            3'b001: begin
                data_reg_rx <= {48'h0, data_in[15:0]};
                bit_count_rx <= 7'd15;
            end
            3'b010: begin
                data_reg_rx <= {40'h0, data_in[31:0]};
                bit_count_rx <= 7'd31;
            end
            3'b011: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            3'b100: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            default: begin
                data_reg_rx <= 64'h0;
                bit_count_rx <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg_rx <= data_reg_rx >> 1;
        bit_count_rx <= bit_count_rx - 1;
    end
    done <= 1'b0;
end

// Set the done signal when transmission is complete
always @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        done_tx = 1'b1;
        case (sel)
            3'b000: begin
                data_reg <= {56'h0, data_in[7:0]};
                bit_count <= 7'd7;
            end
            3'b001: begin
                data_reg <= {48'h0, data_in[15:0]};
                bit_count <= 7'd15;
            end
            3'b010: begin
                data_reg <= {40'h0, data_in[31:0]};
                bit_count <= 7'd31;
            end
            3'b011: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            3'b100: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            default: begin
                data_reg <= 64'h0;
                bit_count <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg   <= data_reg >> 1;
        bit_count  <= bit_count - 1;
    end
    done_tx <= 1'b0;
end

// Sequential logic to drive the parity bit
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Case block to determine the width of data to transmit based on the 'sel' input
        case (sel)
            3'b000: begin
                data_reg_rx <= {56'h0, data_in[7:0]};
                bit_count_rx <= 7'd7;
            end
            3'b001: begin
                data_reg_rx <= {48'h0, data_in[15:0]};
                bit_count_rx <= 7'd15;
            end
            3'b010: begin
                data_reg_rx <= {40'h0, data_in[31:0]};
                bit_count_rx <= 7'd31;
            end
            3'b011: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            3'b100: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            default: begin
                data_reg_rx <= 64'h0;
                bit_count_rx <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg_rx <= data_reg_rx >> 1;
        bit_count_rx <= bit_count_rx - 1;
    end
    done <= 1'b0;
end

// Sequential logic to drive the parity bit
always @(posedge clock or negedge reset_n) begin 
    if (!reset_n) begin
        // Case block to determine the width of data to transmit based on the 'sel' input
        case (sel)
            3'b000: begin
                data_reg_rx <= {56'h0, data_in[7:0]};
                bit_count_rx <= 7'd7;
            end
            3'b001: begin
                data_reg_rx <= {48'h0, data_in[15:0]};
                bit_count_rx <= 7'd15;
            end
            3'b010: begin
                data_reg_rx <= {40'h0, data_in[31:0]};
                bit_count_rx <= 7'd31;
            end
            3'b011: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            3'b100: begin
                data_reg_rx <= data_in[63:0];
                bit_count_rx <= 7'd63;
            end
            default: begin
                data_reg_rx <= 64'h0;
                bit_count_rx <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg_rx <= data_reg_rx >> 1;
        bit_count_rx <= bit_count_rx - 1;
    end
    done <= 1'b0;
end

// Set the done signal when transmission is complete
always @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        done_tx = 1'b1;
        case (sel)
            3'b000: begin
                data_reg <= {56'h0, data_in[7:0]};
                bit_count <= 7'd7;
            end
            3'b001: begin
                data_reg <= {48'h0, data_in[15:0]};
                bit_count <= 7'd15;
            end
            3'b010: begin
                data_reg <= {40'h0, data_in[31:0]};
                bit_count <= 7'd31;
            end
            3'b011: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            3'b100: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            default: begin
                data_reg <= 64'h0;
                bit_count <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg   <= data_reg >> 1;
        bit_count  <= bit_count - 1;
    end
    done_tx <= 1'b0;
end

// Set the done signal when transmission is complete
always @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        done = 1'b1;
        case (sel)
            3'b000: begin
                data_reg <= {56'h0, data_in[7:0]};
                bit_count <= 7'd7;
            end
            3'b001: begin
                data_reg <= {48'h0, data_in[15:0]};
                bit_count <= 7'd15;
            end
            3'b010: begin
                data_reg <= {40'h0, data_in[31:0]};
                bit_count <= 7'd31;
            end
            3'b011: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            3'b100: begin
                data_reg <= data_in[63:0];
                bit_count <= 7'd63;
            end
            default: begin
                data_reg <= 64'h0;
                bit_count <= 7'd0;
            end
        endcase
    end else if (bit_count > 7'h0) begin
        data_reg <= data_reg >> 1;
        bit_count <= bit_count - 1;
    end
    done <= 1'b0;
end