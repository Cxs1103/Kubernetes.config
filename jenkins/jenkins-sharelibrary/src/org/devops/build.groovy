package org.devops

// ��������
def Build(buildType,buildShell){
    def buildTools = ["mvn":"M2","ant":"ANT","gradle":"GRADLE","npm":"NPM"]

    println("��ǰѡ��Ĺ��������ǣ�${buildType}")
    buildHome = tool buildTools[buildType]
    sh "${buildHome}/bin/${buildType} ${buildShell}"
}