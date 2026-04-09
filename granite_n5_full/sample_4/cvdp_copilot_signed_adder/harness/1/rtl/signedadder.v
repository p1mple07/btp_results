module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            //Reset logic
            //...
        end else begin
            case(o_status)
                2'b00: begin
                    if (i_start && i_enable) begin
                        //Load state logic
                        //...
                    end
                end
                2'b01: begin
                    //Load state logic
                    //...
                end
                2'b10: begin
                    //Compute state logic
                    //...
                end
                2'b11: begin
                    //Output state logic
                    //...
                end
                default: begin
                    //Default state logic
                    //...
                end
            endcase
        end
    end
    
    assign o_overflow = (i_mode == 1)? ((i_operand_a[DATA_WIDTH-1] & ~i_operand_b[DATA_WIDTH-1]) | (~i_operand_a[DATA_WIDTH-1] & i_operand_b[DATA_WIDTH-1])) : ((i_operand_a[DATA_WIDTH-1] & ~i_operand_b[DATA_WIDTH-1]) | (~i_operand_a[DATA_WIDTH-1] & i_operand_b[DATA_WIDTH-1]));
    
endmodule