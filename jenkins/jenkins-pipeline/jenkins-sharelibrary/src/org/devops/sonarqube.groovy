package org.devops

//scanner
def SonarScan(sonarServer,projectName,projectDsec,projectPath,sonarScanHome){

    // 定义sonar服务器列表
    def servers = ["test":"SonarQube","prod":"SonarQube-prod"]

    withSonarQubeEnv("${servers[sonarServer]}"){
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
    // 质量阈计算结果
    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
    if (qg.status != 'OK') {
      error "Pipeline aborted due to quality gate failure: ${qg.status}"
    }
}