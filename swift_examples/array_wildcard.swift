type file;

app (file t) echo_wildcard (string s[]) {
    # Can replace * with 0, 1, 2...
    echo s[*] s[0] stdout=filename(t);
}

# Shorthand for simple_file_mapper
file hw <"array_wildcard.out">;

string greetings[] = ["how","are","you"];
hw = echo_wildcard(greetings);	
