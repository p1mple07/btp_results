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
    always_ff @(posedge clk or negedge rst_n) begin
        case(current_state)
            IDLE: next_state = ANALYZE if write_en else IDLE;
            ANALYZE: 
                if (wdata[ADDR_WIDTH-1:0].MSB) next_state = XOR_DATA;
                else next_state = WRITE;
            XOR_DATA: next_state = WRITE;
            WRITE: 
                if (write_en) next_state = IDLE else next_state = LOST;
            LOST: 
                next_state = CHECK_KEY if read_en else LOST;
            CHECK_KEY: 
                if (hmac_key_error) next_state = WRITE else next_state = TRIG_WAIT;
            TRIG_WAIT: 
                if (i_wait_en) next_state = IDLE else next_state = WRITE;
        endcase
    end

    // XOR Logic
    always_ff @(posedge clk) begin
        xor_data = wdata ^ XOR;
    end

    // Key Validation
    always_ff @(posedge clk) begin
        logic key_valid = 1;
        if (hmac_key[3:0] != 0) key_valid = 0;
        if (hmac_key[(DATA_WIDTH-1-3):0] != 0) key_valid = 0;
        hmac_key_error = ~key_valid;
    end

    // Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (write_en && current_state == WRITE) begin
            registers[addr] = wdata;
            rdata = 0;
            hmac_valid = 1;
        end
    end

    // Read Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (read_en && current_state != WRITE) begin
            rdata = registers[addr];
        end
    end

endmodule