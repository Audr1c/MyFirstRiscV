module top_tb;
    reg a, b;
    wire out;

    top dut (.out(out), .in1(a), .in2(b));

    initial begin
        $dumpfile("build/simulation.vcd");
        $dumpvars(0, top_tb);
        
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        
        $finish;
    end
endmodule
