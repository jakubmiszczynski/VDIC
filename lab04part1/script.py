import math

def distance(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

def is_rectangle(points):
    if len(points) != 4:
        return False
    
    dists = []
    for i in range(4):
        for j in range(i + 1, 4):
            dists.append(distance(points[i][0], points[i][1], points[j][0], points[j][1]))
    
    dists.sort()
    
    if dists[0] == dists[1] and dists[2] == dists[3] and dists[4] == dists[5]:
        vectors = [
            (points[1][0] - points[0][0], points[1][1] - points[0][1]),
            (points[2][0] - points[1][0], points[2][1] - points[1][1]),
            (points[3][0] - points[2][0], points[3][1] - points[2][1]),
            (points[0][0] - points[3][0], points[0][1] - points[3][1])
        ]
        
        dot_products = [
            vectors[0][0] * vectors[1][0] + vectors[0][1] * vectors[1][1],
            vectors[1][0] * vectors[2][0] + vectors[1][1] * vectors[2][1],
            vectors[2][0] * vectors[3][0] + vectors[2][1] * vectors[3][1],
            vectors[3][0] * vectors[0][0] + vectors[3][1] * vectors[0][1]
        ]
        
        if all(dot == 0 for dot in dot_products):
            return True
    
    return False

def is_circle(points):
    if len(points) != 2:
        return False
    radius = distance(points[0][0], points[0][1], points[1][0], points[1][1])
    return radius > 0

def triangle_base_and_height(points):
    a = distance(points[0][0], points[0][1], points[1][0], points[1][1])
    b = distance(points[1][0], points[1][1], points[2][0], points[2][1])
    c = distance(points[2][0], points[2][1], points[0][0], points[0][1])
    s = (a + b + c) / 2
    area = math.sqrt(s * (s - a) * (s - b) * (s - c))
    height = (2 * area) / a
    return a, height

def process_input_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            points = []
            coords = list(map(float, line.split()))
            for i in range(0, len(coords), 2):
                points.append((coords[i], coords[i + 1]))
            
            if len(points) == 2:
                if is_circle(points):
                    outfile.write("circle ")
                    outfile.write("{:.2f} 0".format(distance(points[0][0], points[0][1], points[1][0], points[1][1])))
                    points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                    outfile.write(" " + points_str + "\n")
                else:
                    outfile.write("polygon 0 0")
                    points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                    outfile.write(" " + points_str + "\n")
            elif len(points) == 3:
                outfile.write("triangle ")
                base, height = triangle_base_and_height(points)
                outfile.write("{:.2f} {:.2f}".format(base, height))
                points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                outfile.write(" " + points_str + "\n")
            elif len(points) == 4:
                if is_rectangle(points):
                    outfile.write("rectangle ")
                    sides = [
                        distance(points[0][0], points[0][1], points[1][0], points[1][1]),
                        distance(points[1][0], points[1][1], points[2][0], points[2][1]),
                    ]
                    outfile.write("{:.2f} {:.2f}".format(sides[0], sides[1]))
                    points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                    outfile.write(" " + points_str + "\n")
                else:
                    outfile.write("polygon 0 0")
                    points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                    outfile.write(" " + points_str + "\n")
            elif len(points) > 4:
                outfile.write("polygon 0 0")
                points_str = "x".join(["({:.2f},{:.2f})".format(pt[0], pt[1]) for pt in points])
                outfile.write(" " + points_str + "\n")

input_file = '/home/student/jmiszczynski/VDIC/lab04part1/test.txt'
output_file = '/home/student/jmiszczynski/VDIC/lab04part1/data_in.txt'
print("Script end \n")
process_input_file(input_file, output_file)
