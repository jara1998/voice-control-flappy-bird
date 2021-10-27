module random (clock, n);
 input logic clock;
 output logic [9:0] n;
 enum {n1,n2,n3,n4,n5,n6,n7,n8,n9,n10} ps,ns;
 
 always_comb begin
	case(ps)
		 n1 : ns = n2;
		 n2 : ns = n3;
		 n3 : ns = n4;
		 n4 : ns = n5;
		 n5 : ns = n6;
		 n6 : ns = n7;
		 n7 : ns = n8;
		 n8 : ns = n9;
		 n9 : ns = n10;
		 n10: ns = n1;
	endcase
	end
	
	
	always_comb begin
		if(ps == n1) n =70;
		else if (ps == n2) n = 35;
		else if (ps == n3) n = 40 ;
		else if (ps == n4) n = 65;
		else if (ps == n5) n = 50;
		else if (ps == n6) n = 15;
		else if (ps == n7) n = 0;
		else if (ps == n8) n = 10;
		else if (ps == n9) n = 75;
		else n = 15;
	end
 
 always_ff @ (posedge clock) begin
  ps <= ns;
 end
 
 endmodule 
 
 module tb_random();
 logic clock;
 logic [9:0] n;
 
 parameter period = 100000;
	initial begin
		clock <= 0;
		forever #(period / 2)
			clock <= ~clock;
	end
	
 random dut (clock, n);
 
 initial begin
	@(posedge clock);
	@(posedge clock);
	@(posedge clock);
	@(posedge clock);
	@(posedge clock);
	@(posedge clock);
 end
 
 endmodule 
 