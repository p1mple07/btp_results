module axi_alu (
    input  wire        axi_clk_in,
    input  wire        fast_clk_in,
    input  wire        reset_in,
    input  wire*     axi_awvalid_i,
    input  wire*     axi_wvalid_i,
    
    output wire*      axi_awready_o,
    output wire*      axi_wready_i,
    output wire*      axi_bvalid_o,
    output wire*      axi_rvalid_o,
    output wire*      result_o
);
    
    wire        clock_control;
    wire [31:0]  operand_a,
    wire [31:0]  operand_b,
    wire [31:0]  operand_c,
    wire [1:0]   op_select,
    wire        start;
    
    // AXI interface
    axi_csr_block (
        .axi_a (operand_a_cdc),
        .axi_wvalid_i (axi_wvalid_i),
        .axi_wready_o (axi_wready_o),
        .axi_bvalid_i (axi_bvalid_i),
        .axi_arvalid_i (axi_arvalid_i),
        .axi_arready_o (axi_arready_o),
        .axi_rvalid_o (axi_rvalid_o),
        .result_o (result_o)
    );
    
    // AXI to CSR
    axi_csr_block (
        .axi_a (operand_a_cdc),
        .axi_areset_i (reset_in),
        .axi_awvalid_i (axi_awvalid_i),
        .axi_wvalid_i (axi_wvalid_i),
        .axi_wstrb_i (axi_wstrb_i),
        .axi_bvalid_i (axi_bvalid_i),
        .axi_arvalid_i (axi_arvalid_i),
        .axi_arstrb_i (axi_arstrb_i),
        .axi_rvalid_i (axi_rvalid_i),
        .operand_a     (operand_a_cdc),
        .operand_b     (operand_b_cdc),
        .operand_c     (operand_c_cdc),
        .op_select     (op_select),
        .start         (start),
        .clock_control (clock_control)
    );
    
    // DSP processing
    dsp_block (
        .clk (clk),
        .reset_in (reset_in),
        .operand_a (operand_a_cdc),
        .operand_b (operand_b_cdc),
        .operand_c (operand_c_cdc),
        .op_select (op_select),
        .start (start),
        .result (result_o)
    );
    
    // Memory block
    memory_block (
        .clk (clk),
        .reset_in (reset_in),
        .address_a (operand_a_addr),
        .address_b (operand_b_addr),
        .address_c (operand_c_addr),
        .data_a (data_a),
        .data_b (data_b),
        .data_c (data_c)
    );
    
    // CSR outputs
    output reg [31:0] operand_a_addr, operand_b_addr, operand_c_addr;
    output reg [1:0]  op_select;
    output reg        start;
    output reg        clock_control;
    output reg [31:0] result;
    
    // Initializations
    always @(posedge axi_clk_in or posedge fast_clk_in or posedge reset_in) begin
        if (reset_in) begin
            operand_a_addr <= 32'd0;
            operand_b_addr <= 32'd0;
            operand_c_addr <= 32'd0;
            op_select <= 2'b00;
            start <= 1'b0;
            clock_control <= 1'b0;
            result <= 32'd0;
            $readmemh("../rom_data.mem", rom);
        end else begin
            operand_a_addr <= 32'd0;
            operand_b_addr <= 32'd0;
            operand_c_addr <= 32'd0;
            op_select <= 2'b00;
            start <= 1'b0;
            clock_control <= 1'b0;
            result <= 32'd0;
        end
    end
endmodule