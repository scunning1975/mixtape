* Subclassification
cap n drop ey1 ey0
su survived if s==1 & d==1
gen ey11=r(mean)
label variable ey11 "Average survival for male child in treatment"
su survived if s==1 & d==0
gen ey10=r(mean)
label variable ey10 "Average survival for male child in control"
gen diff1=ey11-ey10
label variable diff1 "Difference in survival for male children"
su survived if s==2 & d==1
gen ey21=r(mean)
su survived if s==2 & d==0
gen ey20=r(mean)
gen diff2=ey21-ey20
su survived if s==3 & d==1
gen ey31=r(mean)
su survived if s==3 & d==0
gen ey30=r(mean)
gen diff3=ey31-ey30
su survived if s==4 & d==1
gen ey41=r(mean)
su survived if s==4 & d==0
gen ey40=r(mean)
gen diff4=ey41-ey40
count if s==1 & d==0
count if s==2 & d==0
count if s==3 & d==0
count if s==4 & d==0
count
gen wt1=425/2201
gen wt2=45/2201
gen wt3=1667/2201
gen wt4=64/2201
gen wate=diff1*wt1 + diff2*wt2 + diff3*wt3 + diff4*wt4
sum wate sdo