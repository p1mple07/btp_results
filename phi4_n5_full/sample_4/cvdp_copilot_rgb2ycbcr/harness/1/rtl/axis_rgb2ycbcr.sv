module axis_rgb2ycbcr #(
    parameter PIXEL_WIDTH = 16,
    parameter FIFO_DEPTH  = 16
)(
    input  wire            aclk,
    input  wire            aresetn,

    // AXI Stream Slave Interface (Input)
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    output wire            s_axis_tready,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,

    // AXI Stream Master Interface (Output)
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    input  wire            m_axis_tready,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser
);

    // -----------------------------
    // FIFO Buffer (Circular Buffer)
    // -----------------------------
    reg [15:0] fifo_data [0:FIFO_DEPTH-1];
    reg        fifo_tlast [0:FIFO_DEPTH-1];
    reg        fifo_tuser [0:FIFO_DEPTH-1];

    reg [3:0]  write_ptr, read_ptr;
    reg        full;
    wire       empty;

    // FIFO control signals
    wire       fifo_write = s_axis_tvalid && !full;
    wire       fifo_read  = !empty && m_axis_tready;

    // -----------------------------
    // Combined RGB Extraction, Conversion, and FIFO Write
    // (Fix: Combine conversion and FIFO write to ensure new YCbCr values are used)
    // -----------------------------
    reg [7:0] r, g, b;
    reg [7:0] y_reg, cb_reg, cr_reg;
    always @(posedge aclk) begin
        if (!aresetn) begin
            r      <= 8'd0;
            g      <= 8'd0;
            b      <= 8'd0;
            y_reg  <= 8'd0;
            cb_reg <= 8'd0;
            cr_reg <= 8'd0;
            write_ptr <= 4'd0;
            full      <= 1'b0;
        end else if (fifo_write) begin
            // RGB Extraction
            r <= {s_axis_tdata[15:11], 3'b0}; // 5-bit to 8-bit
            g <= {s_axis_tdata[10:5],  2'b0}; // 6-bit to 8-bit
            b <= {s_axis_tdata[4:0],   3'b0}; // 5-bit to 8-bit

            // RGB to YCbCr Conversion
            y_reg  <= ((77 * r + 150 * g + 29 * b) >> 8) + 16;
            cb_reg <= ((-43 * r - 85 * g + 128 * b) >> 8) + 128;
            cr_reg <= ((128 * r - 107 * g - 21 * b) >> 8) + 128;

            // Write to FIFO using the newly computed conversion values
            fifo_data[write_ptr] <= {y_reg[7:3], cb_reg[7:2], cr_reg[7:3]};
            fifo_tlast[write_ptr] <= s_axis_tlast;
            fifo_tuser[write_ptr] <= s_axis_tuser;
            write_ptr <= write_ptr + 1;
            full      <= (write_ptr == FIFO_DEPTH-1);
        end
    end

    // -----------------------------
    // FIFO Buffer Read
    // -----------------------------
    always @(posedge aclk) begin
        if (!aresetn)
            read_ptr <= 4'd0;
        else if (fifo_read)
            read_ptr <= read_ptr + 1;
    end

    // Use circular buffer arithmetic to compute FIFO empty status
    assign empty = ((write_ptr - read_ptr + FIFO_DEPTH) % FIFO_DEPTH) == 0;

    // -----------------------------
    // AXI-Stream Output Signals
    // -----------------------------
    assign s_axis_tready = !full;  // Accept data only if FIFO not full
    assign m_axis_tvalid = !empty; // Transmit only if FIFO has data
    assign m_axis_tdata  = fifo_data[read_ptr];
    assign m_axis_tlast  = fifo_tlast[read_ptr];
    assign m_axis_tuser  = fifo_tuser[read_ptr];

endmodule