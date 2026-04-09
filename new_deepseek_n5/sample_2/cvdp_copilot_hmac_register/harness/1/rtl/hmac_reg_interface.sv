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
    always_ff @(posedge clk or posedge rst_n) begin
        case(current_state)
            IDLE: next_state = ANALYZE if write_en else IDLE;
            ANALYZE: 
                if ((wdata[0] & (1 << (DATA_WIDTH-1))) != 0) next_state = XOR_DATA;
                else next_state = WRITE;
            XOR_DATA: next_state = WRITE;
            WRITE: 
                if (write_en) next_state = IDLE else next_state = LOST;
            LOST: next_state = CHECK_KEY if read_en else LOST;
            CHECK_KEY: 
                if (hmac_key_error == 0 && hmac_data != 0) next_state = TRIG_WAIT;
                else next_state = WRITE;
            TRIG_WAIT: 
                if (i_wait_en == 0) next_state = IDLE;
                else next_state = WRITE;
            default: next_state = IDLE;
        endcase
    end

    // XOR Logic
    logic [DATA_WIDTH-1:0] xor_data;
    always_ff @(posedge clk) begin
        xor_data = wdata ^ XOR;
    end

    // Key Validation
    logic [DATA_WIDTH-1:0] key_valid;
    always_ff @(posedge clk) begin
        key_valid = 1;
        if (hmac_key_error) key_valid = 0;
        // Pattern check for key
        key_valid = key_valid && 
            ((hmac_key[0] == 0 && hmac_key[1] == 0) && 
             (hmac_key[DATA_WIDTH-2] == 0 && hmac_key[DATA_WIDTH-1] == 0));
    end

    // Data Processing
    logic [DATA_WIDTH-1:0] data_to_write;
    always_ff @(posedge clk) begin
        if (write_en) begin
            data_to_write = wdata ^ XOR;
            registers[addr] = data_to_write;
        end
    end

    // Read Logic
    logic [DATA_WIDTH-1:0] rdata;
    always_ff @(posedge clk) begin
        if (read_en && current_state != WRITE) begin
            rdata = registers[addr];
        end
    end

    // Output Constraints
    logic [DATA_WIDTH-1:0] final_rdata;
    always_ff @(posedge clk) begin
        final_rdata = rdata;
    end
    assign rdata = final_rdata;

    // Reset Handling
    always begin
        if (rst_n) begin
            current_state = IDLE;
            for (integer i = 0; i < NUM_REGS; i++) $write(rst_n, 0, registers[i]);
            $assert(rst_n, "HMAC initialization reset");
        end
    end

endmodule