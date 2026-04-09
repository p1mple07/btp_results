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

    // Registers
    logic [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;
    logic [DATA_WIDTH-1:0] xor_data;

    // FSM Logic
    case(current_state)
        IDLE:
            if (write_en) begin
                next_state = ANALYZE;
            else
                next_state = IDLE;
            end

        ANALYZE:
            if ((wdata & (1 << (DATA_WIDTH-1))) != 0) begin
                next_state = XOR_DATA;
            else begin
                if (addr == 0) begin
                    next_state = WRITE;
                else begin
                    next_state = IDLE;
                end
            end
        end

        XOR_DATA:
            xor_data = wdata ^ XOR;
            next_state = WRITE;

        WRITE:
            if (write_en) begin
                if (addr == 0) begin
                    registers[0] = xor_data;
                    next_state = IDLE;
                else if (addr == 1) begin
                    registers[1] = xor_data;
                    next_state = IDLE;
                else begin
                    next_state = LOST;
                end
            else begin
                next_state = LOST;
            end
        end

        LOST:
            if (read_en) begin
                next_state = CHECK_KEY;
            else
                next_state = LOST;
            end

        CHECK_KEY:
            if ((hmac_key[3] & 1) != 0 || (hmac_key[0] & 1) != 0) begin
                next_state = WRITE;
            else
                if (hmac_data != 0 && addr == 0) begin
                    next_state = TRIG_WAIT;
                else begin
                    next_state = CHECK_KEY;
                end
            end
        end

        TRIG_WAIT:
            if (i_wait_en) begin
                next_state = IDLE;
            else
                next_state = TRIG_WAIT;
            end

    // XOR Logic
    xor_data = wdata ^ XOR;

    // Key Validation
    logic valid_key = 1;
    if ((hmac_key[3] & 1) != 0) valid_key = 0;
    if ((hmac_key[0] & 1) != 0) valid_key = 0;

    // Write Logic
    if (write_en && current_state == WRITE) begin
        if (addr == 0) begin
            registers[0] = xor_data;
            rdata = xor_data;
        else if (addr == 1) begin
            registers[1] = xor_data;
            rdata = xor_data;
        else
            rdata = 0;
    end

    // Read Logic
    if (read_en && current_state != WRITE) begin
        if (addr == 0) begin
            rdata = registers[0];
            if (hmac_key_error) rdata = 0;
        else if (addr == 1) begin
            rdata = registers[1];
            if (hmac_key_error) rdata = 0;
        else
            rdata = 0;
    end

    // Reset Handling
    if (rst_n) begin
        for (integer i = 0; i < NUM_REGS; i++) {
            registers[i] = 0;
        }
        hmac_key = 0;
        hmac_data = 0;
        current_state = IDLE;
    end

endmodule