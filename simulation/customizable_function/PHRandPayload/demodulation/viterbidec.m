function out = viterbidec(in)
x = in;
cr = 2;
len = length(x)/cr;
route1 = zeros(len,1);
route2 = zeros(len,1);
route3 = zeros(len,1);
route4 = zeros(len,1);
route1temp = zeros(len,1);
route2temp = zeros(len,1);
route3temp = zeros(len,1);
route4temp = zeros(len,1);
for i = 1:len
    if(i == 1)
        route1(1,1) = 0;
        route2(1,1) = 0; 
        metric1 = length(find(([x(1);x(2)]-[0;0])~=0));
        route3(1,1) = 1;
        route4(1,1) = 1;
        metric3 = length(find(([x(1);x(2)]-[0;1])~=0));
    end
    if(i == 2)
        temp1 = length(find(([x(2*i-1);x(2*i)]-[0;0])~=0));
        temp2 = length(find(([x(2*i-1);x(2*i)]-[0;1])~=0));
        temp3 = length(find(([x(2*i-1);x(2*i)]-[1;0])~=0));
        temp4 = length(find(([x(2*i-1);x(2*i)]-[1;1])~=0));
        route1temp = route1;
        route2temp = route3;
        route3temp = route1;
        route4temp = route3;
        route1temp(i,1) = 0;
        route2temp(i,1) = 0; 
        metric1new = metric1+temp1;
        metric2new = metric3+temp3;
        route3temp(i,1) = 1;
        route4temp(i,1) = 1;
        metric3new = metric1+temp2;
        metric4new = metric3+temp4;
        metric1 = metric1new;
        metric2 = metric2new;
        metric3 = metric3new;
        metric4 = metric4new;
        route1(1:i,1) = route1temp(1:i,1);
        route2(1:i,1) = route2temp(1:i,1);
        route3(1:i,1) = route3temp(1:i,1);
        route4(1:i,1) = route4temp(1:i,1);
    end
    if(i > 2)
        temp1 = length(find(([x(2*i-1);x(2*i)]-[0;0])~=0));
        temp2 = length(find(([x(2*i-1);x(2*i)]-[0;1])~=0));
        temp3 = length(find(([x(2*i-1);x(2*i)]-[1;0])~=0));
        temp4 = length(find(([x(2*i-1);x(2*i)]-[1;1])~=0));
        if (metric1+temp1 < metric2+temp2)
            metric1new = metric1+temp1;
            route1temp(1:i-1,1) = route1(1:i-1,1);
            route1temp(i,1) = 0;
        else
            metric1new = metric2+temp2;
            route1temp(1:i-1,1) = route2(1:i-1,1);
            route1temp(i,1) = 0;
        end
        if (metric3+temp3 < metric4+temp4)
            metric2new = metric3+temp3;
            route2temp(1:i-1,1) = route3(1:i-1,1);
            route2temp(i,1) = 0;
        else
            metric2new = metric4+temp4;
            route2temp(1:i-1,1) = route4(1:i-1,1);
            route2temp(i,1) = 0;            
        end
        if(metric1+temp2 < metric2+temp1)
            metric3new = metric1+temp2;
            route3temp(1:i-1,1) = route1(1:i-1,1);            
            route3temp(i,1) = 1;            
        else
            metric3new = metric2+temp1;
            route3temp(1:i-1,1) = route2(1:i-1,1); 
            route3temp(i,1) = 1;            
        end
        if(metric3+temp4 < metric4+temp3)
            metric4new = metric3+temp4;
            route4temp(1:i-1,1) = route3(1:i-1,1);
            route4temp(i,1) = 1;            
        else
            metric4new = metric4+temp3;
            route4temp(1:i-1,1) = route4(1:i-1,1);
            route4temp(i,1) = 1;            
        end        
        route1(1:i,1) = route1temp(1:i,1);
        route2(1:i,1) = route2temp(1:i,1);
        route3(1:i,1) = route3temp(1:i,1);
        route4(1:i,1) = route4temp(1:i,1);
        metric1 = metric1new;
        metric2 = metric2new;
        metric3 = metric3new;       
        metric4 = metric4new;        
    end 
end
minval = min([metric1,metric2,metric3,metric4]);
if(metric1 == minval)
    route = route1;
end
if(metric2 == minval)
    route = route2;
end
if(metric3 == minval)
    route = route3;
end
if(metric4 == minval)
    route = route4;
end
out = route;
end