module ULA_a (
    input [5:0] A, B,
    input Reset, Sel_mode,
    input [2:0] Mode,
    output logic [5:0] ULA,
    output logic carry_out, Zero
);

    logic [6:0] temp_result;       // Resultado temporário
    logic overflow_signed;          // Flag de overflow signed
    logic signed_overflow_add;
    logic signed_overflow_sub;

    always @(*) begin
        if (Reset) begin
            // Reset combinacional
            ULA = 6'b0;
            carry_out = 1'b0;
            Zero = 1'b1;
        end else begin
            carry_out = 1'b0;
            temp_result = 7'b0;
            case ({Sel_mode, Mode})
                // Operações Aritméticas
                4'b0000: temp_result = {1'b0, A} + {1'b0, B};   // A + B
                4'b0001: temp_result = {1'b0, A} - {1'b0, B};   // A - B
                4'b0010: temp_result = {1'b0, A} + {1'b0, ~B};  // A + ~B
                4'b0011: temp_result = {1'b0, A} - {1'b0, ~B};  // A - ~B
                4'b0100: temp_result = {1'b0, A} + 7'd1;        // A + 1
                4'b0101: temp_result = {1'b0, A} - 7'd1;        // A - 1
                4'b0110: temp_result = {1'b0, B} + 7'd1;        // B + 1
                4'b0111: temp_result = {1'b0, B} - 7'd1;        // B - 1

                // Operações Lógicas
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

            // Detecção de Overflow Signed
            signed_overflow_add = (A[5] == B[5]) && (ULA[5] != A[5]);  // Soma
            signed_overflow_sub = (A[5] != B[5]) && (ULA[5] != A[5]);  // Subtração

            case ({Sel_mode, Mode})
                4'b0000, 4'b0011: overflow_signed = signed_overflow_add; // A+B ou A-~B
                4'b0001, 4'b0010: overflow_signed = signed_overflow_sub; // A-B ou A+~B
                default: overflow_signed = 1'b0;
            endcase

            // Seleção do carry_out
            if ({Sel_mode, Mode} == 4'b0000 || {Sel_mode, Mode} == 4'b0001 ||
                {Sel_mode, Mode} == 4'b0010 || {Sel_mode, Mode} == 4'b0011)
                carry_out = overflow_signed;   // Operações aritméticas → overflow signed
            else if ({Sel_mode, Mode} == 4'b0100 || {Sel_mode, Mode} == 4'b0101 ||
                     {Sel_mode, Mode} == 4'b0110 || {Sel_mode, Mode} == 4'b0111)
                carry_out = temp_result[6];   // Incremento/decremento → carry unsigned
            Zero = (ULA == 6'b0);

        end
    end

endmodule
