1) run once
mvn install:install-file -Dfile=yenlo-ic-wso2-esb-archetype-1.0.0.jar -DgroupId=com.syngenta.wso2.esb.archetype -DartifactId=syngenta-wso2-esb-archetype -Dversion=1.0.0 -Dpackaging=jar

2) run for every project
cd to the GitHub cloned repository \syngenta-interconnect root folder:
mvn archetype:generate -DarchetypeGroupId=com.syngenta.wso2.esb.archetype -DarchetypeArtifactId=syngenta-wso2-esb-archetype -DarchetypeVersion=1.0.0
