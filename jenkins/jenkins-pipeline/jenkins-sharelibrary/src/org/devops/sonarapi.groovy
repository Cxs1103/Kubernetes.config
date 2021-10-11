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
// ����sonar��Ŀ
def CreateProject(projectName){
    apiUrl = "projects/create?name=${projectName}&project=${projectName}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}

// ������Ŀ��������
def ConfigQualityProfiles(projectName,language,qpname){
    apiUrl = "qualityprofiles/add_project?language=${language}&project=${projectName}&qualityProfile=${qpname}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}

// ��ȡ������ gateId
def GetQualityGateId(gateName){
    apiUrl = "qualitygates/show?name=${gateName}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""
    result = response["id"]

    return result
}

// ������Ŀ������
def ConfigQualityGate(projectName,gateName){
    gateId = GetQualityGateId(gateName)
    apiUrl = "qualitygates/select?gateId=${gateId}&projectKey=${projectName}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}