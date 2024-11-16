class shape_reporter #(type T = shape);
    protected static T shape_storage [$];
    
    static function void store_shape(T l);
        shape_storage.push_back(l);
    endfunction
    
    static function void report_shapes();
        foreach(shape_storage[i]) begin
            shape_storage[i].print();
        end
    endfunction
endclass