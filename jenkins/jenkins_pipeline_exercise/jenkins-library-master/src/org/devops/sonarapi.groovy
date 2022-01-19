package org.devops

//封装HTTP请求
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

// 获取Sonar质量阈状态
def GetProjectStatus(projectName){
    apiUrl = "project_branches/list?project=${projectName}"
    response = HttpReq("GET",apiUrl,'')

    response = readJSON text: """${response.content}"""
    result = response["branches"][0]["status"]["qualityGateStatus"]

    return result
}

// 搜索Sonar项目
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
// 创建sonar项目
def CreateProject(projectName){
    apiUrl = "projects/create?name=${projectName}&project=${projectName}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}

// 配置项目质量规则
def ConfigQualityProfiles(projectName,language,qpname){
    apiUrl = "qualityprofiles/add_project?language=${language}&project=${projectName}&qualityProfile=${qpname}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}

// 获取质量阈 gateId
def GetQualityGateId(gateName){
    apiUrl = "qualitygates/show?name=${gateName}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""
    result = response["id"]

    return result
}

// 配置项目质量阈
def ConfigQualityGate(projectName,gateName){
    gateId = GetQualityGateId(gateName)
    apiUrl = "qualitygates/select?gateId=${gateId}&projectKey=${projectName}"
    response = HttpReq("POST",apiUrl,'')
    println(response)
}