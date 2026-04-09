module load_store_unit(
    input clock,
    input rst_n,
    input [31:0] dmem_req_o,
    input [31:0] dmem_gnt_i,
    input [31:0] dmem_req_addr_o,
    input [3:0] dmem_req_be_o,
    input [31:0] dmem_req_wdata_o,
    input [31:0] ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [31:0] ex_if_addr_base_i,
    input [31:0] ex_if_addr_offset_i,
    input [1:0] ex_if_wdata_i,
    input [31:0] ex_if_ready_o
    output reg dmem_req_we_o,
    output reg dmem_rvalid_i,
    output reg dmem_rsp_rdata_i,
    output reg ex_if_if_o,
    output reg ex_if_we_o
);

    // State variables
    reg [1:0] state = 0;
    reg ready = 0;

    // Address calculation
    reg [31:0] addr = ex_if_addr_base_i ^ ex_if_addr_offset_i;

    // Address alignment check
    reg byte_offset = addr[1:0];
    reg word_offset = addr[3:0];
    reg halfword_offset = addr[5:4];

    // Byte enable signals
    reg [3:0] byte_enable = 0;

    // Processing
    always clocked begin
        case (state)
            0: // Reset
                if (rst_n) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 0;
                    ex_if_we_o = 0;
                    ex_if_if_o = 0;
                    ready = 1;
                    state = 1;
                end
                else if (ex_if_ready_o) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 0;
                    ex_if_we_o = 0;
                    ex_if_if_o = 0;
                    state = 1;
                end
                else if (rst_n) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 0;
                    ex_if_we_o = 0;
                    ex_if_if_o = 0;
                    state = 1;
                end
            1: // Processing
                if (ex_if_req_i) begin
                    if (ex_if_wdata_i) begin
                        dmem_req_we_o = 1;
                        dmem_req_addr_o = addr;
                        byte_enable = (ex_if_type_i == 2) ? 15 : ((ex_if_type_i == 1) ? 3 : 0);
                        dmem_req_wdata_o = ex_if_wdata_i;
                        dmem_gnt_i = 1;
                        state = 2;
                    end
                end
                else if (dmem_gnt_i) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 0;
                    state = 3;
                end
            2: // Loading
                if (dmem_gnt_i) begin
                    dmem_rvalid_i = 1;
                    state = 4;
                end
            3: // Waiting
                if (dmem_gnt_i) begin
                    dmem_rvalid_i = 0;
                    state = 5;
                end
            4: // Valid
                dmem_rvalid_i = 0;
                state = 6;
            5: // Valid
                dmem_rvalid_i = 0;
                state = 7;
            6: // Ready
                if (rst_n) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 0;
                    ex_if_we_o = 0;
                    ex_if_if_o = 0;
                    state = 0;
                end
                else if (ex_if_req_i) begin
                    dmem_req_we_o = 0;
                    dmem_req_addr_o = 0;
                    dmem_req_we_o = 0;
                    dmem_req_wdata_o = 0;
                    dmem_gnt_i = 1;
                    state = 1;
                end
            default:
                state = 0;
        end
    end

    // Alias for ex_if_req_i
    ex_if_if_o = ex_if_req_i;
endmodule