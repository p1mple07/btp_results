module direct_map_cache #(
    parameter CACHE_SIZE   = 256,
    parameter DATA_WIDTH   = 16,
    parameter TAG_WIDTH    = 5,
    parameter OFFSET_WIDTH = 3
)(
    input         clk,
    input         rst,
    input         enable,
    input [INDEX_WIDTH-1:0] index,
    input         [OFFSET_WIDTH-1:0] offset,
    input comp,
    input write,
    input tag_in,
    input data_in,
    input valid_in,
    output reg hit,
    output reg dirty,
    output reg tag_out,
    output reg data_out,
    output reg valid,
    output reg error
);

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            clk <= 0;
            rst <= 0;
            enable <= 0;
            index <= 0;
            offset <= 0;
            comp <= 1'b0;
            write <= 0;
            tag_in <= 0;
            data_in <= 0;
            valid_in <= 0;
            hit <= 1'b0;
            dirty <= 1'b0;
            tag_out <= 0;
            data_out <= 0;
            valid <= 1'b0;
            error <= 1'b0;
        end else begin
            // Reset behavior
            if (enable) begin
                // Initialize on reset, but after reset, we need to set up?
                // We can skip for simplicity.
            end

            // Main processing
            if (enable) begin
                if (comp) begin
                    // Compare mode: tag match check
                    if (tag_in == tag_out) begin
                        if (valid_in) begin
                            hit <= 1'b1;
                            dirty <= 1'b0;
                            tag_out <= tag_in;
                            data_out <= data_in;
                            valid <= 1'b1;
                            error <= 1'b0;
                        end else begin
                            hit <= 1'b0;
                            dirty <= 1'b1;
                            tag_out <= 0;
                            data_out <= 0;
                            valid <= 1'b0;
                            error <= 1'b1;
                        end
                    end else begin
                        hit <= 1'b0;
                        dirty <= 1'b1;
                        tag_out <= 0;
                        data_out <= 0;
                        valid <= 1'b0;
                        error <= 1'b1;
                    end
                end else begin
                    // Direct access: just output data_in
                    hit <= 1'b0;
                    dirty <= 1'b0;
                    tag_out <= 0;
                    data_out <= data_in;
                    valid <= 1'b1;
                    error <= 1'b0;
                end
            end else begin
                // No operation
                hit <= 1'b0;
                dirty <= 1'b0;
                tag_out <= 0;
                data_out <= 0;
                valid <= 1'b0;
                error <= 1'b0;
            end
        end
    end

endmodule
