module hmac_reg_interface #( 
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8  
) (
    input  logic                  clk,       
    input  logic                  rst_n,     
    input  logic                  write_en,  
    input  logic                  read_en,   
    input  logic [ADDR_WIDTH-1:0] addr,      
    input  logic [DATA_WIDTH-1:0] wdata,     
    input  logic                  i_wait_en,
    output logic [DATA_WIDTH-1:0] rdata,     
    output logic                  hmac_valid,
    output logic                  hmac_key_error
);

    // Number of registers
    localparam NUM_REGS = 1 << ADDR_WIDTH;
    localparam [DATA_WIDTH/2-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    // FSM States
    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        ANALYZE  = 3'b001,
        XOR_DATA = 3'b010,
        WRITE    = 3'b011,
        LOST     = 3'b100,
        CHECK_KEY= 3'b101,
        TRIG_WAIT= 3'b110
    } state_t;

    state_t current_state, next_state;

    // FSM Logic
    case(current_state)
        IDLE: next_state = IDLE if (!write_en) else ANALYZE;
        ANALYZE: 
            if (wdata[0] & (1 << (DATA_WIDTH-1)))
                next_state = XOR_DATA;
            else
                next_state = WRITE;
        XOR_DATA: next_state = WRITE;
        WRITE: 
            next_state = LOST if (!read_en) else CHECK_KEY;
        LOST: 
            next_state = CHECK_KEY if (i_wait_en) else LOST;
        CHECK_KEY: 
            if (hmac_key != 0 && hmac_data != 0)
                next_state = TRIG_WAIT;
            else
                next_state = WRITE;
        TRIG_WAIT: 
            next_state = IDLE if (rdata != 0 && hmac_key != 0) else TRIG_WAIT;
    endcase

    // XOR Logic
    xor_data = (wdata & ~XOR) ^ XOR;

    // Key Validation
    logic key_valid = (hmac_key[0] == 0 && hmac_key[1] == 0 && 
        hmac_key[DATA_WIDTH-2] == 0 && hmac_key[DATA_WIDTH-1] == 0);

    // Write Logic
    registers[addr] = wdata if (write_en && current_state == WRITE);

    // Read Logic
    rdata = registers[addr] if (read_en && current_state != WRITE);

    // Output Validity
    hmac_valid = (current_state == IDLE && write_en) || 
        (current_state == TRIG_WAIT && rdata != 0 && hmac_key != 0);

    // Error Flag
    hmac_key_error = ~key_valid;

endmodule