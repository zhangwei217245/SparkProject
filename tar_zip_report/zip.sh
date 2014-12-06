#!/bin/bash


idx=1; ls -lrS *.txt | awk '{print $9}' | while read fname;do command time -p -o "zip_report/${idx}.${fname}.time" zip ${fname}.zip ${fname}; idx=`echo ${idx}+1|bc`;  done

:> zip_report/report_time
:> zip_report/report_size

ls -lrt zip_report/*.time | awk '{print $9}'|while read fname; do echo "====${fname}====">>zip_report/report_time;echo "">>zip_report/report_time; cat ${fname} >> zip_report/report_time; echo "">>zip_report/report_time; done


ls -lrt *.zip |awk '{print $5"\t\t"$9}' > zip_report/report_size

rm -rf *.zip
