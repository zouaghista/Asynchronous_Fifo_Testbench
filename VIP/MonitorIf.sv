typedef struct {
  int data;
  bit enable;
} Transaction;

interface MonitorIf (input wr_clk, rd_clk);
  Transaction in;
  Transaction out;
endinterface

