module gp (
    input a,
    input b,
    input cin,
    output generate,
    output propagate,
    output cout
);

    assign generate = a & b;
    assign propagate = (a ^ b) & cin;
    assign cout = generate + (propagate && cin);

endmodule
