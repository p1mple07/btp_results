module multiplexer #(
    parameter int DATA_WIDTH = 8,
    parameter int NUM_INPUTS = 4,
    parameter bit REGISTER_OUTPUT = 0,
    parameter bit HAS_DEFAULT = 0,
    parameter logic [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
) (
    input  wire clk,
    input  wire rst_n,
    input  wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire bypass,
    output reg  [DATA_WIDTH-1:0] out
);
    typedef enum logic [1:0] {
        SEL_0 = 2'b00,
        SEL_1 = 2'b01,
        SEL_2 = 2'b10,
        SEL_3 = 2'b11
    } sel_e;

    logic [DATA_WIDTH-1:0] inp_array [NUM_INPUTS-1:0];
    logic [1:0]              sel_sync;
    logic                        sel_reg;
    logic [DATA_WIDTH-1:0]     out_sync;
    logic                          out_reg;
    logic [DATA_WIDTH-1:0]     out_comb;

    assign sel_sync = sel;
    assign out_sync = out;
    
    // Registering Output
    generate
        if (REGISTER_OUTPUT == 1) begin
            always @(posedge clk) begin
                case (sel_sync)
                    SEL_0: inp_array[0] <= inp;
                    SEL_1: inp_array[1] <= inp;
                    SEL_2: inp_array[2] <= inp;
                    SEL_3: inp_array[3] <= inp;
                    default: ;
                endcase
            end
    endgenerate
    always @(posedge clk) begin
        case (sel_sync)
            SEL_0: out_comb = inp_array[0];
            SEL_1: out_comb = inp_array[1];
            SEL_2: out_comb = inp_array[2];
            SEL_3: out_comb = inp_array[3];
            default: ;
        endcase
        
        if (REGISTER_OUTPUT == 1) begin
            sel_reg = sel_sync;
            out_reg = out_sync;
        end
        if (REGISTER_OUTPUT == 0) begin
            sel_comb = sel_sync;
            out_comb = out_sync;
        end
    end

    // Combinational Logic
    always @(*) begin
        unique case (sel_comb)
            SEL_0: out_comb = inp_array[0].
end

module multiplexer #(DATA_WIDTH = 8) (
    input wire [DATA_WIDTH-1:0],
    output reg [DATA_WIDTH-1:0] out,
    input wire [DATA_WIDTH-1:0] inp,
    input wire sel,
    input wire [DATA_WIDTH-1:0] inp,
    output reg [DATA_WIDTH-1:0] out
);

// Combinational Logic
assign sel_comb = sel;

always @(*) begin
    case (sel_comb)
        SEL_0: out_comb = inp_array[0] <= inp;
        SEL_1: out_comb = inp_array[1] <= inp_array[1] when sel_comb is SEL_1;
        SEL_0: out_comb is not assigned.

endmodule