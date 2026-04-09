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

    // HMAC data
    logic [DATA_WIDTH-1:0] hmac_key;
    logic [DATA_WIDTH-1:0] hmac_data;

    logic [DATA_WIDTH-1:0] xor_data;

    // FSM Logic
    always @(posedge clk) begin
        if (rst_n) begin
            current_state <= IDLE;
            hmac_key <= 0;
            hmac_data <= 0;
        end else begin
            case (current_state)
                IDLE:
                    if (write_en) begin
                        current_state <= ANALYZE;
                    end else
                        current_state <= IDLE;
                ANALYZE:
                    if (wdata[7]) begin
                        current_state <= XOR_DATA;
                    end else begin
                        current_state <= WRITE;
                    end
                XOR_DATA:
                    xor_data = XOR & wdata;
                    current_state <= WRITE;
                WRITE:
                    if (addr < NUM_REGS-1) begin
                        if (addr == 0) begin
                            hmac_key <= wdata;
                        end
                        if (addr == 1) begin
                            hmac_data <= wdata;
                        end
                        registers[addr] <= xor_data;
                        hmac_valid <= 1;
                        next_state <= IDLE;
                    end else begin
                        current_state <= LOST;
                    end
                LOST:
                    if (read_en) begin
                        current_state <= CHECK_KEY;
                    end else
                        current_state <= WRITE;
                CHECK_KEY:
                    if (i_wait_en && hmac_key != 0 && hmac_key[7] == 0 && hmac_key[6] == 0) begin
                        current_state <= TRIG_WAIT;
                    end else begin
                        current_state <= WRITE;
                    end
                TRIG_WAIT:
                    if (i_wait_en) begin
                        current_state <= IDLE;
                        hmac_valid <= 1;
                        next_state <= IDLE;
                    end else begin
                        current_state <= WRITE;
                    end
            endcase
        end
    end

    // XOR Logic
    always @(wdata) begin
        xor_data = XOR & wdata;
    end

    // Key Validation
    always @* begin
        hmac_key_error = (hmac_key[7] != 0 || hmac_key[6] != 0);
    end

    // Write Logic
    always @(posedge clk) begin
        if (current_state == WRITE) begin
            if (write_en) begin
                registers[addr] <= xor_data;
                hmac_valid <= 1;
            end
        end
    end

    // Read Logic
    always @* begin
        if (read_en && current_state == IDLE) begin
            rdata <= registers[addr];
        end
    end

endmodule
