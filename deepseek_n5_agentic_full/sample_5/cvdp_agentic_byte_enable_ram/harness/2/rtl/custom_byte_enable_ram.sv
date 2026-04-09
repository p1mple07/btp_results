Module Implementation

module custom_byte_enable_ram (
    parameter XLEN,
    parameter LINES,
    localparam ADDR_WIDTH,
    input clock,
    input [ADDR_WIDTH-1:0] addr_a,
    input en_a,
    input [XLEN/8-1:0] be_a,
    input [XLEN-1:0] data_in_a,
    output [XLEN-1:0] data_out_a,
    input [ADDR_WIDTH-1:0] addr_b,
    input en_b,
    input [XLEN/8-1:0] be_b,
    input [XLEN-1:0] data_in_b,
    output [XLEN-1:0] data_out_b
)

    // Register stage to capture inputs on falling edge of clock
    reg [ADDR_WIDTH-1:0] addr_a_reg;
    reg en_a_reg;
    reg [XLEN/8-1:0] be_a_reg;
    reg [XLEN-1:0] data_in_a_reg;

    reg [ADDR_WIDTH-1:0] addr_b_reg;
    reg en_b_reg;
    reg [XLEN/8-1:0] be_b_reg;
    reg [XLEN-1:0] data_in_b_reg;

    // Memory array
    logic [XLEN-1:0] ram [LINES-1:0];

    // Collision handling variables
    reg byte_a_were_high;
    reg byte_b_were_high;
    reg collision_happened;

private:

    // Initialization
    initial begin
        // Initialize memory to zero
        $for (i=0; i<LINES; i=i+1)
            ram[i] = 0;
        $finish

        addr_a_reg = 0;
        en_a_reg = 0;
        be_a_reg = 0;
        data_in_a_reg = 0;
        addr_b_reg = 0;
        en_b_reg = 0;
        be_b_reg = 0;
        data_in_b_reg = 0;
    end

    // Register the inputs on falling edge of clock
    always clock's_edge begin
        addr_a_reg = addr_a;
        en_a_reg = en_a;
        be_a_reg = be_a;
        data_in_a_reg = data_in_a;

        addr_b_reg = addr_b;
        en_b_reg = en_b;
        be_b_reg = be_b;
        data_in_b_reg = data_in_b;
    end

    // Collision detection
    always clock's_edge begin
        byte_a_were_high = be_a_reg & (~en_a_reg);
        byte_b_were_high = be_b_reg & (~en_b_reg);

        if (byte_a_were_high & byte_b_were_high)
            collision_happened = 1;
        else
            collision_happened = 0;
    end

    // Determine which port's data to use for output
    always clock's_edge begin
        if (collision_happened)
            if (byte_a_were_high) 
                data_out_a = data_in_a_reg;
            else 
                data_out_a = data_in_b_reg;
            
            if (byte_b_were_high) 
                data_out_b = data_in_b_reg;
            else 
                data_out_b = data_in_a_reg;
        else
            data_out_a = data_in_a_reg;
            data_out_b = data_in_b_reg;
    end

private:

    // Data_out assignment
    always clock's_edge begin
        data_out_a = data_out_a;
        data_out_b = data_out_b;
    end

endmodule