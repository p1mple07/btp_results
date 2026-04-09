module systolic_array (
    // PE Width
    parameter DATA_WIDTH = 8,
    // Number of processing elements
    parameter ROWS = 2,
    parameter COLS = 2
)

    // PE Configurations
    localparam PE_ROW = 0, 1;
    localparam PE_COL = 0, 1;

    // Instantiate Processing Elements
    foreach (row in PE_ROW)
        foreach (col in PE_COL)
            instantiated #(
                DATA_WIDTH = DATA_WIDTH,
                weight#(stationary = true)
            )(pe_row(row), pe_col(col));

    // Configuration parameters
    reg clock = 1'b0;
    reg valid = 1'b0;
    reg done = 1'b0;

    // Control signals
    reg load_weight = 1'b0;
    reg start = 1'b0;

    // Input signals
    wire [
        DATA_WIDTH-1:0
    ] input_left, input_right,
    input_top, input_bottom;

    // Weight-related signals
    reg [
        DATA_WIDTH-1:0
    ] weight_reg[COLS][ROWS];

    // Output signals
    reg [
        DATA_WIDTH-1:0
    ] output_left, output_right,
    output_top, output_bottom;

    // Internal registers
    reg [
        DATA_WIDTH-1:0
    ] psum_reg[COLS][ROWS];

    // Always block
    always @posedge clock or posedge reset) begin
        if (reset) begin
            // Initialize all weights to 0
            weight_reg[0][0] = {DATA_WIDTH{1'b0}};
            weight_reg[0][1] = {DATA_WIDTH{1'b0}};
            weight_reg[1][0] = {DATA_WIDTH{1'b0}};
            weight_reg[1][1] = {DATA_WIDTH{1'b0}};

            // Initialize all psums to 0
            psum_reg[0][0] = {DATA_WIDTH{1'b0}};
            psum_reg[0][1] = {DATA_WIDTH{1'b0}};
            psum_reg[1][0] = {DATA_WIDTH{1'b0}};
            psum_reg[1][1] = {DATA_WIDTH{1'b0}};
        end else begin
            // Propagate data from left and top PEs
            input_left = pe_col(0).input_out;
            input_top = pe_row(0).input_out;
            
            // Compute MAC operation and pass result downstream
            output_left = pe_col(0).weight_reg <= weight_reg[0][0],
                        psum_out <= psum_reg[0][0] + (input_left * weight_reg[0][0]);

                        output_top = pe_row(0).weight_reg <= weight_reg[0][0],
                                    psum_out <= psum_reg[0][0] + (input_top * weight_reg[0][0]);

            output_right = pe_col(1).weight_reg <= weight_reg[1][0],
                        psum_out <= psum_reg[1][0] + (input_left * weight_reg[1][0]);

                        output_bottom = pe_row(1).weight_reg <= weight_reg[0][1],
                                    psum_out <= psum_reg[0][1] + (input_top * weight_reg[0][1]);

            // Update weights when needed
            if (valid) begin
                weight_reg[0][0] <= pe_col(0).weight;
                weight_reg[0][1] <= pe_row(1).weight;
                weight_reg[1][0] <= pe_row(0).weight;
                weight_reg[1][1] <= pe_row(1).weight;
            end
        end
    end

    // Ensure proper propagation of the done signal
    // (needs to be implemented based on specific PE implementation)
    // Note: This is a simplified version and assumes that PE.done indicates completion
    // You may need to adjust this based on actual PE implementation
    wire done_pe[COLS][ROWS];
    foreach (row in PE_ROW)
        foreach (col in PE_COL)
            done_pe[col][row] <= pe_row(row).done;
    done = ~done_pe[0][0] & ~done_pe[0][1] & ~done_pe[1][0] & ~done_pe[1][1];

endmodule