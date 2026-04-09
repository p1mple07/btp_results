module axis_to_uart_tx #(
    parameter CLK_FREQ = 100,
    parameter BIT_RATE = 115200,
    parameter BIT_PER_WORD = 8,
    parameter PARITY_BIT = 0,
    parameter STOP_BITS_NUM = 1
)(
    input aclk,
    input aresetn,
    input tdata,
    input tvalid,
    output reg tready,
    output reg [7:0] TX
);

localparam CLK_FREQ_HZ = CLK_FREQ;
localparam BIT_RATE_HZ = BIT_RATE;
localparam BIT_PER_WORD_TICKS = BIT_PER_WORD;
localparam BITS_PER_CYCLE = CLK_FREQ_HZ / BIT_RATE_HZ;

enum classrtl uint8_t { IDLE, START, DATA, PARITY, STOP1, STOP2 };

State current_state = IDLE;

reg [BIT_PER_WORD_TICKS-1:0] Data;
reg [BIT_PER_WORD_TICKS-1:0] next_data;
reg [BIT_PER_WORD_TICKS-1:0] Clk_Count;
reg [BIT_PER_WORD_TICKS-1:0] Bit_Count;
wire parity_bit;

always @(*) begin
    if (PARITY_BIT == 0)
        parity_bit = 1'b0;
    else if (PARITY_BIT == 1)
        parity_bit = ~Data[BIT_PER_WORD_TICKS-1];
    else if (PARITY_BIT == 2)
        parity_bit = Data[0] ^ Data[1] ^ Data[2];
    else
        parity_bit = 1'b0;
end

always @(posedge aclk or posedge aresetn) begin
    if (aresetn) begin
        current_state = IDLE;
        Data = 0;
        Bit_Count = 0;
        Clk_Count = 0;
        tready = 1'b1;
        TX = 8'b0;
        return;
    end
end

always @(comb) begin
    if (current_state == IDLE) begin
        if (tvalid && tready) begin
            current_state = START;
            Clk_Count = 0;
            next_data = 0;
        end else begin
            next_state = IDLE;
        end
    end else begin
        case (current_state)
            START: begin
                TX = 1'b0;
                if (Clk_Count == BITS_PER_CYCLE - 1) begin
                    Clk_Count = 0;
                    current_state = DATA;
                end else begin
                    Clk_Count = Clk_Count + 1;
                end
            end
            DATA: begin
                next_data = Data;
                Data <= next_data;
                if (Clk_Count == BIT_PER_WORD_TICKS - 1) begin
                    Clk_Count = 0;
                    current_state = PARITY;
                end else begin
                    Clk_Count = Clk_Count + 1;
                end
            end
            PARITY: begin
                if (PARITY_BIT == 1)
                    parity_bit = ~Data[0];
                else if (PARITY_BIT == 2)
                    parity_bit = Data[0] ^ Data[1] ^ Data[2];
                TX = parity_bit;
                current_state = STOP1;
            end
            STOP1: begin
                TX = 1'b1;
                if (Clk_Count == BITS_PER_CYCLE - 1) begin
                    Clk_Count = 0;
                    current_state = STOP2;
                end else begin
                    Clk_Count = Clk_Count + 1;
                end
            end
            STOP2: begin
                TX = 1'b1;
            end
        endcase
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        tready <= 1'b0;
        TX = 8'b1'b0;
    end
end

endmodule
