`timescale 1ps/1ps

module fifo
#(
    parameter int WIDTH                 = 8,
    parameter int DEPTH_BITS            = 2
)
(
    input   wire                        i_clk,
    input   wire                        i_reset_n,
    input   wire[WIDTH-1:0]             i_data,
    input   wire                        i_push,
    output  wire[WIDTH-1:0]             o_data,
    input   wire                        i_pop,
    output  wire                        o_empty,
    output  wire                        o_full
);

    logic[WIDTH-1:0] data[2**DEPTH_BITS];

    logic[DEPTH_BITS:0] head, tail, head_next, tail_next;
    logic   empty, full;

    assign  head_next = head + 2'd1;
    assign  tail_next = tail + 2'd1;
    assign  empty = (head == tail);
    assign  full = ((head_next[DEPTH_BITS-1:0] == tail[DEPTH_BITS-1:0]) &
                    (head_next[DEPTH_BITS] != tail[DEPTH_BITS])) |
                   ((head_next[DEPTH_BITS-1:0] == tail_next[DEPTH_BITS-1:0]) &
                    (head_next[DEPTH_BITS] != tail_next[DEPTH_BITS]));

    always_ff @(posedge i_clk)
    begin
        if (!i_reset_n)
            head  <= '0;
        else if (i_push)
            head <= head_next;
    end

    always_ff @(posedge i_clk)
    begin
        if (!i_reset_n)
            tail  <= '0;
        else if (i_pop)
            tail <= tail_next;
    end

    generate
        genvar i;
        for (i=0 ; i<(2**DEPTH_BITS) ; i++)
        begin : g_fifo
            always_ff @(posedge i_clk)
            begin
                if (!i_reset_n)
                begin
                    data[i] <= '0;
                end
                else if (i_push & (i == head[DEPTH_BITS-1:0]))
                    data[i] <= i_data;
            end
        end
    endgenerate

/* verilator lint_off UNUSEDSIGNAL */
    logic[DEPTH_BITS-1:0] elements_in_fifo;
    assign elements_in_fifo = head[DEPTH_BITS-1:0] - tail[DEPTH_BITS-1:0];
/* verilator lint_on UNUSEDSIGNAL */

    assign  o_data = data[tail[DEPTH_BITS-1:0]];
    assign  o_empty = empty;
    assign  o_full = full;

endmodule
