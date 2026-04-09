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

    // HMAC data
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;

    logic [DATA_WIDTH-1:0] xor_data;

    // FSM State Logic
    always @(posedge clk) begin
        current_state <= next_state;
    end

    // State Transition Logic
    always @* begin
        case (current_state)
            IDLE:
                if (write_en) begin
                    next_state = ANALYZE;
                end else
                    next_state = IDLE;
            ANALYZE:
                if (wdata[DATA_WIDTH-1]) begin
                    next_state = XOR_DATA;
                end else begin
                    next_state = WRITE;
                end
            XOR_DATA:
                xor_data = XOR & wdata;
                next_state = WRITE;
            WRITE:
                if (addr < NUM_REGS) begin
                    if (addr == 0) begin
                        hmac_data <= xor_data;
                        hmac_valid = 1'b1;
                    end else if (addr == 1) begin
                        hmac_key <= xor_data;
                        hmac_key_error = 1'b0;
                    end else begin
                        registers[addr] <= xor_data;
                    end
                    if (write_en) begin
                        next_state = IDLE;
                    end else begin
                        next_state = LOST;
                    end
                end else begin
                    next_state = IDLE;
                end
            LOST:
                if (read_en) begin
                    if (current_state == CHECK_KEY) begin
                        next_state = TRIG_WAIT;
                    end else begin
                        next_state = LOST;
                    end
                end else begin
                    next_state = IDLE;
                end
            CHECK_KEY:
                // Key Validation Logic
                if (hmac_key[DATA_WIDTH-1] == 0 && hmac_key[DATA_WIDTH-2] == 0) begin
                    hmac_key_error = 1'b0;
                    next_state = WRITE;
                end else begin
                    hmac_key_error = 1'b1;
                    next_state = CHECK_KEY;
                end
            TRIG_WAIT:
                if (!i_wait_en) begin
                    if (hmac_data && hmac_key) begin
                        next_state = IDLE;
                        hmac_valid = 1'b1;
                    end else begin
                        next_state = WRITE;
                    end
                end else begin
                    next_state = TRIG_WAIT;
                end
        endcase
    end

    // Read Logic Operation
    always @(posedge clk) begin
        if (read_en && current_state != WRITE) begin
            rdata <= registers[addr];
        end
    end

    // Write Logic Operation
    always @(posedge clk) begin
        if (write_en && current_state == IDLE) begin
            if (addr < NUM_REGS) begin
                if (addr == 0) begin
                    hmac_data <= wdata;
                    hmac_valid = 1'b1;
                end else if (addr == 1) begin
                    hmac_key <= wdata;
                    hmac_key_error = 1'b0;
                end else begin
                    registers[addr] <= wdata;
                end
            end
        end
    end

    // Reset Logic
    always @(posedge clk) begin
        if (rst_n) begin
            hmac_key <= 0;
            hmac_data <= 0;
            current_state <= IDLE;
        end
    end

endmodule
