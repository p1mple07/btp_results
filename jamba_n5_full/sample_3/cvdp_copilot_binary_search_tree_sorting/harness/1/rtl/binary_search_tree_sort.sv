always @(posedge clk or posedge reset) begin
    if (reset) begin
        ...
    end else begin
        case (top_state)
            IDLE: begin
                done <= 0;
                ...
            end
            BUILD_TREE: begin
                case (build_state)

                       // Insert code here to implement storing of the number to be inserted from the array, insertion of the root, and traversing the tree to find the correct position of the number to be inserted based on the node with no child.

                ...

            end
