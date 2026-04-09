module multiplexer #(
    parameter int unsigned DATA_WIDTH = 8,
    parameter int unsigned NUM_INPUTS = 4,
    parameter bit          REGISTER_OUTPUT = 0,
    parameter bit          HAS_DEFAULT = 0,
    parameter logic [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
)(
    input  wire logic clk,
    input  wire logic rst_n,
    input  wire logic [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire logic [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire logic bypass,
    output wire logic [DATA_WIDTH-1:0] out
);
    localparam int unsigned SELECTOR_BITS = $clog2(NUM_INPUTS);
    logic [NUM_INPUTS-1:0][DATA_WIDTH-1:0] inp_array;
    assign inp_array = {NUM_INPUTS{inp}};
    
    generate
        genvar i;
        for (i=0; i<NUM_INPUTS; i++) begin : channel
            assign out = (sel == i)? inp_array[i] : ((HAS_DEFAULT && sel > NUM_INPUTS-1)? DEFAULT_VALUE : 'X);
            always @(posedge clk or posedge rst_n) begin
                if (!rst_n) begin
                    // Reset the output when rst_n is low
                    out <= '0;
                end else begin
                    // Use combinatorial logic when REGISTER_OUTPUT is set to 0
                    if (bypass) begin
                        // Force the output to always be inp_array[0] when bypass is high
                        out <= inp_array[0];
                    end else if (sel >= NUM_INPUTS) begin
                        // Set the output to the DEFAULT_VALUE when sel is greater than or equal to NUM_INPUTS.
                        out <= DEFAULT_VALUE;
                    end else begin
                        // Use the selected input data
                        out <= inp_array[sel];
                    end
                end
            endgenerate
        endchannel
    endgenerate
    
    // Use combinatorial logic when REGISTER_OUTPUT is set to 0
    always_comb begin
        // Generate the output based on the input data.
    end
endmodule