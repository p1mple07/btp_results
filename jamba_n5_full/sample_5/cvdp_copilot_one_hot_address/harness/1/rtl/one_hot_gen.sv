module one_hot_gen #(
    parameter NS_A = 'd8,
    parameter NS_B = 'd4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [1:0]           i_config,
    input  logic                 i_start,
    input  logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot
);

    // -- State machine for one‑hot encoding
    localparam IDLE    = 2'd0;
    localparam REGION_A = 2'd1;
    localparam REGION_B = 2'd2;
    reg                   state_ff    = IDLE;
    reg                   region_sel = 1'd0;

    // -- Internal registers
    logic [NS_A-1:0] region_A_ff, region_A_nx;
    logic [NS_B-1:0] region_B_ff, region_B_nx;
    logic                  A_to_B, B_to_A, only_A, only_B;

begin
    // ------------------------------------------------------------------
    //  Clock & async reset interface
    // ------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_async_n) begin
        if (~rst_async_n) begin
            state_ff <= IDLE;
            region_A_ff <= {NS_A{1'b0}};
            region_B_ff <= {NS_B{1'b0}};
        end else begin
            o_ready <= (state_ff == IDLE);
            state_ff <= state_ff;
            region_A_ff <= region_A_nx;
            region_B_ff <= region_B_nx;
        end
    end

    // ------------------------------------------------------------------
    //  Drive region flags
    // ------------------------------------------------------------------
    always_comb begin
        case (state_ff)
            IDLE: begin
                if (i_start) begin
                    region_A_nx[NS_A] = (~i_config[0]);
                    region_B_nx[NS_B] = (i_config[0]);
                end else begin
                    region_A_nx[NS_A] = 1'b0;
                    region_B_nx[NS_B] = 1'b0;
                end

                region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
                region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
            end

            REGION_A: begin
                region_A_nx = region_A_ff >> 1;

                if (region_A_ff[0]) begin
                    region_B_nx[NS_B] = A_to_B;
                end else begin
                    region_B_nx[NS_B] = 1'b0;
                end
                region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
            end

            REGION_B: begin
                if (region_B_ff[0]) begin
                    region_A_nx[NS_A] = B_to_A;
                end else begin
                    region_A_nx[NS_A] = 1'b0;
                end
                region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};

                region_B_nx = region_B_ff >> 1;
            end

            default: begin
                region_A_nx = {NS_A{1'b0}};
                region_B_nx = {NS_B{1'b0}};
            end
        endcase
    end

    // ------------------------------------------------------------------
    //  Output mapping
    // ------------------------------------------------------------------
    always_comb begin
        o_address_one_hot = {region_A_ff, region_B_ff};
    end

    // ------------------------------------------------------------------
    //  Reset handling
    // ------------------------------------------------------------------
    always_comb begin
        if (~rst_async_n) begin
            o_ready <= 1;
            state_ff <= IDLE;
            region_A_ff <= {NS_A{1'b0}};
            region_B_ff <= {NS_B{1'b0}};
        end else begin
            o_ready <= (state_ff == IDLE);
            state_ff <= state_ff;
            region_A_ff <= region_A_nx;
            region_B_ff <= region_B_nx;
        end
    end

endmodule
