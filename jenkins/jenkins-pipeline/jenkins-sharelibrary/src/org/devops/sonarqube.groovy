package org.devops

//scanner
def SonarScan(projectName,projectDsec,projectPath,sonarScanHome){
    withSonarQubeEnv("SonarQube"){
        def sonarDate = sh returnStdout: true, script: 'date +%Y%m%d%H%M%S'
        sonarDate = sonarDate - "\n"

        sh """
            ${sonarScanHome}/sonar-scanner -Dsonar.projectKey=${projectName} \
            -Dsonar.projectName=${projectName} \
            -Dsonar.projectVersion=${sonarDate} \
            -Dsonar.ws.timeout=30 \
            -Dsonar.projectDescription=${projectDsec} \
            -Dsonar.links.homepage=http://www.baidu.com \
            -Dsonar.sources=${projectPath} \
            -Dsonar.sourceEncoding=UTF-8 \
            -Dsonar.java.binaries=target/classes \
            -Dsonar.java.test.binaries=target/test-classes \
            -Dsonar.java.surefire.report=target/surefire-reports
        """
    }
}