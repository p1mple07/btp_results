module pkt_detector #(
    parameter PKT_CNT_WIDTH = 4
) (
    input  logic                       reset,
    input  logic                       clk,
    input  logic [7:0]                 data_in,
    input  logic                       data_k_flag,
    output logic [PKT_CNT_WIDTH - 1:0] pkt_count,
    output logic [159:0]               pkt_data,
    output logic                       mem_read_detected,
    output logic                       mem_write_detected,
    output logic                       io_read_detected,
    output logic                       io_write_detected,
    output logic                       cfg_read0_detected,
    output logic                       cfg_write0_detected,
    output logic                       cfg_read1_detected,
    output logic                       cfg_write1_detected,
    output logic                       completion_detected,
    output logic                       completion_data_detected,
    output logic                       error_detected
);

localparam [7:0] START_SYMBOL = 8'hFB;
localparam [7:0] END_SYMBOL   = 8'hFD;
localparam       PKT_BYTES    = 20;

typedef enum logic [1:0] {
    S_IDLE     = 2'b00,
    S_ACTIVE   = 2'b01,
    S_WAIT_END = 2'b10,
    S_ERROR    = 2'b11
} state_t;

state_t curr_state, nxt_state;

logic [7:0]    byte_cnt;
logic [159:0]  pkt_reg;

// State transitions
always_ff @(posedge clk or negedge reset) begin
    if (!reset)
        curr_state <= S_IDLE;
    else
        curr_state <= nxt_state;
end

// Activate on START_SYMBOL with k_flag
always_comb begin
    case (curr_state)
        S_IDLE: 
            if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                nxt_state = S_ACTIVE;
            else
                nxt_state = S_IDLE;

        S_ACTIVE: 
            if (byte_cnt == PKT_BYTES)
                nxt_state = S_WAIT_END;
            else
                nxt_state = S_ACTIVE;

        S_WAIT_END: 
            if (pkt_reg[159:152] == END_SYMBOL)
                nxt_state = S_IDLE;
            else
                nxt_state = S_ERROR;

        S_ERROR: 
            if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                nxt_state = S_ACTIVE;
            else
                nxt_state = S_ERROR;

        default: nxt_state = S_IDLE;
    endcase
end

// Accumulate 20 bytes during active phase
always_ff @(posedge clk) begin
    if (nxt_state == S_ACTIVE) begin
        if (byte_cnt < PKT_BYTES) begin
            pkt_reg <= {pkt_reg[7:0], data_in};
            byte_cnt++;
        end
    end
end

// Finalise packet handling at WAIT_END
always_ff @(posedge clk) begin
    if (nxt_state == S_WAIT_END) begin
        if (pkt_reg[159:152] == END_SYMBOL) begin
            nxt_state = S_IDLE;
        end else
            nxt_state = S_ERROR;
        pkt_data <= pkt_reg[159:139];
        pkt_count <= byte_cnt - 1;
    end
end

// Detect packet completion and set flags
always_ff @(posedge clk) begin
    if (nxt_state == S_WAIT_END) begin
        if (pkt_reg[159:152] == END_SYMBOL) begin
            completion_detected <= 1'b1;
            completion_data_detected <= pkt_data[159:139];
        end else begin
            completion_detected <= 1'b0;
            completion_data_detected <= 160'b0;
        end
    end else if (nxt_state == S_ERROR) begin
        error_detected <= 1'b1;
        pkt_data <= 160'b0;
        pkt_count <= 4'd0;
    end
end

// Output detection flags
always_ff @(posedge clk) begin
    case (curr_state)
        S_IDLE: begin
            // No flags needed in idle
        end
        S_ACTIVE: begin
            mem_read_detected <= 0;
            mem_write_detected <= 0;
            io_read_detected <= 0;
            io_write_detected <= 0;
        end
        S_WAIT_END: begin
            mem_read_detected <= 0;
            mem_write_detected <= 0;
            io_read_detected <= 0;
            io_write_detected <= 0;
        end
        S_ERROR: begin
            mem_read_detected <= 0;
            mem_write_detected <= 0;
            io_read_detected <= 0;
            io_write_detected <= 0;
        end
        default: begin
            mem_read_detected <= 0;
            mem_write_detected <= 0;
            io_read_detected <= 0;
            io_write_detected <= 0;
        end
    endcase
end

endmodule
