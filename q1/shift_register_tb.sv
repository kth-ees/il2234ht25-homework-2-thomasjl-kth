`timescale 1ns/100ps
module shift_register_tb;

// complete here
localparam N = 5;
logic [N-1:0] parallel_in, parallel_out, test_result;
logic [N+3:0] test_quantity;
logic clk, rst_n, serial_parallel, load_enable, serial_in, serial_out;
int unsigned wrong_count;

shift_register #(N) dut (
    .clk(clk),
    .rst_n(rst_n),
    .serial_parallel(serial_parallel),
    .load_enable(load_enable),
    .serial_in(serial_in),
    .parallel_in(parallel_in),
    .parallel_out(parallel_out),
    .serial_out(serial_out)
);

initial begin // T=10ns. sample on i*10+5ns (5, 15, 25, 35)
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    
    parallel_in = '0;

    rst_n = 0;
    serial_parallel = 0;
    load_enable = 0;
    serial_in = 0; // extra 4 inputs
    
    wrong_count = 0;
    #10;

    for (int i=0;i<2**(N+4);i++) begin
        // set inputs
        test_quantity   = i;
        serial_parallel = ~test_quantity[0]; // start every cycle with a parallel load
        serial_in       = test_quantity[1]; 
        load_enable     = ~test_quantity[2]; // change load second slowest - start with load
        rst_n           = ~test_quantity[3]; // Reset slowest - start with non-reset
        parallel_in     = test_quantity[N+3:4];

        // populate test_result with the intended result
        if (!rst_n) begin
            test_result = '0;
        end
        else begin
            if (load_enable) begin
                if (serial_parallel) begin
                    test_result = parallel_in;
                end
                else begin
                    test_result = {serial_in, test_result[N-1:1]};
                end
            end else begin
                test_result = test_result; // I know I don't need to do this. It's for me to ensure I have full test coverage
            end
        end

        #10;
        // check outputs
        
        if ((test_result!=parallel_out) || (test_result[0] != serial_out)) begin
            wrong_count++;
            $display("test_quantity:%b, test_result:%b, parallel_out:%b, serial_out:%b", test_quantity, test_result, parallel_out, serial_out);
        end
    end
    $display(wrong_count);
    $stop;
end



endmodule