class shape_factory;
    
    static function shape make_shape(string name, real w, real h, string points);
        rectangle rectangle_h;
        circle circle_h;
        triangle triangle_h;
	    polygon polygon_h;
        case (name)
            "rectangle": begin
                rectangle_h = new(name, w, h, points);
                make_shape = rectangle_h;
            end
            "circle": begin
                circle_h = new(name,w,h, points);
                make_shape = circle_h;
            end
            "triangle": begin
                triangle_h = new(name,w, h, points);
                make_shape = triangle_h;
            end
            "polygon": begin
                polygon_h = new(name,w, points);
                make_shape = polygon_h;
            end
            default : 
                $fatal (1, {"No such shape: ", name});
        endcase
    endfunction
    
endclass