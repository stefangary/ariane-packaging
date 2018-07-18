type file;

app (file o) echo_app_wrap (string s)
{ 
   echo s stdout=filename(o); 
}

#file hello_out_file <single_file_mapper;file="hello.out">;
file hello_out_file <"hello.out">;
hello_out_file = echo_app_wrap("hi");
