module axis_joiner(
    input clk,
    input rst,
    input [7:0] s_axis_tdata_1,
    input s_axis_tvalid_1,
    output reg s_axis_tready_1,
    input s_axis_tlast_1,
    input [7:0] s_axis_tdata_2,
    input s_axis_tvalid_2,
    output reg s_axis_tready_2,
    input s_axis_tlast_2,
    input [7:0] s_axis_tdata_3,
    input s_axis_tvalid_3,
    output reg s_axis_tready_3,
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    output reg m_axis_tready,
    output reg m_axis_tlast,
    output [2:0] m_axis_tuser
);

    // State declaration
    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_1,
        STATE_2,
        STATE_3
    } state_t;

    reg [2:0] current_state, next_state;

    // Internal state register
    reg [2:0] temp_state;

    // Internal registers for data buffering
    logic [7:0] temp_data;
    logic [1:0] temp_valid, temp_last;
    logic temp_ready;

    // FSM for arbitration
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STATE_IDLE;
            temp_state <= STATE_IDLE;
            temp_data <= {8'b0, 8'b0};
            temp_valid <= 1'b0;
            temp_last <= 1'b0;
            temp_ready <= 1'b0;
        end else begin
            if (current_state == STATE_IDLE) begin
                if (s_axis_tvalid_1) begin
                    next_state <= STATE_1;
                end else if (s_axis_tvalid_2 && !s_axis_tvalid_1) begin
                    next_state <= STATE_2;
                end else if (s_axis_tvalid_3 && !s_axis_tvalid_1 && !s_axis_tvalid_2) begin
                    next_state <= STATE_3;
                end else begin
                    next_state <= STATE_IDLE;
                end
            end else begin
                next_state <= temp_state;
            end

            if (next_state != current_state) begin
                current_state <= next_state;
            end
        end
    end

    // FSM logic
    always @(posedge clk) begin
        if (s_axis_tready_1 && temp_ready == 1'b0) begin
            temp_data <= s_axis_tdata_1;
            temp_valid <= s_axis_tvalid_1;
            temp_last <= s_axis_tlast_1;
            temp_ready <= 1'b1;
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= temp_valid;
            m_axis_tlast <= temp_last;
            m_axis_tuser <= 3'b001;
        end else if (s_axis_tready_2 && temp_ready == 1'b0) begin
            temp_data <= s_axis_tdata_2;
            temp_valid <= s_axis_tvalid_2;
            temp_last <= s_axis_tlast_2;
            temp_ready <= 1'b1;
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= temp_valid;
            m_axis_tlast <= temp_last;
            m_axis_tuser <= 3'b010;
        end else if (s_axis_tready_3 && temp_ready == 1'b0) begin
            temp_data <= s_axis_tdata_3;
            temp_valid <= s_axis_tvalid_3;
            temp_last <= s_axis_tlast_3;
            temp_ready <= 1'b1;
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= temp_valid;
            m_axis_tlast <= temp_last;
            m_axis_tuser <= 3'b011;
        end

        // Reset logic
        if (rst) begin
            m_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
            m_axis_tuser <= 3'b000;
            busy <= 1'b0;
        end

        // Data transfer logic
        if (temp_ready == 1'b1) begin
            m_axis_tready <= temp_ready;
            busy <= 1'b1;
        end else begin
            m_axis_tready <= 1'b0;
            busy <= 1'b0;
        end
    end

    // Output signal assignments
    assign m_axis_tready = temp_ready;
    assign m_axis_tlast = temp_last;
    assign m_axis_tuser = m_axis_tuser;

    // Busy signal
    assign busy = m_axis_tready && m_axis_tvalid;

endmodule
