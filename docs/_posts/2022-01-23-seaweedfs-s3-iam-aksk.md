---
layout: post
title: "Set AK/SK of S3 and Iam in Seaweedfs"
date:  2022-01-23 10:11:53 +0800
categories: Seaweedfs
---

目前开始搞[Seaweedfs](https://github.com/chrislusf/seaweedfs)，一个
快速的分布式存储系统。这里记录一下为`S3 server`和`Iam server`配置
`AK/SK (Access Key / Secret Key)`的步骤。

首先，启动Seaweedfs的master，volume，Filer，S3这四个server：
```
$ ./weed server -dir=/tmp/seaweedfs_data -s3
```

再单独启动iam server：
```
$ ./weed iam
```

安装[aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)，
然后开始进行配置：
```
$ aws configure
AWS Access Key ID [None]: 123          # AK
AWS Secret Access Key [None]: 123      # SK
Default region name [None]: guosj
Default output format [None]:

$ aws configure set default.s3.signature_version s3v4
```

这里设置了AK/SK，然后我们再来用`weed shell`配置：
```
$ ./weed shell
master: localhost:9333 filers: [192.168.2.31:8888]
> s3.configure -access_key=123 -secret_key=123 -user=guosj -actions=Read,Write,List,Tagging,Admin -apply
{
  "identities": [
    {
      "name": "guosj",
      "credentials": [
        {
          "accessKey": "123",
          "secretKey": "123"
        }
      ],
      "actions": [
        "Read:",
        "Write:",
        "List:",
        "Tagging:",
        "Admin:"
      ]
    }
  ]
}
```
注意，这里的`-access_key`，`-secret_key`和`-user`的值要和上面用命令`aws configure`配置的值
相匹配。

然后，我们在命令行中请求列出s3的bucket信息：
```
$ aws --no-verify-ssl --endpoint-url http://localhost:8333 s3 ls
2022-01-21 22:19:24 newbucket3
```

请求成功。

然后再测试一下`iam server`：
```
$ aws --endpoint http://localhost:8111 iam list-users
{
    "Users": [
        {
            "UserName": "guosj"
        }
    ]
}
```

请求成功。

以上。
