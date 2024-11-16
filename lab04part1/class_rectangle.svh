class rectangle extends shape;
	
    function new(string n, real w, real h, string p);
        super.new(n, w, h, p);
    endfunction
    
    function real get_area();
        get_area = width * height; 
    endfunction
    
    function void print(); 
	    $display("This is: %s", name);
	    real_points = replace_char(points, old_char, new_char);
	    $display(real_points);
        $display("Area is: ", get_area());
	    $display("-------------------------------------------------------------");
    endfunction
    
endclass