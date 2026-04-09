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

    // FSM Logic
    always @ (posedge clk) begin
        if (rst_n) begin
            current_state <= IDLE;
            hmac_key <= 0;
            hmac_data <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (write_en) begin
                        current_state <= ANALYZE;
                    end else begin
                        current_state <= IDLE;
                    end
                end
                ANALYZE: begin
                    if (wdata[DATA_WIDTH-1]) begin
                        current_state <= XOR_DATA;
                    end else begin
                        current_state <= WRITE;
                    end
                end
                XOR_DATA: begin
                    xor_data = XOR ^ wdata;
                    current_state <= WRITE;
                end
                WRITE: begin
                    if (addr == 0) begin
                        hmac_key <= wdata;
                    end else if (addr == 1) begin
                        hmac_data <= xor_data;
                    end
                    if (write_en) begin
                        current_state <= IDLE;
                    end else begin
                        current_state <= LOST;
                    end
                end
                LOST: begin
                    if (read_en) begin
                        current_state <= CHECK_KEY;
                    end else begin
                        current_state <= WRITE;
                    end
                end
                CHECK_KEY: begin
                    if (i_wait_en) begin
                        current_state <= TRIG_WAIT;
                    end else begin
                        current_state <= WRITE;
                    end
                end
                TRIG_WAIT: begin
                    if (!i_wait_en) begin
                        current_state <= IDLE;
                        hmac_valid <= 1;
                        hmac_key_error <= 0;
                    end else begin
                        current_state <= WRITE;
                    end
                end
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

    // XOR Logic
    assign xor_data = XOR ^ wdata;

    // Key Validation Logic
    always @ (*) begin
        if (addr == 0) begin
            hmac_key_error <= (wdata == 2'b0 && wdata == 2'b1);
        end else if (addr == 1) begin
            hmac_key_error <= (xor_data == 2'b0 && xor_data == 2'b1);
        end
    end

    // Read Logic
    assign rdata = hmac_data;
    assign hmac_valid = (current_state == WRITE);

    // Write Logic
    assign registers[addr] = hmac_data;

endmodule
