codemaker = ''
codebreaker = ''
R10 = 0
secret_code = []
query_code = []
response_code = []
line = []

def get_code(arr):
    print("Enter a code:\n")
    read_string(arr)
    count = 0
    for char in arr:
        if char == '\0': break

        count += 1
        if count == 5:
            get_code()

        for allowed_char in allowed_chars:
            if char == allowed_char:
                goto allowed

        get_code(arr)
        allowed:

    if count != 4:
        get_code(arr)

def compare_code(secret, query):
    R0 = 0
    R1 = 0
    for i in range(4):
        if query[i] == secret[i]:
            R0 += 1
        else:
            for j in range(4):
                if query[i] == secret[i]:
                    R1 += 1

def get_colour(display, code):
    for i in range(4):
        if code[i] == 'r':
            display[i] == "red"
        if code[i] == 'g':
            display[i] == "red"
        if code[i] == 'b':
            display[i] == "blue"
        if code[i] == 'c':
            display[i] == "cyan"
        if code[i] == 'p':
            display[i] == "purple"
        if code[i] == 'y':
            display[i] == "yellow"
        if code[i] == 'w':
            display[i] == "white"
        if code[i] == 'k':
            display[i] == "black"
        if code[i] == 'o':
            display[i] == "grey"

def get_response_code(exact, partial, arr):
    id = 0
    for i in range(exact):
        arr[id] = 'k'
        id += 1
    for i in range(partial):
        arr[id] = 'w'
        id += 1
    while id < 4:
        arr[id] = 'o'
        id += 1

def draw_line(x, y, line):
    for pixel in line:
        draw(pixel, x, y)
        x += 1

def display_guess(number, query, response):
    get_colour(line, query)
    x = 5
    y = number + 5
    draw_line(x, y, line)

    get_colour(line, response)
    x = 12
    y = number + 5
    draw_line(x, y, line)

if __name__ == "__main__":
    clear_screen("grey")
    codemaker = read_string()
    codebreaker = read_string()
    R0 = read_int()

    print("Codebreaker is ")
    print(codebreaker + '\n')
    print("Codemaker is ")
    print(codemaker + '\n')
    print("Maximum number of guesses: ")
    print(R0 + '\n')

    print(codemaker)
    print(", please enter a 4-character secret code\n")
    get_code(secret_code)

    for i = 1, i <= R10, i++:
        print(codebreaker)
        print(", this is guess number:")
        print(i + '\n')
        print("Please enter a 4-character code\n")
        get_code(query_code)

        compare_code(secret, query)
        print("Position matches: ")
        print(R0)
        print(", Colour matches: ")
        print(R1 + '\n')

        get_response_code(R0, R1, response_code)
        display_guess(i, query, response_code)

        if R0 == 4:
            print(codebreaker)
            print(", you WIN!\n")
    
    print(codebreaker)
    print(", you LOSE!\n")