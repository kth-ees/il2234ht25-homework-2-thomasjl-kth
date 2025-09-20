`timescale 1ns/100ps
module LFSR_6bit_tb;

// complete here
logic [5:0] parallel_in, parallel_out, test_result;
logic [7:0] test_quantity;
logic clk, rst_n, ser;
int unsigned wrong_count;

LFSR_6bit dut (
    .clk(clk),
    .rst_n(rst_n),
    .sel(ser),
    .parallel_in(parallel_in),
    .parallel_out(parallel_out)
);

initial begin // T=10ns. sample on i*10+5ns (5, 15, 25, 35)
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    
    parallel_in = '0;

    rst_n = 0;
    ser = 0;
    
    wrong_count = 0;
    #10;

    for (int i=0;i<2**8;i++) begin
        // set inputs
        test_quantity = i;
        ser           = test_quantity[0];  // start every cycle with a parallel load
        rst_n         = ~test_quantity[1]; // do a reset after every parallel + serial check
        parallel_in   = test_quantity[7:2];

        // populate test_result with the intended result
        if (!rst_n) begin
            test_result = '0;
        end
        else begin
            if (ser) begin
                test_result = {test_result[4:0], {test_result[5]}}; // shift all bits up by one (wrapping around)
                test_result[1] = test_result[1] ^ test_result[0]; // [1] = [0]^[5] but both inputs were just shifted up by one
                test_result[3] = test_result[3] ^ test_result[0]; // [3] = [2]^[5] but both inputs were just shifted up by one
            end
            else begin
                test_result = parallel_in;
            end
        end

        #10;
        // check outputs
        
        if (test_result!=parallel_out) begin
            wrong_count++;
            $display("test_quantity:%b, test_result:%b, parallel_out:%b", test_quantity, test_result, parallel_out);
        end
    end
    $display(wrong_count);
    $stop;
end



endmodule