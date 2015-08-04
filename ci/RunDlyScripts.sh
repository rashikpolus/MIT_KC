#!/bin/bash
env=$ENV
rundbflag=$RunDB
if [ "$env" == "kcdev" -o "$env" == "all" -o "$env" == "devqasttr" ] 
then
	sudo -u www cp -u /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war /usr/local/tomcat_kc_dev/webapps/kc-dev.war
	sleep 3
	#sudo -u www chown www:www /usr/local/tomcat_kc_dev/webapps/kc-dev.war
	#sleep 1
fi
if [ "$env" == "kcqawkly" -o "$env" == "all" -o "$env" == "devqasttr" ]
then
	sudo -u www scp /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war www@kc-train-web:/usr/local/tomcat-kc-qa-wkly/webapps/kc-qa-wkly.war
	sleep 3
	#sudo -u coeus cp -u /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war www@kc-train-web:/home/coeus/kc/deployment/.
	#sleep 1
fi
if [ "$env" == "kctrain" -o "$env" == "devqasttr" ]
then
	sudo -u www scp /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war www@kc-train-web:/usr/local/tomcat-kc-train/webapps/kc-train.war
fi
if [ "$env" == "kcstage" -o "$env" == "all" -o "$env" == "devqasttr" ]
then
	sudo -u www scp /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war www@kc-stage-web:/usr/local/tomcat_kc_stage/webapps/kc-stage.war
	sudo -u www scp /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war tomcat@kc-stage-app-1.mit.edu:/usr/local/tomcat-kc-stage/webapps/kc-stage.war
fi
if [ "$env" == "kcsdbx" ]
then
	sudo -u www scp /var/lib/jenkins/jobs/kc_mit_6_0/workspace/coeus-webapp/target/coeus-webapp-1505.70.war www@kc-stage-web:/usr/local/tomcat_kc_sdbx/webapps/kc-sdbx.war
fi