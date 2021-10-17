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

// ��Ʒ����
def ArtifactUpdate(updateType,artifactUrl){

    // ��������
    if ("${updateType}" == "snapshot -> release"){
        println("snapshot -> release")

        // ����ԭʼ��Ʒ
        sh " rm -rf updates && mkdir updates && cd updates && wget ${artifactUrl} && ls -l"

        // ��ȡartifactID
        artifactUrl = artifactUrl - "http://nexus.mieken.cn/repository/maven-hostd/"
        artifactUrl = artifactUrl.split("/").toList()

        env.jarName = artifactUrl[-1]
        env.pomVersion = artifactUrl[-2].replace("SNAPSHOT","RELEASE")
        env.pomArtifact = artifactUrl[-3]
        pomPackaging = artifactUrl[-1].split("\\.").toList()[-1]
        env.pomPackaging = pomPackaging
        env.pomPackage = "/${pomArtifact}/${pomVersion}/${jarName}"
        env.pomGroupId = artifactUrl[0..-4].join(".")

        println("${pomGroupId}###${pomArtifact}###${pomVersion}###${pomPackaging}")
        env.newJarName = "${pomArtifact}-${pomVersion}.${pomPackaging}"

        // ��������
        sh "cd updates && mv ${jarName} ${newJarName}"

        // ʹ��Nexus artifact uploader �ϴ���Ʒ
        env.repoName = "maven-releases"
        env.filePath = "updates/${newJarName}"
        NexusUpload()
    }

}

def main(uploadType){
    // ��ȡpom
    GetGav()

    // �ж��ϴ���ʽ
    if ("${uploadType}" == "maven"){
        MavenUpload()
    } else if("${uploadType}" == "nexus"){
        env.repoName = "maven-hostd"
        env.filePath = "target/${jarName}"
        NexusUpload()
    }
}