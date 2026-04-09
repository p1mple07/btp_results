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

    // FSM and State Transition Logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= IDLE;
            hmac_key <= 0;
            hmac_data <= 0;
            rdata <= 0;
            hmac_valid <= 0;
            hmac_key_error <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == IDLE) begin
                if (write_en) begin
                    next_state <= ANALYZE;
                end else begin
                    next_state <= IDLE;
                end
            else if (current_state == ANALYZE) begin
                if (wdata[DATA_WIDTH-1] == 1'b1) begin
                    next_state <= XOR_DATA;
                end else begin
                    next_state <= WRITE;
                end
            else if (current_state == XOR_DATA) begin
                xor_data <= wdata ^ XOR;
                next_state <= WRITE;
            end
            else if (current_state == WRITE) begin
                if (addr == 0) begin
                    registers[addr] <= xor_data;
                    hmac_valid <= 1;
                end else if (addr == 1) begin
                    hmac_key <= xor_data;
                end else begin
                    registers[addr] <= wdata;
                end
                next_state <= IDLE;
            end
            else if (current_state == LOST) begin
                if (read_en) begin
                    next_state <= CHECK_KEY;
                end else begin
                    next_state <= LOST;
                end
            end
            else if (current_state == CHECK_KEY) begin
                if (i_wait_en) begin
                    if (hmac_key == 0 && hmac_data == 0) begin
                        next_state <= TRIG_WAIT;
                    end else begin
                        next_state <= WRITE;
                    end
                end else begin
                    next_state <= CHECK_KEY;
                end
            end
            else if (current_state == TRIG_WAIT) begin
                if (i_wait_en' && (hmac_data != 0) && (hmac_key != 0)) begin
                    next_state <= IDLE;
                    hmac_valid <= 1;
                end else begin
                    next_state <= WRITE;
                end
            end
        end
    end

    // Read Logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            rdata <= 0;
        end else if (read_en) begin
            if (current_state == WRITE) begin
                rdata <= registers[addr];
            end
        end
    end

    // Write Logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            hmac_key <= 0;
            hmac_data <= 0;
        end else if (write_en) begin
            hmac_key <= xor_data;
            hmac_data <= xor_data;
        end
    end

    // Key Validation Logic
    always @(wdata) begin
        hmac_key_error = (wdata == 2'b00 || wdata == 2'b01 || wdata == 2'b10 || wdata == 2'b11);
    end

endmodule
