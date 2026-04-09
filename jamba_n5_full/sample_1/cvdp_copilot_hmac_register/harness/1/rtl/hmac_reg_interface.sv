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

    localparam NUM_REGS = 1 << ADDR_WIDTH;
    localparam [DATA_WIDTH-1:0] XOR = {(DATA_WIDTH/2){2'b01}};

    state_t current_state, next_state;

    // Registers
    logic [DATA_WIDTH-1:0] registers [NUM_REGS-1:0];

    assign current_state = IDLE;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        if (current_state == IDLE) begin
            if (write_en)
                next_state = ANALYZE;
            else
                next_state = IDLE;
        end else if (current_state == ANALYZE) begin
            if (wdata[3:0] == XOR)
                next_state = XOR_DATA;
            else
                next_state = WRITE;
        end else if (current_state == XOR_DATA) begin
            xor_data = wdata[3:0] ^ XOR[3:0];
            next_state = WRITE;
        end else if (current_state == WRITE) begin
            rdata = wdata;
            next_state = IDLE;
        end else if (current_state == LOST) begin
            if (read_en)
                next_state = CHECK_KEY;
            else
                next_state = LOST;
        end else if (current_state == CHECK_KEY) begin
            if (hmac_key == 4'b0)
                next_state = TRIG_WAIT;
            else
                next_state = WRITE;
        end else if (current_state == TRIG_WAIT) begin
            if (!i_wait_en)
                next_state = IDLE;
            else if (hmac_data != 0 || hmac_key != 0)
                next_state = IDLE;
            else
                next_state = WRITE;
        end
    end

    assign rdata = (current_state == WRITE) ? wdata : (current_state == XOR_DATA) ? xor_data : rdata;

    assign hmac_valid = (current_state == WRITE) && (hmac_data != 0 && hmac_key != 0);

    assign hmac_key_error = !(hmac_key[3:0] == 4'b0);

endmodule
