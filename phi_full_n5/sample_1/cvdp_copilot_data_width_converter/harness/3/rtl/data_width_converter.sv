module data_width_converter(
    input clk,
    input reset,
    input [31:0] data_in,
    input data_valid,
    output reg [127:0] o_data_out,
    output reg o_data_out_valid
);
    // Internal state
    reg [3:0] input_count = 0;
    reg [127:0] output_buffer = {32'b0};

    // Counter to track valid inputs
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            input_count <= 0;
            output_buffer <= {32'b0};
        end else begin
            if (data_valid && input_count == 0) begin
                output_buffer <= data_in;
                input_count <= 1;
            end else if (data_valid && input_count < 4) begin
                output_buffer <= {output_buffer{data_in}};
                input_count <= input_count + 1;
            end

            // Generate output after four valid inputs
            if (input_count == 4) begin
                o_data_out <= output_buffer;
                o_data_out_valid <= 1;
                input_count <= 0; // Reset counter
            end
        end
    end
endmodule
