module top();
    integer fd;
    shape shape_h;
    rectangle rectangle_h;
    circle circle_h;
    triangle triangle_h;
	polygon polygon_h;
    string command;	

	
    initial begin
	    command = "python script.py";
    	$system(command);
	    
        fd = $fopen("./data_in.txt", "r");
        if (!fd) $fatal(1, "Can't access file.");
        while (!$feof(fd)) begin
            string shape;
	        string points;
            automatic real w, h;
            void'($fscanf(fd, "%s %f %f %s", shape, w, h, points));
                  
            shape_h = shape_factory::make_shape(shape, w, h, points);
            
            if ($cast(rectangle_h, shape_h)) shape_reporter#(rectangle)::store_shape(rectangle_h);
            else if ($cast(circle_h, shape_h)) shape_reporter#(circle)::store_shape(circle_h);
            else if ($cast(triangle_h, shape_h)) shape_reporter#(triangle)::store_shape(triangle_h);
            else if ($cast(polygon_h, shape_h)) shape_reporter#(polygon)::store_shape(polygon_h);
            else $fatal (1, {"No such shape: ", shape});
 
        end
        
        shape_reporter#(rectangle)::report_shapes();
        shape_reporter#(circle)::report_shapes();
        shape_reporter#(triangle)::report_shapes();
        shape_reporter#(polygon)::report_shapes();
        
        $finish;
    end
    
endmodule