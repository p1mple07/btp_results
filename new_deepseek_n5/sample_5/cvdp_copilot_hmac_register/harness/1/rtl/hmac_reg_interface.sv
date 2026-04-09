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
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

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
    always_ff @(posedge clk or posedge rst_n) begin
        case(current_state)
            IDLE: 
                if (write_en) 
                    next_state = ANALYZE;
                else 
                    next_state = IDLE;
                    endcase

            ANALYZE:
                if ((wdata & (1 << (DATA_WIDTH-1))) != 0)
                    next_state = XOR_DATA;
                else 
                    next_state = WRITE;
                    endcase

            XOR_DATA:
                xor_data = wdata ^ XOR;
                next_state = WRITE;
                endcase

            WRITE:
                if (write_en) 
                    next_state = IDLE;
                else 
                    next_state = LOST;
                    endcase

            LOST:
                if (read_en) 
                    next_state = CHECK_KEY;
                else 
                    next_state = LOST;
                    endcase

            CHECK_KEY:
                if (hmac_key != 0 && hmac_data != 0)
                    next_state = TRIG_WAIT;
                else 
                    next_state = WRITE;
                    endcase

            TRIG_WAIT:
                if (hmac_data != 0 && hmac_key != 0)
                    next_state = IDLE;
                else 
                    next_state = TRIG_WAIT;
                    endcase
        default
            next_state = current_state;
        endcase
    endalways

    // XOR Logic
    always_ff @(posedge clk) begin
        if (write_en && addr == 0) 
            registers[0] = wdata ^ XOR;
        else if (write_en && addr == 1) 
            registers[1] = wdata ^ XOR;
        end
    endalways

    // Read Logic
    always_ff @(posedge clk) begin
        if (read_en && current_state != WRITE) 
            rdata = registers[addr];
        end
    endalways

    // Reset Handling
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state = IDLE;
            registers[0:NUM_REGS-1] = 0;
            hmac_key = 0;
            hmac_data = 0;
            xor_data = 0;
        end
    endalways