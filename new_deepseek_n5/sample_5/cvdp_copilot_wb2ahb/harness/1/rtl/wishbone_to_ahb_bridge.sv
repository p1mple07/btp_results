module wishbone_to_ahb_bridge(
    input wire [31:0] addr_i,
    input wire [31:0] data_i,
    input wire [3:0] sel_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire we_i,
    output wire [31:0] data_o,
    output wire ack_o,
    input wire hclk,
    input wire hreset_n,
    output wire [1:0] htrans,
    output wire [2:0] hsize,
    output wire [2:0] hburst,
    output wire hwrite,
    output wire haddr,
    output wire hwdata
);

    // FSM states
    enum state { IDLE, NON-SEQUENTIAL, BUSY };
    reg state = IDLE;

    // Address calculation
    reg [31:0] ahb_addr;

    // Data conversion
    reg [31:0] ahb_data;

    // Transaction control
    reg [1:0] htrans_val = 0;
    reg [2:0] hsize_val = 0;
    reg [2:0] hburst_val = 0;

    // Clock and reset handling
    always_comb begin
        if (rst_i || hreset_n) begin
            state = IDLE;
            htrans_val = 0;
            hsize_val = 0;
            hburst_val = 0;
            haddr = 0;
            hwdata = 0;
            ack_o = 0;
        end else begin
            case (state)
                IDLE: 
                    if (cyc_i) begin
                        // Handle read transaction
                        if (sel_i[0] & sel_i[1] & sel_i[2]) begin
                            // Byte operation
                            ahb_addr = addr_i;
                            hsize_val = 8;
                            htrans_val = 0;
                            hburst_val = 0;
                            hwdata = data_i;
                        end else if (sel_i[1] & sel_i[2]) begin
                            // Halfword operation
                            ahb_addr = addr_i;
                            hsize_val = 16;
                            htrans_val = 0;
                            hburst_val = 0;
                            hwdata = data_i[15:0] | (data_i[16:31] << 1);
                        end else if (sel_i[2]) begin
                            // Word operation
                            ahb_addr = addr_i;
                            hsize_val = 32;
                            htrans_val = 0;
                            hburst_val = 0;
                            hwdata = data_i[31:0];
                        end else begin
                            // Default to byte operation
                            ahb_addr = addr_i;
                            hsize_val = 8;
                            htrans_val = 0;
                            hburst_val = 0;
                            hwdata = data_i;
                        end
                        state = NON-SEQUENTIAL;
                    end
                NON-SEQUENTIAL: 
                    if (cyc_i) begin
                        // Handle write transaction
                        ahb_addr = (addr_i << 2) | sel_i;
                        hsize_val = 4 * (sel_i[0] ? 1 : 0) + 2 * (sel_i[1] ? 1 : 0) + (sel_i[2] ? 1 : 0);
                        htrans_val = 1;
                        hburst_val = 3'b000;
                        hwrite = we_i;
                        ack_o = 0;
                        state = BUSY;
                    end else begin
                        state = IDLE;
                    end
                BUSY: 
                    if (cyc_i) begin
                        if (hready) begin
                            ack_o = 1;
                            state = IDLE;
                        end
                    end else begin
                        state = IDLE;
                    end
            endcase
        end
    end

    // Convert data to AHB format
    always_comb begin
        if (sel_i[0]) begin // Byte
            ahb_data = data_i;
        else if (sel_i[1]) begin // Halfword
            ahb_data = data_i[15:0] | (data_i[16:31] << 1);
        else if (sel_i[2]) begin // Word
            ahb_data = data_i[31:0];
        else begin // Default to byte
            ahb_data = data_i;
        end
    end

    // Assign calculated values
    ahb_addr = ahb_addr;
    htrans = htrans_val;
    hsize = hsize_val;
    hburst = hburst_val;
    hwrite = hwrite;
    hwdata = ahb_data;
endmodule