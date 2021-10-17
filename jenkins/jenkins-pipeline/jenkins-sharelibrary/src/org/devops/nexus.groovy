package org.devops

// ��ȡPOM�ļ��е�����
def GetGav(){
    def jarName = sh returnStdout: true, script: "cd target;ls *.jar"
    env.jarName = jarName - "\n"

    def pom = readMavenPom file: 'pom.xml'
    env.pomVersion = "${pom.version}"
    env.pomArtifact = "${pom.artifactId}"
    env.pomPackaging = "${pom.packaging}"
    env.pomGroupId = "${pom.groupId}"

    println("${pomGroupId}-${pomArtifact}-${pomVersion}-${pomPackaging}")

    return ["${pomGroupId}","${pomArtifact}","${pomVersion}","${pomPackaging}"]
}

// ����Maven�����ϴ���Ʒ
def MavenUpload(){
def mvnHome = tool "M2"
sh  """
    cd target/
    ${mvnHome}/bin/mvn deploy:deploy-file -Dmaven.test.skip=true \
                                          -Dfile=${jarName} -DgroupId=${pomGroupId} \
                                          -DartifactId=${pomArtifact} -Dversion=${pomVersion} \
                                          -Dpackaging=${pomPackaging} -DrepositoryId=maven-hostd \
                                          -Durl=http://nexus.mieken.cn/repository/maven-hostd
    """
}


// ʹ�� nexus artifact uploader �ϴ���Ʒ
def NexusUpload(){
def repoName = "maven-hostd"
def filePath = "target/${jarName}"
nexusArtifactUploader artifacts: [[artifactId: "${pomArtifact}",
                                    classifier: '',
                                    file: "${filePath}",
                                    type: "${pomPackaging}"]],
                        credentialsId: 'Nexus-auth',
                        groupId: "${pomGroupId}",
                        nexusUrl: 'nexus.mieken.cn',
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        repository: "${repoName}",
                        version: "${pomVersion}"
}

def main(uploadType){
    // ��ȡpom
    GetGav()

    // �ж��ϴ���ʽ
    if ("${uploadType}" == "maven"){
        MavenUpload()
    } else if("${uploadType}" == "nexus"){
        NexusUpload()
    }
}