class async_filo extends uvm_component #(
    int DATA_WIDTH,
    int DEPTH
);

    // ports
    input w_clk;
    input w_rst;
    input push;
    input r_clk;
    input r_rst;
    input pop;
    output [DATA_WIDTH-1:0] w_data;
    output wire r_data;
    output wire r_empty;
    output wire w_full;

    // internal state
    integer counter;
    logic empty, full;
    logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
    logic [DATA_WIDTH-1:0] w_ptr, r_ptr;

    // helper functions for Gray code
    function new(string name, int data_width, int depth);
        super.new(name, data_width, depth);
        counter = 0;
        empty = 1;
        full = 0;
        w_ptr = 0;
        r_ptr = 0;
        mem = {};
    endfunction

    task run_simulation();
        // simulation code omitted for brevity
    endtask

    task push_data(input [DATA_WIDTH-1:0] data_in);
        begin
            if (!full) begin
                push = 1;
                w_data = data_in;
                assert(counter < DEPTH);
                counter = counter + 1;
                full = 1;
                @(posedge w_clk);
            end else
                $display("Cannot Push, FILO is Full.");
        end
    endtask

    task pop_data();
        reg [DATA_WIDTH-1:0] expected_data;
        begin
            if (!empty) begin
                rd_data = pushed_data[counter-1];
                pop = 1;
                full = 0;
                @(posedge r_clk);
                pop = 0;
            end else
                $display("Cannot Pop, FILO is Empty.");
        end
    endtask

    task check_full();
        if (full) begin
            w_full = 1;
        end else
            w_full = 0;
    endtask

    task check_empty();
        if (empty) begin
            r_empty = 1;
        end else
            r_empty = 0;
    endtask

endclass
