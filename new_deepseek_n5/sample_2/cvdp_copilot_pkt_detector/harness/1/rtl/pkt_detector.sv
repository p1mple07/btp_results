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

// State Register
always_ff @(posedge clk or negedge reset) begin
    if (!reset)
        curr_state <= S_IDLE;
    else
        curr_state <= nxt_state;
end

// Next State Logic
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
                if (data_k_flag == 1'b1)
                    pkt_reg[byte_cnt: byte_cnt + 7] = data_in;
                    byte_cnt++;
                nxt_state = S_ACTIVE;

        S_WAIT_END: 
            if (pkt_reg[159:152] == END_SYMBOL)
            begin
                pkt_data = pkt_reg;
                byte_cnt = 0;
                // Set detection flags based on header
                if (pkt_reg[31:24] != 0) 
                    // Implement logic to set detection flags
                    // based on the header value
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

endmodule