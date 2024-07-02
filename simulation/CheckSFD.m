function flag = CheckSFD(Rx)

flag = false;
if(Rx.SFDwindowidx >=-9 &&Rx.SFDwindowidx <=11)
    flag = true;
end

end