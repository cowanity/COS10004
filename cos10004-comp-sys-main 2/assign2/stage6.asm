main:
      MOV R4, #.burlywood
      MOV R1, #.PixelScreen
      MOV R2, #0
      LDR R3, .PixelAreaSize
clearscreen:
      STR R4, [R1]                  // clear screen
      ADD R1, R1, #4
      ADD R2, R2, #1
      CMP R2, R3
      BLT clearscreen

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

      MOV R0, #secretcode           // show the hidden secret code
      MOV R1, #1
      BL displayanswer

      CMP R5, #1
      BLT readsecret                // skip drawing

      MOV R1, #.PixelScreen         // draw borders
      ADD R1, R1, #616
      MOV R2, #0
      MOV R4, #.grey
drawverticallines:
      MOV R3, R1
      STR R4, [R3]
      ADD R3, R3, #20
      STR R4, [R3]
      ADD R3, R3, #4
      STR R4, [R3]
      ADD R3, R3, #20
      STR R4, [R3]
      ADD R1, R1, #256
      ADD R2, R2, #1
      CMP R2, R5
      BLT drawverticallines

readsecret:
      MOV R4, #codemaker            // read secret code
      STR R4, .WriteString
      MOV R4, #asksecretcode
      STR R4, .WriteString
      MOV R0, #secretcode
      BL getcode

      CMP R5, #1
      BLT lose                      // skip game loop
      MOV R6, #0                    // current number of guesses
      LDR R7, codesize
loop:
      MOV R4, #codebreaker          // print number of guesses
      STR R4, .WriteString
      MOV R4, #printguessnumber
      STR R4, .WriteString
      STR R5, .WriteSignedNum
      BL newline

      MOV R0, #48                   // draw the number of guesses
      MOV R1, #.CharScreen
      ADD R0, R0, R5
      STRB R0, [R1]

      MOV R4, #askquerycode         // read query code
      STR R4, .WriteString
      MOV R0, #querycode
      BL getcode

      MOV R0, #secretcode           // count matches
      MOV R1, #querycode
      BL comparecodes

      MOV R4, #printpositionmatches // print feedback
      STR R4, .WriteString
      STR R0, .WriteSignedNum
      MOV R4, #printcolourmatches
      STR R4, .WriteString
      STR R1, .WriteSignedNum
      PUSH {R0, R1}
      BL newline
      POP {R0, R1}

      PUSH {R0, R1}
      MOV R2, R1
      MOV R1, R0
      MOV R0, #responsecode
      BL getresponsecode
      POP {R0, R1}

      PUSH {R0, R1}
      MOV R0, R6
      MOV R1, #querycode
      MOV R2, #responsecode
      BL displayguess
      POP {R0, R1}

      CMP R0, R7                    // check win
      BEQ win

      ADD R6, R6, #1
      SUB R5, R5, #1
      CMP R5, #0
      BGT loop
lose:
      MOV R4, #codebreaker
      STR R4, .WriteString
      MOV R4, #printlose
      STR R4, .WriteString
      B end
win:
      MOV R4, #codebreaker
      STR R4, .WriteString
      MOV R4, #printwin
      STR R4, .WriteString
end:
      PUSH {R0, R1}                 // show the secret code
      MOV R0, #secretcode
      MOV R1, #0
      BL displayanswer
      POP {R0, R1}
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

// desc: convert code to array of colours
// params: R0 -> arr, R1 -> code
// return: R0 -> arr of colours
getcolour:
      PUSH {R4, R5, R6, R7, R8}
      LDR R2, charsize
      LDR R3, codesize
      LDR R8, wordsize
      MOV R4, #0                    // char arr offset
      MOV R5, #0                    // colour arr offset
getcolourloop:
      LDRB R6, [R1 + R4]            // char in code

      CMP R6, #0x72                 // r
      BNE getcolourg
      MOV R7, #.red
      B getcolourstore
getcolourg:
      CMP R6, #0x67                 // g
      BNE getcolourb
      MOV R7, #.green
      B getcolourstore
getcolourb:
      CMP R6, #0x62                 // b
      BNE getcoloury
      MOV R7, #.blue
      B getcolourstore
getcoloury:      
      CMP R6, #0x79                 // y
      BNE getcolourp
      MOV R7, #.yellow
      B getcolourstore
getcolourp:
      CMP R6, #0x70                 // p
      BNE getcolourc
      MOV R7, #.purple
      B getcolourstore
getcolourc:
      CMP R6, #0x63                 // c
      BNE getcolourw
      MOV R7, #.cyan
      B getcolourstore
getcolourw:
      CMP R6, #0x77                 // w
      BNE getcolourk
      MOV R7, #.white
      B getcolourstore
getcolourk:
      CMP R6, #0x6B                 // k
      BNE getcolouro
      MOV R7, #.black
      B getcolourstore
getcolouro:
      MOV R7, #.burlywood           // no need to check last colour
getcolourstore:
      STR R7, [R0 + R5]
      ADD R5, R5, R8
      ADD R4, R4, #1
      CMP R4, R3
      BLT getcolourloop
      POP {R4, R5, R6, R7, R8}
      RET

