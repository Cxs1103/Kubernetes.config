package org.devops

//��װHTTP����
def HttpReq(reqType,reqUrl,reqBody){
    def sonarServer = "http://nexus.mieken.cn/service/rest"

    result = httpRequest authentication: 'Nexus-auth',
            httpMode: reqType,
            contentType: "APPLICATION_JSON",
            consoleLogResponseBody: true,
            ignoreSslErrors: true,
            requestBody: reqBody,
            url: "${sonarServer}/${reqUrl}"
            //quiet: true
    return result
}

// ��ȡ�ֿ����������
def GetRepoComponents(repoName){
    println("===============��ȡ�ֿ������������Ϣ===============")
    apiUrl = "v1/components/?repository=${repoName}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""

    println("===============��ȡ�ֿ��������������===============")
    println(response["items"].size())

    return response["items"]
}

// ��ȡ�������
def GetComponentsId(repoName,groupId,actifactId,version){
    result = GetRepoComponents(repoName)

    for (component in result){
        if (component["group"] == groupId && component["name"] == actifactId && component["version"] == version){

            componentId = component["id"]
            println("===============��ȡ�������ID===============")
            println("ID��${componentId}")
            return componentId
        }
    }
}

// ��ȡ���������Ϣ
def GetSingleComponents(repoName,groupId,actifactId,version){
    componentId = GetComponentsId(repoName,groupId,actifactId,version)
    apiUrl = "v1/components/${componentId}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""
    println("===============��ȡ���������Ϣ===============")
    println(response["assets"]["downloadUrl"])
}