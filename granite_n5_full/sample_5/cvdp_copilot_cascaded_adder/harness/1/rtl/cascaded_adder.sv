module cascaded_adder #(
    parameter IN_DATA_WIDTH = 16,
    parameter IN_DATA_NS    = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [IN_DATA_WIDTH-1:0] i_data,
    output logic o_valid,
    output logic [IN_DATA_WIDTH+($clog2(IN_DATA_NS)-1):0] o_data
);

    // Register inputs
    reg  [IN_DATA_WIDTH-1:0] reg_i_data;
    reg                      reg_i_valid;
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_i_data <= {IN_DATA_WIDTH{1'b0}};
            reg_i_valid <= 1'b0;
        end else begin
            if(reg_i_valid & ~i_valid) begin
                reg_i_data <= {IN_DATA_WIDTH{1'b0}};
            end else begin
                reg_i_data <= i_data;
            end
            reg_i_valid <= i_valid;
        end
    end

    // Local variables
    logic [IN_DATA_WIDTH-1:0] accu;
    logic [IN_DATA_NS-1:0]   stage;

    // Adders
    generate
        for(genvar i = 0; i < IN_DATA_NS; ++i) begin
            add_stage #(.IN_WIDTH(IN_DATA_WIDTH))
            add_stage_inst (
               .clk     (clk),
               .rst_n   (rst_n),
               .i_valid (reg_i_valid),
               .i_data  (reg_i_data[(i*IN_DATA_WIDTH)+(IN_DATA_WIDTH-1):i*IN_DATA_WIDTH]),
               .o_valid (stage[i]),
               .o_data  (accu)
            );
        end
    endgenerate

    // Output register
    always @(posedge clk) begin
        if(reg_i_valid) begin
            o_valid <= 1'b1;
            o_data  <= {{($clog2(IN_DATA_NS)-1){1'b0}}, reg_i_valid};
        end else begin
            o_valid <= 1'b0;
            o_data  <= {IN_DATA_WIDTH+($clog2(IN_DATA_NS)-1){1'b0}};
        end
    end

endmodule