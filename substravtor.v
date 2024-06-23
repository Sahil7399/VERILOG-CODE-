 module halfsub(diff,bo,a,b);
	 input a;
	 input b;
	 output diff;
	 output bo;
	 wire w1;
	 xor(diff,a,b);
	 and(bo,w1,b);
	 endmodule
