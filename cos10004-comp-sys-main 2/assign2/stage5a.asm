main:
      MOV R4, #askmakername         // read maker's name
      STR R4, .WriteString
      MOV R4, #codemaker
      STR R4, .ReadString

      MOV R4, #askbreakername       // read breaker's name
      STR R4, .WriteString
      MOV R4, #codebreaker
      STR R4, .ReadString

      MOV R4, #askmaxqueries        // read max queries
      STR R4, .WriteString
      LDR R5, .InputNum

      MOV R4, #printmaker           // print maker's name
      STR R4, .WriteString
      MOV R4, #codemaker
      STR R4, .WriteString
      BL newline

      MOV R4, #printbreaker         // print breaker's name
      STR R4, .WriteString
      MOV R4, #codebreaker
      STR R4, .WriteString
      BL newline

      MOV R4, #printmaxqueries      // print max queries
      STR R4, .WriteString
      STR R5, .WriteSignedNum
      BL newline

      MOV R4, #codemaker            // read secret code
      STR R4, .WriteString
      MOV R4, #asksecretcode
      STR R4, .WriteString
      MOV R0, #secretcode
      BL getcode

      CMP R5, #1
      BLT end                       // skip game loop
loop:
      MOV R4, #codebreaker          // print number of guess
      STR R4, .WriteString
      MOV R4, #printguessnumber
      STR R4, .WriteString
      STR R5, .WriteSignedNum
      BL newline

      MOV R4, #askquerycode         // read query code
      STR R4, .WriteString
      MOV R0, #querycode
      BL getcode

      SUB R5, R5, #1
      CMP R5, #0
      BGT loop
end:
      HALT

// desc: print new line char
newline:
      MOV R0, #0xA
      STRB R0, .WriteChar
      RET

// desc: read code from user input and store it into arr
// params: R0 -> arr
// return: R0 -> arr with values
getcode:                            
      PUSH {R4, R5, R6, R7, R8, R9}
getcodemain:
      MOV R1, #askcode
      STR R1, .WriteString
      STR R0, .ReadString
      MOV R3, #0                    // offset
      MOV R4, #allowedchars
      LDR R7, charsize
      LDR R8, codesize
      LDR R9, allowedcharssize
getcodeloop:                        // for char in code
      LDRB R2, [R0 + R3]
      ADD R3, R3, R7
      CMP R2, #0                    // end of string
      BEQ getcodereturn

      CMP R3, R8                    // string length > 4
      BGT getcodemain

      MOV R5, #0                    // offset
getcodeloop2:                       // for char in allowedchars
      LDRB R6, [R4 + R5]
      CMP R2, R6
      BEQ getcodeloop               // char is allowed

      ADD R5, R5, R7
      CMP R5, R9                    // end of string
      BLT getcodeloop2
      B getcodemain                 // char is not allowed
getcodereturn:
      CMP R3, R8                    // length < 4
      BLT getcodemain
      BEQ getcodeMain
      POP {R4, R5, R6, R7, R8, R9}
      RET

// desc: compare query to secret code and return feedback 
// params: R0 -> secret array, R1 -> query array
// return: R0 -> number of exact matches, R1 -> number of colour matches
comparecodes:
      PUSH {R4, R5, R6, R7, R8, R9}
      LDR R2, charsize
      MOV R3, #0                    // exact match
      MOV R4, #0                    // partial match
      MOV R5, #0                    // offset
      LDR R9, codesize
comparecodesloop:
      LDRB R6, [R0 + R5]            // char in secret
      LDRB R7, [R1 + R5]            // char in query
      CMP R6, R7                    // exact match
      BNE comparecodeselse
      ADD R3, R3, #1
      B comparecodesendif
comparecodeselse:
      MOV R8, #0                    // offset
comparecodesloop2:
      LDRB R6, [R0 + R8]            // char in secret
      CMP R6, R7                    // partial match
      BNE comparecodesloop2else
      ADD R4, R4, #1
      B comparecodesendif
comparecodesloop2else:
      ADD R8, R8, R2
      CMP R8, R9
      BLT comparecodesloop2
comparecodesendif:
      ADD R5, R5, R2
      CMP R5, R9
      BLT comparecodesloop

      MOV R0, R3
      MOV R1, R4
      POP {R4, R5, R6, R7, R8, R9}
      RET

.ALIGN 4
codemaker: .BLOCK 128
codebreaker: .BLOCK 128
secretcode: .BLOCK 128
querycode: .BLOCK 128
askmakername: .ASCIZ "Enter code maker name:\n"
askbreakername: .ASCIZ "Enter code breaker name:\n"
askmaxqueries: .ASCIZ "Enter the maximum number of queries:\n"
printmaker: .ASCIZ "Codemaker is: "
printbreaker: .ASCIZ "Codebreaker is: "
printmaxqueries: .ASCIZ "Maximum number of guesses: "
asksecretcode: .ASCIZ ", please enter a 4-character secret code\n"
printguessnumber: .ASCIZ ", this is guess number:"
askquerycode: .ASCIZ "Please enter a 4-character code\n"
askcode: .ASCIZ "Enter a code:\n"
.ALIGN 4
charsize: 1
codesize: 4
allowedcharssize: 6
allowedchars: .ASCIZ "rgbypc"
