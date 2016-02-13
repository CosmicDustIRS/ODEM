function Plot_Skybox
% This function plots a skybox around the scene

skybox = cell(6,4,4);
for c=1:6
    for i=1:4
        for j=1:4
            skybox{c}{i}{j}=imread(['textures\','skybox\',int2str(c),'\',int2str(c),...
                                    ' [www.imagesplitter.net]-', int2str(i-1),'-',int2str(j-1),'.png']);
        end
    end
end
hold on;
a=1e6;

%x negative
for i=0:3
    for j=0:3
        surf([-2*a,-2*a;-2*a,-2*a],[2*a-j*a,2*a-j*a-a;2*a-j*a,2*a-j*a-a],[2*a-i*a,2*a-i*a;2*a-i*a-a,2*a-i*a-a],...
            'FaceColor','texturemap','CData',skybox{4}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
    end
end
%y negative
for i=0:3
    for j=0:3
        surf([2*a-j*a,2*a-j*a-a;2*a-j*a,2*a-j*a-a],[-2*a,-2*a;-2*a,-2*a],[2*a-i*a,2*a-i*a;2*a-i*a-a,2*a-i*a-a],...
            'FaceColor','texturemap','CData',skybox{2}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
    end
end
% %z negative
for i=0:3
    for j=0:3
        surf([2*a-j*a,2*a-j*a-a;2*a-j*a,2*a-j*a-a],[-2*a+i*a,-2*a+i*a;-2*a+i*a+a,-2*a+i*a+a],[-2*a,-2*a;-2*a,-2*a],...
            'FaceColor','texturemap','CData',skybox{3}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
    end
end
%x positive
for i=0:3
    for j=0:3
        surf([2*a,2*a;2*a,2*a],[-2*a+j*a,-2*a+j*a+a;-2*a+j*a,-2*a+j*a+a],[2*a-i*a,2*a-i*a;2*a-i*a-a,2*a-i*a-a],...
            'FaceColor','texturemap','CData',skybox{1}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
    end
end
%y positive
for i=0:3
    for j=0:3
        surf([-2*a+j*a,-2*a+j*a+a;-2*a+j*a,-2*a+j*a+a],[2*a,2*a;2*a,2*a],[2*a-i*a,2*a-i*a;2*a-i*a-a,2*a-i*a-a],...
            'FaceColor','texturemap','CData',skybox{5}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
     end
end
%z positive
for i=0:3
    for j=0:3
        surf([2*a-j*a,2*a-j*a-a;2*a-j*a,2*a-j*a-a],[-2*a+i*a,-2*a+i*a;-2*a+i*a+a,-2*a+i*a+a],[2*a,2*a;2*a,2*a],...
            'FaceColor','texturemap','CData',skybox{6}{i+1}{j+1},'EdgeColor','none','CDataMapping','direct','FaceLightin','none');
    end
end 
