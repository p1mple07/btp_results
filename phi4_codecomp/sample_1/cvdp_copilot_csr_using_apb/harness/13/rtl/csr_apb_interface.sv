module csr_apb_interface (
    input                    pclk,              // Clock input for synchronization
    input                    presetn,           // Active-low asynchronous reset input
    input [31:0]             paddr,             // APB address bus, 32-bit for register addressing
    input                    pselx,             // APB peripheral select signal
    input                    penable,           // APB enable signal for transactions
    input                    pwrite,            // APB write enable signal
    input [31:0]             pwdata,            // APB write data bus

    output reg               pready,            // APB ready signal, indicates end of transaction
    output reg [31:0]        prdata,            // APB read data bus
    output reg               pslverr,           // APB slave error signal

    output [1:0]             debug_state        // Debug output to monitor state
);

    // ----------------------------------------
    // Register Addresses
    // ----------------------------------------
    localparam DATA_REG       = 32'h10; // Data register
    localparam CONTROL_REG    = 32'h14; // Control register
    localparam INTERRUPT_REG  = 32'h18; // Interrupt configuration register
    localparam ISR_REG        = 32'h1C; // Interrupt status register

    // ----------------------------------------
    // State Machine States
    // ----------------------------------------
    localparam IDLE           = 2'b00; // Idle state
    localparam SETUP          = 2'b01; // Setup state
    localparam READ_STATE     = 2'b10; // Read operation state
    localparam WRITE_STATE    = 2'b11; // Write operation state

    // ----------------------------------------
    // Internal State Registers
    // ----------------------------------------
    reg [1:0]                 present_state, next_state; 

    // Signals for state transitions and outputs
    reg                       next_pready;
    reg [31:0]                next_prdata;
    reg                       next_pslverr;

    // Internal Storage Registers
    reg [9:0]                 data1, next_data1;
    reg [9:0]                 data2, next_data2;
    reg [11:0]                data_reserved, next_data_reserved;

    reg                       enable, next_enable;     
    reg                       mode, next_mode;         
    reg [29:0]                control_reserved, next_control_reserved;

    reg                       overflow_ie, next_overflow_ie; 
    reg                       sign_ie, next_sign_ie;
    reg                       parity_ie, next_parity_ie;
    reg                       zero_ie, next_zero_ie;
    reg [27:0]                interrupt_reserved, next_interrupt_reserved;

    reg                       overflow_is, next_overflow_is; 
    reg                       sign_is, next_sign_is;
    reg                       parity_is, next_parity_is;
    reg                       zero_is, next_zero_is;

    assign debug_state = present_state;
    wire write_protected = (paddr == ISR_REG);
   
    always @ (*) begin
        next_pready           = pready;
        next_prdata           = prdata;
        next_pslverr          = pslverr;

        next_data1            = data1;
        next_data2            = data2;
        next_data_reserved    = data_reserved;

        next_enable           = enable;
        next_mode             = mode;
        next_control_reserved = control_reserved;

        next_overflow_ie      = overflow_ie;
        next_sign_ie          = sign_ie;
        next_parity_ie        = parity_ie;
        next_zero_ie          = zero_ie;
        next_interrupt_reserved = interrupt_reserved;

        next_overflow_is      = overflow_is;
        next_sign_is          = sign_is;
        next_parity_is        = parity_is;
        next_zero_is          = zero_is;

        next_state            = present_state;

        case (present_state)
            IDLE: begin
                if (pselx)
                    next_state = SETUP;
            end

            SETUP: begin
                if (penable && pwrite && !write_protected)
                    next_state = WRITE_STATE;
                else if (penable && !pwrite)
                    next_state = READ_STATE;
                else if (penable && write_protected)
                    next_pslverr = 1'b1; 
            end

            READ_STATE: begin
                if (pready) begin
                    next_state = IDLE;
                    next_pready = 1'b0;
                end else begin
                    next_pready = 1'b1;
                    case (paddr)
                        DATA_REG:      next_prdata = {data_reserved, data1, data2};
                        CONTROL_REG:   next_prdata = {control_reserved, enable, mode};
                        INTERRUPT_REG: next_prdata = {interrupt_reserved, overflow_ie, sign_ie, parity_ie, zero_ie};
                        ISR_REG:       next_prdata = {28'b0, overflow_is, sign_is, parity_is, zero_is};
                        default:       next_pslverr = 1'b1; 
                    endcase
                end
            end

            WRITE_STATE: begin
                if (pready) begin
                    next_state = IDLE;
                    next_pready = 1'b0;
                end else begin
                    next_pready = 1'b1;
                    case (paddr)
                        DATA_REG: begin
                            next_data1            = pwdata[19:10];
                            next_data2            = pwdata[9:0];
                            next_data_reserved    = pwdata[31:20];
                        end
                        CONTROL_REG: begin
                            next_enable           = pwdata[1];
                            next_mode             = pwdata[0];
                            next_control_reserved = pwdata[31:2];
                        end
                        INTERRUPT_REG: begin
                            next_overflow_ie      = pwdata[3];
                            next_sign_ie          = pwdata[2];
                            next_parity_ie        = pwdata[1];
                            next_zero_ie          = pwdata[0];
                            next_interrupt_reserved = pwdata[31:4];
                          
                            next_overflow_is      = pwdata[3] ? 1'b0 : overflow_is;
                            next_sign_is          = pwdata[2] ? 1'b0 : sign_is;
                            next_parity_is        = pwdata[1] ? 1'b0 : parity_is;
                            next_zero_is          = pwdata[0] ? 1'b0 : zero_is;
                        end
                        default: next_pslverr = 1'b1; 
                    endcase
                end
            end
        endcase
    end

    always @ (posedge pclk or negedge presetn) begin
        if (!presetn) begin
            pready               <= 1'b0;
            prdata               <= 32'h0;
            pslverr              <= 1'b0;

            present_state        <= IDLE;
            data1                <= 10'd0;
            data2                <= 10'd0;
            data_reserved        <= 12'd0;

            enable               <= 1'b0;
            mode                 <= 1'b0;
            control_reserved     <= 30'd0;

            overflow_ie          <= 1'b0;
            sign_ie              <= 1'b0;
            parity_ie            <= 1'b0;
            zero_ie              <= 1'b0;
            interrupt_reserved   <= 28'd0;

            overflow_is          <= 1'b0;
            sign_is              <= 1'b0;
            parity_is            <= 1'b0;
            zero_is              <= 1'b0;
        end else begin
            present_state        <= next_state;
            pready               <= next_pready;
            prdata               <= next_prdata;
            pslverr              <= next_pslverr;

            data1                <= next_data1;
            data2                <= next_data2;
            data_reserved        <= next_data_reserved;

            enable               <= next_enable;
            mode                 <= next_mode;
            control_reserved     <= next_control_reserved;

            overflow_ie          <= next_overflow_ie;
            sign_ie              <= next_sign_ie;
            parity_ie            <= next_parity_ie;
            zero_ie              <= next_zero_ie;
            interrupt_reserved   <= next_interrupt_reserved;

            overflow_is          <= next_overflow_is;
            sign_is              <= next_sign_is;
            parity_is            <= next_parity_is;
            zero_is              <= next_zero_is;
        end
    end

endmodule
