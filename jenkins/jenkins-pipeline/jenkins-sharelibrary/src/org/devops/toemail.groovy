package org.devops

//�����ʼ�����
def Email(status,emailUser){
    emailext body: """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="UTF-8">
            </head>
            <body leftmargin="8" marginwidth="0" topmargin="8" marginheight="4" offset="0">
                <img src="http://gitlab.mieken.cn/uploads/-/system/user/avatar/1/avatar.png">
                <table width="95%" cellpadding="0" cellspacing="0" style="font-size: 11pt; font-family: Tahoma, Arial, Helvetica, sans-serif">
                    <tr>
                        <td><br />
                            <b><font color="#0B610B">������Ϣ</font></b>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <ul>
                                <li>��Ŀ���ƣ�${JOB_NAME}</li>
                                <li>������ţ�${BUILD_ID}</li>
                                <li>����״̬: ${status} </li>
                                <li>��Ŀ��ַ��<a href="${BUILD_URL}">${BUILD_URL}</a></li>
                                <li>������־��<a href="${BUILD_URL}console">${BUILD_URL}console</a></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </body>
            </html>  """,
            subject: "Jenkins-${JOB_NAME}��Ŀ������Ϣ ",
            to: emailUser
}