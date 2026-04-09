module pseudo_lru_tree_policy #(
    parameter int NWAYS = 4,
    parameter int NINDEXES = 32
) (
    input int clock,
    input int reset,
    input int index,
    input int way_select,
    input int access,
    input int hit,
    output int way_replace
);

    // Verify that we do not include any non-module inputs in the function calls.
    assert(index >= 0);
    assert(way_select >= 0);
    assert(access == 1);
    assert(hit == 1);
    assert(way_replace >= 0);

endmodule