// desc: get colour code for response
// params: R0 -> arr, R1 -> exact matches, R2 -> partial matches
// return: R0 -> arr of code
getresponsecode:
      PUSH {R4, R5, R6}
      LDR R3, charsize
      MOV R4, #0                    // offset
      LDR R6, codesize
getresponsecodeloop1:
      CMP R1, #0
      BEQ getresponsecodeloop2
      MOV R5, #0x6b
      STRB R5, [R0 + R4]          // fill with k
      ADD R4, R4, R3
      SUB R1, R1, #1
      B getresponsecodeloop1
getresponsecodeloop2:
      CMP R2, #0
      BEQ getresponsecodeloop3
      MOV R5, #0x77
      STRB R5, [R0 + R4]          // fill with w
      ADD R4, R4, R3
      SUB R2, R2, #1
      B getresponsecodeloop2
getresponsecodeloop3:
      CMP R4, R6
      BEQ getresponsecodeReturn
      MOV R5, #0x6F
      STRB R5, [R0 + R4]          // fill with o
      ADD R4, R4, R3
      B getresponsecodeloop3
getresponsecodeReturn:
      POP {R4, R5, R6}
      RET

// desc: draw a 4-pixel line of colours at (x, y)
// params: R0 -> x, R1 -> y, R2 -> arr of colours
drawline:
      PUSH {R4, R5, R6, R7, R8, R9}
      LDR R3, wordsize
      MOV R4, #0                    // offset
      MOV R5, #.PixelScreen         // pixel
      LDR R7, codesize
      MOV R8, #0                    // screen offset
      MOV R9, #0                    // index
drawlineMoveY:
      CMP R1, #0
      BEQ drawlineMoveX
      ADD R5, R5, #256               // move down by 1 row
      SUB R1, R1, #1
      B drawlineMoveY
drawlineMoveX:
      CMP R0, #0
      BEQ drawlineloop
      ADD R5, R5, R3                // move right by 1 columns
      SUB R0, R0, #1
      B drawlineMoveX
drawlineloop:
      LDR R6, [R2 + R4]
      STR R6, [R5 + R8]             // draw to screen

      ADD R8, R8, R3
      ADD R4, R4, R3
      ADD R9, R9, #1
      CMP R9, R7
      BLT drawlineloop

      POP {R4, R5, R6, R7, R8, R9}
      RET

// desc: draw a line for guess and a line for response
// params: R0 -> guess number, R1 -> query code, R2 -> response code
displayguess:
      PUSH {R0, R1, R2, LR}
      MOV R0, #line
      BL getcolour
      POP {R0, R1, R2, LR}

      PUSH {R0, R1, R2, LR}
      MOV R1, R0                    // y = guess + 2
      ADD R1, R1, #2
      MOV R0, #27                   // x = 27
      MOV R2, #line
      BL drawline
      POP {R0, R1, R2, LR}

      PUSH {R0, R1, R2, LR}
      MOV R0, #line
      MOV R1, R2
      BL getcolour
      POP {R0, R1, R2, LR}

      PUSH {R0, R1, R2, LR}
      MOV R1, R0                    // y = guess + 2
      ADD R1, R1, #2
      MOV R0, #33                   // x = 33
      MOV R2, #line
      BL drawline
      POP {R0, R1, R2, LR}
      RET

// desc: draw a line for the secret code
// params: R0 -> secret code, R1 -> should hide the code
displayanswer:
      PUSH {R4, R5, R6, R7}

      CMP R1, #1                    // should hide == true
      BEQ displayanswerfillblack

      PUSH {R0, R1, R2, LR}         // get colours from code
      MOV R1, R0
      MOV R0, #line
      BL getcolour
      POP {R0, R1, R2, LR}
      B displayanswerdraw

displayanswerfillblack:
      MOV R0, #line
      LDR R3, wordsize
      MOV R4, #0                    // offset
      LDR R5, codesize
      MOV R6, #0                    // count
displayanswerloop:
      MOV R7, #.black
      STR R7, [R0 + R4]
      ADD R4, R4, R3
      ADD R6, R6, #1
      CMP R6, R5
      BLT displayanswerloop

displayanswerdraw:
      PUSH {R0, R1, R2, LR}
      MOV R0, #27                   // x = 27
      MOV R1, #0                    // y = 0
      MOV R2, #line
      BL drawline
      POP {R0, R1, R2, LR}

      POP {R4, R5, R6, R7}
      RET

.ALIGN 4
codemaker: .BLOCK 128
codebreaker: .BLOCK 128
secretcode: .BLOCK 128
querycode: .BLOCK 128
responsecode: .BLOCK 4
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
.ALIGN 4
wordsize: 4
line: .WORD 0
      0
      0
      0
printpositionmatches: .ASCIZ "Position matches: "
printcolourmatches: .ASCIZ ", Colour matches: "
printwin: .ASCIZ ", you WIN!\n"
printlose: .ASCIZ ", you LOSE!\n"
