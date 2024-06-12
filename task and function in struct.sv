module tb_function_task_in_SV();
  
  typedef struct{ 
    string name;
    string roll_no;
    int marks;
  } student;
  int A,B,C;
  bit a,b,c,d;
  student s;
  function student create_student(string name, roll_no, int marks);
    student s1;
    s1.name = name;
    s1.roll_no = roll_no;
    s1.marks = marks;
    return s1;
  endfunction
  function int sum1 (int A = 8, B = 9);
    
    sum1 = A + B;
    return sum1;
    
  endfunction
  
  
  function automatic void sum2 (int A,int B, ref int C);
    
    C = A + B;
    
    return;
    
  endfunction
  
  function void example ( output bit a, inout bit b, input bit in1, input bit in2);
    
    a = c & d;
    b = c & d | !b;
    
  endfunction
  
  task task_ex (int A=55, int B=60);
    
    if(A+B > 100) begin
      $display("sum is greater than 100");
      return;
    end
    
    $display("sum is less than 100");
    
  endtask
  initial begin
    s = create_student("Alok", "2020UEC2120",85);
    $display("Student s = %p",s);
    A = 10;
    B = 25;
    $display("sum %0d + %0d = %0d",A,B,sum1(A,B));
    $display("sum with default values = %0d",sum1());
    task_ex(A,B);
    sum2(A,B,C);
    $display("C after sum : %0d",C);
    c = 1;
    d = 1;
    b = 0;
    example(a,b,in1,in2);
    $display("Funtion with inout and output %b %b",a,b);   
  end 
 
endmodule
