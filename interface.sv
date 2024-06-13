interface sync_fifo #(parameter width = 8, parameter depth = 8) (input clk);
  logic wd_en_i, rd_en_i, empty_o, full_o, rst_n;
  logic [width-1:0] data_i, data_o;

  modport dut(input clk, wd_en_i, rd_en_i, rst_n, data_i,
              output data_o, empty_o, full_o);
  modport tb(input data_o, empty_o, full_o, clk,
             output wd_en_i, rd_en_i, rst_n, data_i);

  // Task to perform push operation
  task push(input logic [width-1:0] wr_data);
    @(posedge clk or negedge rst_n)
    if (!full_o) begin
      data_i = wr_data;
      wd_en_i = 1;
      #5 $display("data = %h data pushed in fifo", data_i);
    end else
      $display("error: FIFO is full");
  endtask

  // Task to perform pop operation
  task pop(output logic [width-1:0] rd_data); 
    @(posedge clk or negedge rst_n)
    if (!empty_o) begin
      rd_data = data_o;
      rd_en_i = 1;
      #5 $display("data = %h data popped from fifo", rd_data);
    end else
      $display("error: FIFO is empty");
  endtask
endinterface

// Module using the sync_fifo interface
module sync_fifo #(parameter width = 8, parameter depth = 8) (sync_fifo fifo_if);
  logic [width-1:0] memory [depth-1:0];
  parameter ptr_width = $clog2(depth);
  logic [ptr_width-1:0] rd_ptr, wr_ptr;
  logic wrap_around;

  always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
    if (!fifo_if.rst_n) begin
      rd_ptr <= 0;
      wr_ptr <= 0;
    end else begin
      // Write operation
      if (fifo_if.wd_en_i && !fifo_if.full_o) begin
        memory[wr_ptr] <= fifo_if.data_i;
        wr_ptr <= wr_ptr + 1;
      end
      // Read operation
      if (fifo_if.rd_en_i && !fifo_if.empty_o) begin
        rd_ptr <= rd_ptr + 1;
      end
    end
  end

  // Logic for wraparound condition
  assign fifo_if.data_o = memory[rd_ptr];
  assign wrap_around = rd_ptr[ptr_width-1] ^ wr_ptr[ptr_width-1];
  assign fifo_if.empty_o = (rd_ptr == wr_ptr);
  assign fifo_if.full_o = (wrap_around && (rd_ptr[ptr_width-2:0] == wr_ptr[ptr_width-2:0]));

endmodule
//////////////////////////////////////////////////////////
//testbench 


module tb_toplevel #(parameter width = 8,parameter depth = 8)();

  logic clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  my_fifo #(width, depth) intf(clk);
  
  fifo #(width, depth) dut (intf);
 
  test1 t1(intf); 
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars();
    
    #1000 $finish;
  end

endmodule


program test1 #(parameter width = 8, depth = 8)(sync_fifo fifo_if);
  
  logic [width - 1 : 0] data_i, data_o;
 
  //program block terminates the entire simulation after it gets executed
  
  initial begin
    fifo_if.rst_n = 0;
    
    #10 fifo_if.rst_n = 1;
    
    fifo_if.wr_en_i = 0;
    fifo_if.rd_en_i = 0;
   	
    repeat(10) begin
      
      data_in = $urandom;
      fifo_if.push(data_i);
    end
    
    fifo_if.wr_en_i = 0;

      
    repeat(10) begin
      
      fifo_if.pop(data_o);
      
    end
     
    fifo_if.rd_en_i = 0;

  end
  
  //test2 simultaneous push and pop from fifo
  
  initial begin
    
    #200;
  
  fork 
    
    begin
      
      repeat(10) begin
      
      data_in = $urandom;
      fifo_if.push(data_i);
        
    	end
    
    fifo_if.wr_en_i = 0;
      
    end
    
    begin
      #10;
      repeat(10) begin
      
      fifo_if.pop(data_o);
      
    end
     
    fifo_if.rd_en_i = 0;
      
      
    end
    
    
  join
  end 
endprogram
