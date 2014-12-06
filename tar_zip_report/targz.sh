#!/bin/bash


idx=1; ls -lrS *.txt | awk '{print $9}' | while read fname;do command time -p -o "targz_report/${idx}.${fname}.time" tar zcf ${fname}.tgz ${fname}; idx=`echo ${idx}+1|bc`;  done

:> targz_report/report_time
:> targz_report/report_size

ls -lrt targz_report/*.time | awk '{print $9}'|while read fname; do echo "====${fname}====">>targz_report/report_time;echo "">>targz_report/report_time; cat ${fname} >> targz_report/report_time; echo "">>targz_report/report_time; done


ls -lrt *.tgz |awk '{print $5"\t\t"$9}' > targz_report/report_size


rm -rf *.tgz
