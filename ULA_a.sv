module ULA_a (
    input [5:0] A, B,
    input Reset, Sel_mode,
    input [2:0] Mode,
    output logic [5:0] ULA,
    output logic carry_out, Zero
);

    logic [6:0] temp_result;
    logic overflow_signed;

    always @(*) begin
        if (Reset) begin
            ULA = 6'b0;
            carry_out = 1'b0;
            Zero = 1'b1;
        end else begin
            carry_out = 1'b0;
            temp_result = 7'b0;
            
            case ({Sel_mode, Mode})
                // Aritméticas
                4'b0000: temp_result = {1'b0, A} + {1'b0, B};   // A+B
					 4'b0001: temp_result = {1'b0, A} - {1'b0, B};   // A-B
					 4'b0010: temp_result = {1'b0, A} + {1'b0, ~B};  // A+~B
					 4'b0011: temp_result = {1'b0, A} - {1'b0, ~B};  // A-~B
					 4'b0100: temp_result = {1'b0, A} + 7'd1;        // A+1
					 4'b0101: temp_result = {1'b0, A} - 7'd1;        // A-1
					 4'b0110: temp_result = {1'b0, B} + 7'd1;        // B+1
					 4'b0111: temp_result = {1'b0, B} - 7'd1;        // B-1
                
                // Lógicas
                4'b1000: ULA = A & B;
                4'b1001: ULA = ~A;
                4'b1010: ULA = ~B;
                4'b1011: ULA = A | B;
                4'b1100: ULA = A ^ B;
                4'b1101: ULA = ~(A & B);
                4'b1110: ULA = A;
                4'b1111: ULA = B;
                default: ULA = 6'b0;
            endcase
            
            // Atribui resultado para operações aritméticas
            if ({Sel_mode, Mode} < 4'b1000) 
                ULA = temp_result[5:0];
            
            // Detecção de overflow signed (apenas para soma/subtração)
            overflow_signed = (A[5] == B[5]) && (ULA[5] != A[5]);
            
            // Seleção do carry_out
            if ({Sel_mode, Mode} == 4'b0000 || // A+B
					 {Sel_mode, Mode} == 4'b0001 || // A-B
					 {Sel_mode, Mode} == 4'b0010 || // A+~B
					 {Sel_mode, Mode} == 4'b0011)   // A-~B
					 carry_out = overflow_signed;   // Soma/subtração → overflow signed
				else if ({Sel_mode, Mode} == 4'b0100 || // A+1
							{Sel_mode, Mode} == 4'b0101 || // A-1
							{Sel_mode, Mode} == 4'b0110 || // B+1
							{Sel_mode, Mode} == 4'b0111)   // B-1
					 carry_out = temp_result[6];   // Incremento/decremento → carry unsigned
            
            Zero = (ULA == 6'b0);
        end
    end
endmodule
