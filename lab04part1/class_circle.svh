class circle extends shape;
    
    function new(string n, real w, real h, string p);
        super.new(n, w, h, p);
    endfunction
    
    function real get_area();
        get_area = width * 3.14; 
    endfunction
    
    function void print();
	    $display("This is: %s", name);
	    real_points = replace_char(points, old_char, new_char);
	    $display(real_points);
        $display("Area is: ", get_area());
	    $display("Radius is: %f", width);
	    $display("-------------------------------------------------------------");
    endfunction
    
endclass