1. 检查列表主配置文件: config
    - example: CheckDirs="basic frontend cloud"
    - 定制这个变量可以指定不同环境的检测脚本，只执行这个变量指定的目录下的检查脚本
2. 新增一个检查项:
    - a.修改主config文件，指定需要运行脚本的目录
    - b.在对应目录下新增检查脚本，输出格式为：
        - ==Check_Item_Name: [0|1|...]  # 检查项的名称
        - Msg: "something"              # 一些关于检查项的输出
    - c.修改检查目录下的config文件，修改BasicScripts变量，加入脚本名
        example:
    ```
        BasicScripts=" \
                $checkdir/shell/check-disk.sh   \
                $checkdir/shell/check-raid.sh   \
                $checkdir/shell/common.sh       \
                "
    ```
3. 执行检查:
    - su - root
    - bash checklist
