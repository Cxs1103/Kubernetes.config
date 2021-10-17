package org.devops

//封装HTTP请求
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

// 获取仓库中所有组件
def GetRepoComponents(repoName){
    println("===============获取仓库中所有组件信息===============")
    apiUrl = "v1/components/?repository=${repoName}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""

    println("===============获取仓库中所有组件个数===============")
    println(response["items"].size())

    return response["items"]
}

// 获取单个组件
def GetComponentsId(repoName,groupId,actifactId,version){
    result = GetRepoComponents(repoName)

    for (component in result){
        if (component["group"] == groupId && component["name"] == actifactId && component["version"] == version){

            componentId = component["id"]
            println("===============获取单个组件ID===============")
            println("ID：${componentId}")
            return componentId
        }
    }
}

// 获取单个组件信息
def GetSingleComponents(repoName,groupId,actifactId,version){
    componentId = GetComponentsId(repoName,groupId,actifactId,version)
    apiUrl = "v1/components/${componentId}"
    response = HttpReq("GET",apiUrl,'')
    response = readJSON text: """${response.content}"""
    println("===============获取单个组件信息===============")
    println(response["assets"]["downloadUrl"])
}