
interface FifoIf
#(parameter DEPTH = 8, DATA_WIDTH = 12)
(input wr_clk, rd_clk);
    bit fifo_enable;
    bit wr_rst_n;
    bit rd_rst_n;
    bit wr_en;
    bit wr_line_en;
    bit rd_en;
    bit[$clog2(DEPTH)-1:0] almost_full_limit;
    bit[$clog2(DEPTH)-1:0] almost_empty_limit;
    bit[DATA_WIDTH-1:0] wr_data;
    bit[DATA_WIDTH-1:0] wr_mask;
    bit[DATA_WIDTH-1:0] rd_data;
    bit fifo_full;
    bit fifo_empty;
    bit fifo_almost_empty;
    bit fifo_almost_full;  
    clocking cb1 @(posedge wr_clk);
        input wr_rst_n;
        input wr_en;
        input wr_line_en;
        input wr_data;
        input wr_mask;
        output fifo_full;
        output fifo_almost_full;  
    endclocking
    clocking cb2 @(posedge rd_clk);
        input rd_rst_n;
        input rd_en;
        output rd_data;
        output fifo_empty;
        output fifo_almost_empty;
  endclocking
endinterface
