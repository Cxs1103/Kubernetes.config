package org.devops

//��װHTTP����
def HttpReq(reqType,reqUrl,reqBody){
    def sonarServer = "http://sonar.mieken.cn/api"

    result = httpRequest authentication: 'Sonar-auth',
            httpMode: reqType,
            contentType: "APPLICATION_JSON",
            consoleLogResponseBody: true,
            ignoreSslErrors: true,
            requestBody: reqBody,
            url: "${sonarServer}/${reqUrl}"

    return result
}

// ��ȡSonar������״̬
def GetProjectStatus(projectName){
    apiUrl = "project_branches/list?project=${projectName}"
    response = HttpReq("GET",apiUrl,'')

    response = readJSON text: """${response.content}"""
    result = response["branches"][0]["status"]["qualityGateStatus"]

    return result
}

// ����Sonar��Ŀ
def SearchProject(projectName){
    apiUrl = "projects/search?project=${projectName}"
    response = HttpReq("GET",apiUrl,'')

    response = readJSON text: """${response.content}"""
    result = response["paging"]["total"]

    if (result.toString() == "0"){
        return "false"
    } else {
        return "true"
    }
}