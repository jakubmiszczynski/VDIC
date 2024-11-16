virtual class shape;
    protected real width = 0.0;
    protected real height = 0.0;
	protected string name = "name";
	protected string points = "points";
    protected byte old_char = "x";  
    protected byte new_char = " ";
    protected string real_points;
	
    function new(string n, real w, real h, string p);
        begin
	        name = n;
            width = w;
            height = h;
	        points = p;
        end
    endfunction
    
    pure virtual function real get_area();
    pure virtual function void print();
    
    function string replace_char(string str, byte old_char, string new_char);
        for (int i = 0; i < str.len(); i++) begin
            if (str[i] == old_char) begin
                str[i] = new_char;
            end
        end
        
       
        return str;
    endfunction
endclass