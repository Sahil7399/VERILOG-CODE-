
// Code your design here
module queue #(parameter WIDTH = 8, DEPTH = 16) (
    input logic clk,
    input logic rst_n,
    input logic enq,
    input logic deq,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

    // Internal storage for the queue
    logic [WIDTH-1:0] queue [0:DEPTH-1];
    logic [$clog2(DEPTH+1)-1:0] head, tail;
    logic [$clog2(DEPTH+1):0] count;

    // Enqueue operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            head <= 0;
            tail <= 0;
            count <= 0;
            empty <= 1;
            full <= 0;
        end else begin
            if (enq && !full) begin
                queue[tail] <= data_in;
                tail <= (tail + 1) % DEPTH;
                count <= count + 1;
            end
            if (deq && !empty) begin
                data_out <= queue[head];
                head <= (head + 1) % DEPTH;
                count <= count - 1;
            end
            // Update empty and full flags
            empty <= (count == 0);
            full <= (count == DEPTH);
        end
    end

endmodule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Code your testbench here
// or browse Examples
module tb_queue;

    parameter WIDTH = 8;
    parameter DEPTH = 16;

    logic clk;
    logic rst_n;
    logic enq;
    logic deq;
    logic [WIDTH-1:0] data_in;
    logic [WIDTH-1:0] data_out;
    logic full;
    logic empty;

    // Instantiate the queue
    queue #(.WIDTH(WIDTH), .DEPTH(DEPTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enq(enq),
        .deq(deq),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize VCD file for waveform viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_queue);

        clk = 0;
        rst_n = 0;
        enq = 0;
        deq = 0;
        data_in = 0;

        // Reset the system
        #10 rst_n = 1;

        // Enqueue some data
        #10 enq = 1; data_in = 8'hAA;
        #10 enq = 0;

        #10 enq = 1; data_in = 8'hBB;
        #10 enq = 0;

        #10 enq = 1; data_in = 8'hCC;
        #10 enq = 0;

        // Dequeue the data
        #10 deq = 1;
        #10 deq = 0;

        #10 deq = 1;
        #10 deq = 0;

        #10 deq = 1;
        #10 deq = 0;

        // Check empty condition
        #10 if (empty) $display("Queue is empty");

        // End of test
        #20 $finish;
    end

endmodule
