clear_signals;
    wait_for_trigger();
    $display("TC10 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC11: Adding event ID=12 and trying to add it again immediately");
    clear_signals;
    event_id    = 4'd12;
    timestamp   = current_time + 20;
    priority_in = 4'd3;
    add_event   = 1;
    #10;
    clear_signals;
    repeat (2) #10;
    $display("TC11 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC12: Adding event ID=13 with a very high timestamp");
    clear_signals;
    event_id    = 4'd13;
    timestamp   = current_time + 200000000;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC12 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC13: Adding event ID=14 and then modifying its timestamp and priority");
    clear_signals;
    event_id    = 4'd14;
    timestamp   = current_time + 200000000;
    priority_in = 4'd1;
    add_event   = 1;
    #10;
    clear_signals;
    event_id       = 4'd14;
    new_timestamp  = 16'd200;
    new_priority   = 4'd6;
    modify_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC13 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC14: Adding event ID=15 and checking its event_triggered status after 5 cycles");
    clear_signals;
    event_id    = 4'd15;
    timestamp   = current_time + 200000000;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC14 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC15: Testing with no events for 10 cycles");
    clear_signals;
    repeat (10) #10;
    $display("TC15 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC16: Testing with a long duration event");
    clear_signals;
    event_id    = 4'd16;
    timestamp   = current_time + 200000000;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC16 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC17: Testing with a short duration event");
    clear_signals;
    event_id    = 4'd17;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC17 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC18: Testing with a high priority event");
    clear_signals;
    event_id    = 4'd18;
    timestamp   = current_time + 10;
    priority_in = 4'd3;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC18 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC19: Testing with a recurring event after 5 cycles");
    clear_signals;
    event_id    = 4'd19;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    recurring_event = 1;
    recurring_interval = 10;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC19 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC20: Testing with a recurring event with interval");
    clear_signals;
    event_id    = 4'd20;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    recurring_event = 1;
    recurring_interval = 100;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC20 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC21: Testing with an event that triggers multiple times");
    clear_signals;
    event_id    = 4'd21;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    recurring_event = 1;
    recurring_interval = 20;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC21 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC22: Testing with a long chain of events");
    clear_signals;
    event_id    = 4'd22;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC22 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC23: Testing with a nested event");
    clear_signals;
    event_id    = 4'd23;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC23 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC24: Testing with a nested event that recurses");
    clear_signals;
    event_id    = 4'd24;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    recurring_event = 1;
    recurring_interval = 10;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC24 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC25: Testing with a complex event tree");
    clear_signals;
    event_id    = 4'd25;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC25 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC26: Testing with a complex event with a high priority");
    clear_signals;
    event_id    = 4'd26;
    timestamp   = current_time + 10;
    priority_in = 4'd3;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC26 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC27: Testing with a complex event with a low priority");
    clear_signals;
    event_id    = 4'd27;
    timestamp   = current_time + 10;
    priority_in = 4'd1;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC27 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);

    
    do_reset();
    $display("\nTC28: Testing with a complex event that triggers multiple times");
    clear_signals;
    event_id    = 4'd28;
    timestamp   = current_time + 10;
    priority_in = 4'd2;
    recurring_event = 1;
    recurring_interval = 20;
    add_event   = 1;
    #10;
    clear_signals;
    wait_for_trigger();
    $display("TC28 Outputs: event_triggered=%0d, triggered_event_id=%0d, error=%0d, current_time=%0d, log_event_time=%0d, log_event_id=%0d",
             event_triggered, triggered_event_id, error, current_time, log_event_time, log_event_id);