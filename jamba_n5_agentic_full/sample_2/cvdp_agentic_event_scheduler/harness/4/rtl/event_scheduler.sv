clear_signals;
    wait_for_trigger();
    $display("TC10 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC11: Testing with an empty queue");
    clear_signals;
    event_id    = 4'd12;
    timestamp   = current_time + 30;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC11 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    do_reset();
    $display("\nTC12: Testing with maximum events");
    clear_signals;
    for (i=0; i<16; i = i + 1) begin
      event_id   = 4'd i;
      timestamp  = current_time + 40;
      priority_in = 4'd i+2;
      add_event   = 1;
    end
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC12 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    do_reset();
    $display("\nTC13: Testing with repeated events and errors");
    clear_signals;
    event_id    = 4'd13;
    timestamp   = current_time + 50;
    priority_in = 4'd4;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd14;
    timestamp   = current_time + 50;
    priority_in = 4'd4;
    add_event   = 1;
    #10;
    clear_signals;
    repeat (2) #10;
    $display("TC13 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    do_reset();
    $display("\nTC14: Testing with a full FIFO and buffer");
    clear_signals;
    event_id    = 4'd15;
    timestamp   = current_time + 60;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd16;
    timestamp   = current_time + 60;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC14 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC15: Testing with a sudden burst of events");
    clear_signals;
    event_id    = 4'd17;
    timestamp   = current_time + 70;
    priority_in = 4'd4;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd18;
    timestamp   = current_time + 70;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC15 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC16: Testing with a long continuous data stream");
    clear_signals;
    event_id    = 4'd19;
    timestamp   = current_time + 80;
    priority_in = 4'd4;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd20;
    timestamp   = current_time + 80;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC16 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC17: Testing with a constant maximum pixel data feed");
    clear_signals;
    event_id    = 4'd21;
    timestamp   = current_time + 90;
    priority_in = 4'd4;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd22;
    timestamp   = current_time + 90;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC17 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC18: Testing with a FIFO preload and monitor");
    clear_signals;
    event_id    = 4'd23;
    timestamp   = current_time + 100;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd24;
    timestamp   = current_time + 100;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC18 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC19: Testing with a sudden burst of pixel data");
    clear_signals;
    event_id    = 4'd25;
    timestamp   = current_time + 110;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd26;
    timestamp   = current_time + 110;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC19 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC20: Testing with a sudden burst of pixel data (255 values)");
    clear_signals;
    event_id    = 4'd27;
    timestamp   = current_time + 120;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd28;
    timestamp   = current_time + 120;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC20 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC21: Testing with FIFO backpressure");
    clear_signals;
    event_id    = 4'd29;
    timestamp   = current_time + 130;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd30;
    timestamp   = current_time + 130;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC21 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC22: Testing with extended random pixel data");
    clear_signals;
    event_id    = 4'd31;
    timestamp   = current_time + 140;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd32;
    timestamp   = current_time + 140;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC22 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC23: Testing with FIFO preload and monitor");
    clear_signals;
    event_id    = 4'd33;
    timestamp   = current_time + 150;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd34;
    timestamp   = current_time + 150;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC23 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC24: Testing with sudden burst of pixel data (255 values)");
    clear_signals;
    event_id    = 4'd35;
    timestamp   = current_time + 160;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd36;
    timestamp   = current_time + 160;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC24 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC25: Testing with FIFO preload and monitor");
    clear_signals;
    event_id    = 4'd37;
    timestamp   = current_time + 170;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;
    event_id    = 4'd38;
    timestamp   = current_time + 170;
    priority_in = 4'd6;
    add_event   = 1;
    #10;
    clear_signals;