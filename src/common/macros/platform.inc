%ifdef HOST
    %define SVC(name) extern svc_%+name
%else
    %define SVC(name) extern svc_%+name
%endif
