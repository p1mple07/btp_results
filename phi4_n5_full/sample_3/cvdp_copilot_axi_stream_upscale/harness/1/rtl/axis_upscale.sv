module axis_upscale (
    input  logic         clk,
    input  logic         resetn,
    input  logic         dfmt_enable,
    input  logic         dfmt_type,
    input  logic         dfmt_se,
    input  logic         s_axis_valid,
    input  logic [23:0]  s_axis_data,
    input  logic         m_axis_ready,
    output logic         s_axis_ready,
    output logic         m_axis_valid,
    output logic [31:0]  m_axis_data
);

    // Internal registers for a single pipeline stage
    reg [23:0] data_reg;
    reg        valid_reg;

    // Pipeline register: capture input data when valid and master is ready.
    // When reset is de-asserted, all registers are cleared.
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            data_reg  <= 24'd0;
            valid_reg <= 1'b0;
        end else begin
            if (valid_reg && m_axis_ready) begin
                valid_reg <= s_axis_valid;
                data_reg  <= s_axis_data;
            end
        end
    end

    // Handshake signals: slave ready is driven by master ready.
    assign s_axis_ready = m_axis_ready;
    assign m_axis_valid = valid_reg;

    // Compute the 8-bit extension based on data format signals.
    // If dfmt_enable is false, the extension is all zeros.
    // If dfmt_enable is true and dfmt_se is true, then the extension bits
    // are all set to either the MSB of s_axis_data (if dfmt_type is 0)
    // or its inverted value (if dfmt_type is 1).
    logic [7:0] ext;
    always_comb begin
        if (!dfmt_enable) begin
            ext = 8'd0;
        end else begin
            if (dfmt_se) begin
                ext = (dfmt_type) ? {8{~data_reg[23]}} : {8{data_reg[23]}};
            end else begin
                ext = 8'd0;
            end
        end
    end

    // Construct m_axis_data by concatenating the extension bits with the 24-bit input data.
    assign m_axis_data = {ext, data_reg};

endmodule