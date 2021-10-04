package org.devops

// ��������
def Build(buildType,buildShell){
    def buildTools = ["mvn":"M2","ant":"ANT","gradle":"GRADLE","npm":"NPM"]

    println("��ǰѡ��Ĺ��������ǣ�${buildType}")
    buildHome = tool buildTools[buildType]
    if ( "${buildType}" == "npm" ){
        sh """
            export NODE_HOME=${buildHome}
            export PATH=\$NODE_HOME/bin:\$PATH
            ${buildHome}/bin/${buildType} ${buildShell}"""
    }else {
        sh "${buildHome}/bin/${buildType} ${buildShell}"
    }
}