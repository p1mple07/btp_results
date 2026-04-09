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
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= IDLE;
            hmac_key <= 0;
            hmac_data <= 0;
        end else begin
            case (current_state)
                IDLE:
                    if (write_en) begin
                        current_state <= ANALYZE;
                    end else begin
                        current_state <= IDLE;
                    end
                ANALYZE:
                    if (wdata[DATA_WIDTH-1]) begin
                        current_state <= XOR_DATA;
                    end else begin
                        current_state <= WRITE;
                    end
                XOR_DATA:
                    xor_data <= wdata ^ XOR;
                    current_state <= WRITE;
                WRITE:
                    if (addr == 0) begin
                        registers[addr] <= xor_data;
                        hmac_valid <= 1;
                    end else if (addr == 1) begin
                        hmac_key <= xor_data;
                    end else begin
                        registers[addr] <= xor_data;
                    end
                    current_state <= IDLE;
                LOST:
                    if (read_en) begin
                        current_state <= CHECK_KEY;
                    end else begin
                        current_state <= LOST;
                    end
                CHECK_KEY:
                    if (i_wait_en) begin
                        current_state <= TRIG_WAIT;
                    end else begin
                        current_state <= WRITE;
                    end
                TRIG_WAIT:
                    if (hmac_data && hmac_key) begin
                        current_state <= IDLE;
                    end else begin
                        current_state <= WRITE;
                    end
            endcase
        end
    end

    // XOR Logic
    always @(*) begin
        xor_data = wdata;
        if (wdata[DATA_WIDTH-1]) begin
            xor_data = xor_data ^ XOR;
        end
    end

    // Key Validation
    always @(*) begin
        hmac_key_error = 0;
        if (wdata[DATA_WIDTH-2] == 0 && wdata[DATA_WIDTH-1] == 0) begin
            hmac_key_error = 1;
        end
    end

    // Write Logic
    always @(*) begin
        if (current_state == WRITE) begin
            if (addr == 0) begin
                rdata <= xor_data;
                hmac_valid <= 1;
            end else if (addr == 1) begin
                hmac_data <= xor_data;
            end else begin
                rdata <= xor_data;
            end
        end
    end

    // Read Logic
    always @(*) begin
        if (current_state != WRITE && read_en) begin
            if (addr == 0) begin
                rdata <= registers[addr];
            end else if (addr == 1) begin
                rdata <= hmac_data;
            end
        end
    end

endmodule
