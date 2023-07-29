package SCOREBOARD;

class ScoreBoard;
  int tests = 0;
  int errors = 0;
  virtual MonitorIf Monitor;
  int ReadFifo[$];
  int WriteFifo[$];
  bit Sstarted = 0;
  bit InterruptOnError;
  function new(virtual MonitorIf Monitor);
	this.Monitor = Monitor; 
  endfunction
  task SetInterruptions(bit setting);
      InterruptOnError = setting;
  endtask
  task CompareLoop();
      forever begin
      fork
         @(posedge Monitor.wr_clk);
         @(posedge Monitor.rd_clk);
      join_any
      if(ReadFifo.size()!=0&&WriteFifo.size()!=0) begin
	  tests++;
          if(WriteFifo[0]!=WriteFifo[0]) begin
              if(InterruptOnError) begin
      	           $display("Scoreboard: Error expected $d, got $d instead",WriteFifo[0],ReadFifo[0]);
                   $display("Scoreboard: TEST FAILED");
	           $finish;
              end
              errors++;
          end
          WriteFifo.pop_front();
          ReadFifo.pop_front();
      end
      end
  endtask
  task ReadRegister();
      forever begin
          @(posedge Monitor.rd_clk);
          if(Monitor.out.enable)
                ReadFifo.push_back(Monitor.out.data);
      end
  endtask
  task WriteRegister();
      forever begin
          @(posedge Monitor.wr_clk);
          if(Monitor.in.enable)
                WriteFifo.push_back(Monitor.in.data);
      end
  endtask
  task Start();
      if(!Sstarted) begin
         Sstarted = 1;
         fork
            WriteRegister();
            ReadRegister();
            CompareLoop();
         join_none
      end
  endtask
  task GetSummery();
       $display("Scoreboard: %d of data has been checked.",tests);
       $display("Scoreboard: %d of errors were found.",errors);
       $display("Scoreboard: data corruption rate is %d", errors/tests);
       if(!errors)
           $display("Scoreboard: TEST PASSED SECCESSFULY");
       else
           $display("Scoreboard: TEST FAILED");
  endtask
endclass
endpackage
