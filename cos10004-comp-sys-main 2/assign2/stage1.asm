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
      HALT

// desc: print new line char
newline:
      MOV R0, #0xA
      STRB R0, .WriteChar
      RET

.ALIGN 4
codemaker: .BLOCK 128
codebreaker: .BLOCK 128
askmakername: .ASCIZ "Enter code maker name:\n"
askbreakername: .ASCIZ "Enter code breaker name:\n"
askmaxqueries: .ASCIZ "Enter the maximum number of queries:\n"
printmaker: .ASCIZ "Codemaker is: "
printbreaker: .ASCIZ "Codebreaker is: "
printmaxqueries: .ASCIZ "Maximum number of guesses: "
