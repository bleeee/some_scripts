#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Separator_1="——————————————————————————————"
VHuser="overlord"
Username=""
virtusers_file="/etc/vsftpd/virtusers"
backup_vuserfile="/etc/vsftpd/virtusers.bkup"
virtusers_dbfile="/etc/vsftpd/virtusers.db"
Base_User_Path="/opt/vsftp/"
New_User_path=""
Vconf_Path="/etc/vsftpd/vconf/"
Vconf_file=""
writable=""
Umask=""
Idletime=""
Datatime=""
Maxclients=""
Maxperip=""
Maxrate=""
downable=""
upable=""
creatable=""
deleable=""


check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
Add_User(){
Set_User_Name
Set_User_Pass
Create_Name_Pass
Create_Path
Set_Config
Create_Config
Final_Confirm
}
Delete_User(){
Set_User_Name_Del
Delete_Name_Pass
Delete_Path
Delete_Config
Final_Confirm
}
Set_User_Name(){
    illegal=(\! \  \~ \\ \@ \# \\\$ \% \\\^ \& \\\* \( \) \- \+ \_ \= \? \/ \\\. \, \{ \} \[ \] \: \; \" \' \` \< \>)
	while true
	do
	echo -e "请输入要添加的用户名"
	stty erase '^H' && read -p "(确认不包含非法字符):" Uname
	if [[ -n "$Uname" ]]; then
        testflag=0
        for ((i=0;i<${#illegal[@]};i++))
        do
            if [[ $Uname =~ ${illegal[$i]} ]]
            then
                testflag=1
                break
            fi
        done
        if (( $testflag==0 ));then
        	if [[ -z `cat $virtusers_file|grep -w $Uname` ]];then
                Username=$Uname
                echo && echo ${Separator_1} && echo -e "	用户名 : ${Green_font_prefix}${Username}${Font_color_suffix}" && echo ${Separator_1} && echo
                break
            else
                echo -e "用户名已存在"
            fi 
        else
            echo -e "请输入不包含非法字符的用户名"
        fi

	else
		echo -e "请输入非空用户名"
	fi
	done
}
Set_User_Name_Del(){
    illegal=(\! \  \~ \\ \@ \# \\\$ \% \\\^ \& \\\* \( \) \- \+ \_ \= \? \/ \\\. \, \{ \} \[ \] \: \; \" \' \` \< \>)
	while true
	do
	echo -e "请输入要删除的用户名"
	stty erase '^H' && read -p "(确认不包含非法字符):" Uname
	if [[ -n "$Uname" ]]; then
        testflag=0
        for ((i=0;i<${#illegal[@]};i++))
        do
            if [[ $Uname =~ ${illegal[$i]} ]]
            then
                testflag=1
                break
            fi
        done
        if (( $testflag==0 ));then
        	if [[ -n `cat $virtusers_file|grep -w $Uname` ]];then
                Username=$Uname
                echo && echo ${Separator_1} && echo -e "	用户名 : ${Green_font_prefix}${Username}${Font_color_suffix}" && echo ${Separator_1} && echo
                break
            else
                echo -e "用户名不存在"
            fi 
        else
            echo -e "请输入不包含非法字符的用户名"
        fi

	else
		echo -e "请输入非空用户名"
	fi
	done
}
Set_User_Pass(){
    illegal=(\! \  \~ \\ \@ \# \\\$ \% \\\^ \& \\\* \( \) \- \+ \_ \= \? \/ \\\. \, \{ \} \[ \] \: \; \" \' \` \< \>)
	while true
	do
	echo -e "请输入要设置的密码"
	stty erase '^H' && read -p "(确认不包含非法字符):" Upass
	if [[ -n "$Upass" ]]; then
        testflag=0
        for ((i=0;i<${#illegal[@]};i++))
        do
            if [[ $Upass =~ ${illegal[$i]} ]]
            then
                testflag=1
                break
            fi
        done
        if (( $testflag==0 ));then
            Userpass=$Upass
        	echo && echo ${Separator_1} && echo -e "	密码 : ${Green_font_prefix}${Userpass}${Font_color_suffix}" && echo ${Separator_1} && echo
            break
        else
            echo -e "请输入不包含非法字符的密码"
        fi

	else
		echo -e "请输入非空密码"
	fi
	done
}
Create_Name_Pass(){
echo $Username >> $virtusers_file
echo $Userpass >> $virtusers_file
}
Create_Path(){
New_User_path=$Base_User_Path$Username
mkdir $New_User_path
chown -R $VHuser.$VHuser $New_User_path
}
Set_Config(){
#write_enable
	while true
	do
	echo -e "请输入此用户是否可写，0不可，1可"
	stty erase '^H' && read -p "(默认可):" tchar
	[[ -z "$tchar" ]] && tchar="1"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        if (( $tchar==1 ));then
            writable="YES"
        else
            writable="NO"
        fi
        break
    else
        echo -e "请输入数字"
    fi
	done
#anon_world_readable_only
	while true
	do
	echo -e "请输入此用户是否可下载，0不可，1可"
	stty erase '^H' && read -p "(默认可):" tchar
	[[ -z "$tchar" ]] && tchar="1"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        if (( $tchar==1 ));then
            downable="NO"
        else
            downable="YES"
        fi
        break
    else
        echo -e "请输入数字"
    fi
	done
#anon_upload_enable
	while true
	do
	echo -e "请输入此用户是否可上传，0不可，1可"
	stty erase '^H' && read -p "(默认可写):" tchar
	[[ -z "$tchar" ]] && tchar="1"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        if (( $tchar==1 ));then
            upable="YES"
        else
            upable="NO"
        fi
        break
    else
        echo -e "请输入数字"
    fi
	done
#anon_mkdir_write_enable
	while true
	do
	echo -e "请输入此用户是否可创建目录，0不可，1可"
	stty erase '^H' && read -p "(默认可):" tchar
	[[ -z "$tchar" ]] && tchar="1"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        if (( $tchar==1 ));then
            creatable="YES"
        else
            creatable="NO"
        fi
        break
    else
        echo -e "请输入数字"
    fi
	done
#anon_other_write_enable
	while true
	do
	echo -e "请输入此用户是否可删除和重命名，0不可，1可"
	stty erase '^H' && read -p "(默认可):" tchar
	[[ -z "$tchar" ]] && tchar="1"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        if (( $tchar==1 ));then
            deleable="YES"
        else
            deleable="NO"
        fi
        break
    else
        echo -e "请输入数字"
    fi
	done
#local_umask   
    while true
	do
	echo -e "请输入此用户上传文件权限掩码"
	stty erase '^H' && read -p "(默认022):" tchar
	[[ -z "$tchar" ]] && tchar="022"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Umask=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
#idle_session_timeout   
    while true
	do
	echo -e "请输入此用户空闲超时"
	stty erase '^H' && read -p "(默认600):" tchar
	[[ -z "$tchar" ]] && tchar="600"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Idletime=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
#data_connection_timeout   
    while true
	do
	echo -e "请输入此用户单词最大传输时间"
	stty erase '^H' && read -p "(默认120):" tchar
	[[ -z "$tchar" ]] && tchar="120"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Datatime=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
#max_clients   
    while true
	do
	echo -e "请输入此用户最大IP数"
	stty erase '^H' && read -p "(默认10):" tchar
	[[ -z "$tchar" ]] && tchar="10"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Maxclients=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
#max_per_ip   
    while true
	do
	echo -e "请输入此用户单IP最大并发数"
	stty erase '^H' && read -p "(默认5):" tchar
	[[ -z "$tchar" ]] && tchar="5"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Maxperip=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
#local_max_rate   
    while true
	do
	echo -e "请输入此用户空闲超时"
	stty erase '^H' && read -p "(默认50000b/s):" tchar
	[[ -z "$tchar" ]] && tchar="50000"
    expr ${tchar} + 1 &>/dev/null
    if [[ $? == 0 ]]; then
        Maxrate=$tchar
        break
    else
        echo -e "请输入数字"
    fi
	done
}
Create_Config(){
Vconf_file=$Vconf_Path$Username
echo "local_root=$New_User_path">> $Vconf_file
echo "write_enable=$writable">> $Vconf_file
echo "anon_world_readable_only=$downable">> $Vconf_file
echo "anon_upload_enable=$upable">> $Vconf_file
echo "anon_mkdir_write_enable=$creatable">> $Vconf_file
echo "anon_other_write_enable=$deleable">> $Vconf_file
echo "local_umask=$Umask">> $Vconf_file
echo "idle_session_timeout=$Idletime">> $Vconf_file
echo "data_connection_timeout=$Datatime">> $Vconf_file
echo "max_clients=$Maxclients">> $Vconf_file
echo "max_per_ip=$Maxperip">> $Vconf_file
echo "local_max_rate=$Maxrate">> $Vconf_file
}
Delete_Name_Pass(){
sed -i "/^$Username$/,+1d" $virtusers_file
rm -rf $virtusers_dbfile
}
Delete_Path(){
New_User_path=$Base_User_Path$Username
rm -rf $New_User_path
}
Delete_Config(){
Vconf_file=$Vconf_Path$Username
rm -rf $Vconf_file

}
Final_Confirm(){
/bin/cp -rf $virtusers_file $backup_vuserfile
db_load -T -t hash -f $virtusers_file $virtusers_dbfile
service vsftpd restart
}
check_root
echo -e "  vsftpd+db4 用户管理脚本 root运行 
  ---- ble | HRBEU ----

  ${Green_font_prefix}1.${Font_color_suffix} 添加用户
  ${Red_font_prefix}2.${Font_color_suffix} 删除用户
 "
echo && stty erase '^H' && read -p "请输入数字 [1-2]：" num
case "$num" in
	1)
	Add_User
	;;
	2)
	Delete_User
	;;
	*)
	echo -e "${Error} 请输入正确的数字 [1-2]"
	;;
esac
