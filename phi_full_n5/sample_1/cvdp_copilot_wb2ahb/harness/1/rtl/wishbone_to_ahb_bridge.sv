module wishbone_to_ahb_bridge(
    input clk_i,
    input rst_i,
    input cyc_i,
    input stb_i,
    input [3:0] sel_i,
    input we_i,
    input [31:0] addr_i,
    input [31:0] data_i,
    output reg ack_o,
    output reg [31:0] data_o,
    output reg [1:0] hresp,
    output reg hready,
    output [1:0] htrans,
    output [2:0] hsize,
    output [2:0] hburst,
    output hwrite,
    output [31:0] haddr,
    output [31:0] hdata
);

    // Internal signals
    logic [31:0] a_data, a_addr;
    logic [31:0] b_data, b_addr;
    logic [2:0] h_size;
    logic h_burst = 3'b000;
    logic h_write;
    logic [1:0] h_trans;
    logic h_ready;

    // State Machine
    typedef enum logic [2:0] {IDLE, NON_SEQUENTIAL, BUSY} state_t;
    state_t state, next_state;

    // Endian Conversion
    function logic [31:0] convert_endian(input logic [31:0] data);
        return {data[31], data[30], data[29], data[28], data[27], data[26], data[25], data[24], data[23], data[22], data[21], data[20], data[19], data[18], data[17], data[16], data[15], data[14], data[13], data[12], data[11], data[10], data[9], data[8], data[7], data[6], data[5], data[4], data[3], data[2], data[1], data[0]};
    endfunction

    // Reset Behavior
    always @ (posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state <= IDLE;
            ack_o <= 1'b0;
            hready <= 1'b0;
            hdata <= 32'b0;
            haddr <= 32'b0;
            hdata <= convert_endian(data_i);
        end else begin
            state <= next_state;
        end
    end

    // Transaction Phases
    always @ (*) begin
        case (state)
            IDLE: begin
                if (stb_i && cyc_i) begin
                    next_state = NON_SEQUENTIAL;
                end
            end
            NON_SEQUENTIAL: begin
                if (we_i) begin
                    a_data = convert_endian(data_i);
                    a_addr = {addr_i[31:24], sel_i};
                    hdata = a_data;
                    haddr = a_addr;
                    hwrite = 1'b1;
                    hsize = 3'b100; // Assuming byte-level transactions for simplicity
                    h_trans = 2'b01;
                    h_burst = h_burst;
                    h_size = hsize;
                    hready <= 1'b0;
                end
            end
            BUSY: begin
                if (hready) begin
                    hdata <= convert_endian(b_data);
                    haddr <= {b_addr[31:24], sel_i};
                    hwrite = 1'b0;
                    h_trans = 2'b01;
                    h_burst = h_burst;
                    h_size = hsize;
                    h_ready = 1'b1;
                end
            end
        endcase
    end

    // Outputs
    assign data_o = hdata;
    assign ack_o = 1'b1;
    assign hresp = hresp;

endmodule
