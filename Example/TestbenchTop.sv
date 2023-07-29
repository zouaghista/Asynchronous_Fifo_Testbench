`timescale 1ns/10ps

module testbench_top;
    parameter int sizes[][3] ='{
			'{4,8,1},
			'{8,12,1},
			'{8,16,1},
			'{32,16,1}
                       };

    genvar i;
    generate
        for(i=0; i<4;i++) begin :main_tests
                Testbench #(sizes[i][0],sizes[i][1],sizes[i][2]) test();
        end
    endgenerate
endmodule
