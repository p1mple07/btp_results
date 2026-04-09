
case (insert_phase)
    0: begin
        // Phase 0: Setup for inserting array[i]
        if (i < N) begin
            key <= array[i];
            j <= i - 1;
            insert_phase <= 1;
        end
    end
    1: begin
        // Phase 1: Shift elements to the right until the correct spot is found
        if (j >= 0 && array[j] > key) begin
            array[j+1] <= array[j];
            j <= j - 1;
        end else begin
            // We found the spot (or j < 0)
            insert_phase <= 2;
        end
    end
    2: begin
        // Phase 2: Insert the key at array[j+1]
        array[j+1] <= key;
        i <= i + 1;
        insert_phase <= 0; 
    end
