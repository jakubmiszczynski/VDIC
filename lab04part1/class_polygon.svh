class polygon extends shape;
    
    function new(string n, real w, string p);
        super.new(n, w, 0, p);
    endfunction
    
    function real get_area();
        get_area = 0; 
    endfunction
    
    function void print(); 
	    $display("This is: %s", name);
	    real_points = replace_char(points, old_char, new_char);
	    $display(real_points);
        $display("Area is: cant measure");
	    $display("-------------------------------------------------------------");
    endfunction
    
endclass