module Projeto_1 (
	input [5:0]A, B,
	input Reset, Sel_mode,
	input [2:0]Mode,
	output logic [5:0]ULA,
	output logic carry_outp, Zero
);

	always @(*) begin
		//Valores iniciais:
		Zero = 1'b0;
		carry_outp = 1'b0;
		ULA = 6'b0;
	
		if(Reset == 1'b1) begin
			Zero = 1'b0;
			carry_outp = 1'b0;
			ULA = 6'b0;
		end else begin
			case ({Sel_mode, Mode})
				// Parte aritmética
				4'b0000: {ULA} = (A+B);
				4'b0001: {ULA} = (A-B);
				4'b0010: {ULA} = (A+(~B)+1);
				4'b0011: {ULA} = (A-(~B)-1);
				4'b0100: {ULA} = A+1;
				4'b0101: {ULA} = A-1;
				4'b0110: {ULA} = B+1;
				4'b0111: {ULA} = B-1;
				// Parte lógica
				4'b1000: {ULA} = (A&B);
				4'b1001: {ULA} = (~A);
				4'b1010: {ULA} = (~B);
				4'b1011: {ULA} = (A|B);
				4'b1100: {ULA} = (A^B);
				4'b1101: {ULA} = ~(A&B);
				4'b1110: {ULA} = (A);
				4'b1111: ULA = (B);
				default: ULA = 6'b0;
			endcase
		end
		
		//Detecta se a saída é zero
		Zero = (ULA == 6'b0);
		
		//overflow
		if((Sel_mode == 1'b0) && (Reset == 1'b0)) begin
			case(Mode)
				3'b000: carry_outp = ((A[5] == B[5]) && (ULA[5] != A[5]));
				3'b001: carry_outp = ((A[5] != B[5]) && (ULA[5] != A[5]));
				3'b010: carry_outp = ((A[5] != B[5]) && (ULA[5] != A[5]));
				3'b011: carry_outp = ((A[5] == B[5]) && (ULA[5] != A[5]));
				3'b100: carry_outp = (A == 6'b111111);
				3'b101: carry_outp = (A[0] == 1'b0);
				3'b110: carry_outp = (B == 6'b111111);
				3'b111: carry_outp = (B[0] == 1'b0);
				default: carry_outp = 1'b0;
			endcase
		end else begin
			carry_outp = 1'b0;
		end
	end
endmodule