function [p, v, c ,n3, np, nv, shape_handle] = Load_ShapeModel( file_path )
% This function loads the shape model file and calculates the normal
% vectors of each facett

global dladsc
shape_handle = cspice_dasopr(file_path);
dladsc = cspice_dlabfs(shape_handle);
[nv,np] = cspice_dskz02(shape_handle, dladsc);

p = cspice_dskp02(shape_handle, dladsc, 1, np);
v = cspice_dskv02(shape_handle, dladsc, 1, nv);
v = v.*1000;
%Calculate normal vectors n3
n1(1:3,:) = v(1:3,p(2,:)) - v(1:3,p(1,:));
n2(1:3,:) = v(1:3,p(3,:)) - v(1:3,p(1,:));
n3 = zeros(np,3);
for i=1:np
    orth = cross(n1(:,i),n2(:,i));
    n3(i,:) = orth./norm(orth);
end

c = zeros(np,4);
for i=1:np
    c(i,1)=(v(1,p(1,i)) + v(1,p(2,i)) + v(1,p(3,i)))/3;
    c(i,2)=(v(2,p(1,i)) + v(2,p(2,i)) + v(2,p(3,i)))/3;
    c(i,3)=(v(3,p(1,i)) + v(3,p(2,i)) + v(3,p(3,i)))/3;
    c(i,4) = norm(c(i,1:3));
end