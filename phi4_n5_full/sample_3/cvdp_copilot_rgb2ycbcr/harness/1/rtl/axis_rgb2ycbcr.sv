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
    // FIFO Buffer (Circular FIFO)
    // -----------------------------
    reg [15:0] fifo_data [0:FIFO_DEPTH-1];
    reg        fifo_tlast [0:FIFO_DEPTH-1];
    reg        fifo_tuser [0:FIFO_DEPTH-1];

    reg [3:0]  write_ptr, read_ptr; // 4-bit pointers for FIFO
    reg        full;
    wire       empty;

    // -----------------------------
    // Intermediate Registers for RGB and YCbCr Conversion
    // -----------------------------
    reg [7:0] r, g, b;
    reg [7:0] y_reg, cb_reg, cr_reg;

    // Combined always block for RGB extraction, conversion, FIFO write, and FIFO read.
    // This ensures that the conversion registers are used in the same cycle as the FIFO write,
    // and that the FIFO pointers are updated synchronously.
    always @(posedge aclk) begin
        if (!aresetn) begin
            // Reset all registers and pointers
            r          <= 8'd0;
            g          <= 8'd0;
            b          <= 8'd0;
            y_reg      <= 8'd0;
            cb_reg     <= 8'd0;
            cr_reg     <= 8'd0;
            write_ptr  <= 0;
            read_ptr   <= 0;
            full       <= 0;
        end else begin
            // -----------------------------
            // RGB Extraction and YCbCr Conversion
            // -----------------------------
            if (s_axis_tvalid) begin
                // Extract RGB values (expanding bit-width)
                r <= {s_axis_tdata[15:11], 3'b0}; // 5-bit to 8-bit
                g <= {s_axis_tdata[10:5],  2'b0}; // 6-bit to 8-bit
                b <= {s_axis_tdata[4:0],   3'b0}; // 5-bit to 8-bit

                // Compute Y, Cb, and Cr values
                y_reg  <= (( 77 * r + 150 * g +  29 * b) >> 8) + 16;
                cb_reg <= ((-43 * r - 85 * g + 128 * b) >> 8) + 128;
                cr_reg <= ((128 * r - 107 * g - 21 * b) >> 8) + 128;
            end

            // -----------------------------
            // FIFO Write Operation
            // -----------------------------
            // Only write when there is valid input and the FIFO is not full.
            if (s_axis_tvalid && !full) begin
                fifo_data[write_ptr]   <= {y_reg[7:3], cb_reg[7:2], cr_reg[7:3]}; // Pack YCbCr into 16 bits
                fifo_tlast[write_ptr]  <= s_axis_tlast;
                fifo_tuser[write_ptr]  <= s_axis_tuser;
                // Update write pointer with wrap-around
                if (write_ptr == FIFO_DEPTH - 1)
                    write_ptr <= 0;
                else
                    write_ptr <= write_ptr + 1;
                // Set full flag: FIFO is full if the next write position equals the read pointer.
                full <= ((write_ptr + 1) % FIFO_DEPTH == read_ptr);
            end

            // -----------------------------
            // FIFO Read Operation
            // -----------------------------
            // Only read when there is data (i.e. FIFO is not empty) and the master is ready.
            if (!empty && m_axis_tready) begin
                // Update read pointer with wrap-around
                if (read_ptr == FIFO_DEPTH - 1)
                    read_ptr <= 0;
                else
                    read_ptr <= read_ptr + 1;
            end
        end
    end

    // -----------------------------
    // FIFO Status Flags
    // -----------------------------
    assign empty = (write_ptr == read_ptr);

    // -----------------------------
    // AXI-Stream Output Signals
    // -----------------------------
    assign s_axis_tready = !full; // Accept data only when FIFO is not full
    assign m_axis_tvalid = !empty; // Transmit data only when FIFO has data
    assign m_axis_tdata  = fifo_data[read_ptr];
    assign m_axis_tlast  = fifo_tlast[read_ptr];
    assign m_axis_tuser  = fifo_tuser[read_ptr];

endmodule