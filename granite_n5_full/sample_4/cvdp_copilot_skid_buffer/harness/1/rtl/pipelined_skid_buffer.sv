module pipelined_skid_buffer (
    input wire clock,
    input wire rst,

    input wire [3:0] data_i,
    input wire valid_i,
    output wire ready_o,
    output wire valid_o,
    output wire [3:0] data_o,
    input wire ready_i
    );
    
    // Define internal variables
    reg [3:0] data_reg;
    reg buffer;

    // Define module functionality
    always @(posedge clock) begin
        if (rst) begin
            // Reset logic
            data_reg <= 4'b0;
            buffer <= 1'b0;
        end else begin
            // Input data handling
            if (valid_i &&!buffer) begin
                // Store input data in the internal register
                data_reg <= data_i;
                buffer <= 1'b1;
            end else if (!valid_i && buffer) begin
                // Forward stored data to the output when ready
                data_o <= data_reg;
                valid_o <= 1'b1;
                ready_o <= 1'b1;
                buffer <= 1'b0;
            end else begin
                // No data is stored, ready for more input
                data_o <= 4'b0;
                valid_o <= 1'b0;
                ready_o <= 1'b1;
            end

            // Output data handling
            if (ready_i && buffer) begin
                // Forward stored data to the output
                data_o <= data_reg;
                valid_o <= 1'b1;
                ready_o <= 1'b0;
            end else begin
                // Data is not yet ready to be forwarded
                data_o <= 4'b0;
                valid_o <= 1'b0;
                ready_o <= 1'b1;
            end
        end
    end

endmodule

module register(
    input clk,
    input rst,

    input [3:0]data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,

    input  ready_in    
    );
    
    // Define internal variables
    reg [3:0] data_reg;
    reg data_reg_empty;
    reg data_reg_full;
    
    // Define module functionality
    always @(posedge clock) begin
        if (rst) begin
            // Reset logic
            data_reg <= 4'b0;
            data_reg_empty <= 1'b0;
            data_reg_full <= 1'b0;
        end else begin
            // Input data handling
            if (valid_in &&!data_reg_full) begin
                // Store input data in the internal register
                data_reg <= data_in;
                data_reg_full <= 1'b1;
            end else if (!valid_in && data_reg_full) begin
                // Forward stored data to the output when ready
                data_out <= data_reg;
                valid_out <= 1'b1;
                ready_out <= 1'b1;
            end else begin
                // No data is stored, ready for more input
                data_out <= 4'b0;
                valid_out <= 1'b0;
                ready_out <= 1'b0;
            end
        end
    endmodule